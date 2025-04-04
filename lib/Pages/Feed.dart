import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../DataAccessLayer/UserDAO.dart';
import '../DataAccessLayer/VolunteeringEventDAO.dart';
import '../DataAccessLayer/VolunteeringEventRegistrationsDAO.dart';
import '../DataAccessLayer/VolunteeringHistoryDAO.dart';
import '../Models/LeaderboardStatistic.dart';
import '../Models/VolunteeringEvent.dart';
import 'Leaderboard.dart';
import 'Messages.dart';
import 'NavBarManager.dart';
import 'Profile.dart';
import 'RecordVolunteering.dart';
import 'SearchVolunteering.dart';
import 'VolunteeringEventDetails.dart';

class FeedPage extends StatefulWidget {
  final GlobalKey<NavigatorState> mainNavigatorKey;
  final GlobalKey<NavigatorState> logInNavigatorKey;

  const FeedPage({super.key, required this.mainNavigatorKey, required this.logInNavigatorKey});

  @override
  State<StatefulWidget> createState() => FeedPageState();
}

class FeedPageState extends State<FeedPage> {
  int _overallIndividualRank = 0;
  int _teamIndividualRank = 0;
  int _yourTeamsRank = 0;
  late String _yourTeamId;
  bool areYourRanksLoading = true;
  bool isYourTeamsRankLoading = true;
  bool _areHoursLoading = true;
  int _mostRecentBadge = 0;
  late List<LeaderboardStatistic> individualLeaderboardStatistics;
  late List<LeaderboardStatistic> teamLeaderboardStatistics;
  late List<LeaderboardStatistic> individualWithinTeamLeaderboardStatistics;
  bool _hasUnreadChats = false;
  bool hasUnreadChatsLoading = false;

  bool areLeaderboardStatsLoading = true;
  late List<VolunteeringEvent> upcomingVolunteeringEvents = [];
  bool areVolunteeringEventsLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchData();
  }

  void initialiseData() {
    _hasUnreadChats = false;
    hasUnreadChatsLoading = false;
    _overallIndividualRank = 0;
    _teamIndividualRank = 0;
    _yourTeamsRank = 0;
    _yourTeamId = "";
    areYourRanksLoading = true;
    isYourTeamsRankLoading = true;
    _areHoursLoading = true;
    _mostRecentBadge = 0;
    individualLeaderboardStatistics = [];
    teamLeaderboardStatistics = [];
    areLeaderboardStatsLoading = true;
    upcomingVolunteeringEvents = [];
    areVolunteeringEventsLoading = true;
  }

  Future<void> _fetchData() async {
    initialiseData();
    await _fetchYourTeamId();
    await _fetchLeaderboardStats();
    await _fetchYourRanks();
    await _fetchYourHours();
    await getTeamOverallRank();
    await _fetchVolunteeringEvents();
    await _fetchHasUnreadChats();
  }

  Future<void> _fetchYourTeamId() async {
    String? teamID = await UserDAO.getUserTeam(FirebaseAuth.instance.currentUser!.uid);
    setState(() {
      _yourTeamId = teamID!;
    });
  }

  Future<void> _fetchLeaderboardStats() async {
    try {
      List<LeaderboardStatistic> individualStats =
          await VolunteeringHistoryDAO.getLeaderboardStatistics(DateTime.now().add(Duration(days: -365)), DateTime.now(), "Any");
      List<LeaderboardStatistic> teamStats =
          await VolunteeringHistoryDAO.getTeamLeaderboardStatistics(DateTime.now().add(Duration(days: -365)), DateTime.now(), "Any");
      List<LeaderboardStatistic> individualWithinTeamStats = await VolunteeringHistoryDAO.getLeaderboardStatisticsWithinTeamUsingTeamId(
          DateTime.now().add(Duration(days: -365)), DateTime.now(), "Any", _yourTeamId);

      setState(() {
        individualLeaderboardStatistics = individualStats;
        teamLeaderboardStatistics = teamStats;
        individualWithinTeamLeaderboardStatistics = individualWithinTeamStats;
        areLeaderboardStatsLoading = false;
      });
    } catch (error) {
      //print('Error fetching data: $error');
    }
  }

  Future<void> _fetchYourRanks() async {
    int userRank = 0;
    int teamRank = 0;

    for (int i = 0; i < individualLeaderboardStatistics.length; i++) {
      if (individualLeaderboardStatistics[i].ID == FirebaseAuth.instance.currentUser?.uid) {
        userRank = individualLeaderboardStatistics[i].rank;
        break;
      }
    }

    for (int i = 0; i < individualWithinTeamLeaderboardStatistics.length; i++) {
      if (individualWithinTeamLeaderboardStatistics[i].ID == FirebaseAuth.instance.currentUser?.uid) {
        teamRank = individualWithinTeamLeaderboardStatistics[i].rank;
        break;
      }
    }

    setState(() {
      _overallIndividualRank = userRank;
      _teamIndividualRank = teamRank;
      areYourRanksLoading = false;
    });
  }

  Future<void> getTeamOverallRank() async {
    String? teamID = await UserDAO.getUserTeam(FirebaseAuth.instance.currentUser!.uid);
    int teamRank = 0;

    for (int i = 0; i < teamLeaderboardStatistics.length; i++) {
      if (teamLeaderboardStatistics[i].ID == teamID) {
        teamRank = teamLeaderboardStatistics[i].rank;
        break;
      }
    }
    setState(() {
      _yourTeamsRank = teamRank;
      isYourTeamsRankLoading = false;
    });
  }

  Future<void> _fetchYourHours() async {
    String loggedInUserId = FirebaseAuth.instance.currentUser?.uid ?? '';
    int allTimeHours = 0;
    int mostRecentBadge = 0;
    List<int> badgeThresholds = [5, 10, 15, 30, 50, 100];

    for (LeaderboardStatistic stat in individualLeaderboardStatistics) {
      if (stat.ID == loggedInUserId) {
        allTimeHours = stat.numHours;
      }
    }

    for (int threshold in badgeThresholds) {
      if (allTimeHours >= threshold) {
        mostRecentBadge = threshold;
      } else {
        break;
      }
    }

    setState(() {
      _mostRecentBadge = mostRecentBadge;
      _areHoursLoading = false;
    });
  }

  Future<void> _fetchVolunteeringEvents() async {
    try {
      List<VolunteeringEvent> upcomingVolunteering = [];

      List<String> allEventIds = await VolunteeringEventRegistrationsDAO.getAllEventIdsForUser(FirebaseAuth.instance.currentUser!.uid);

      for (var eventId in allEventIds) {
        VolunteeringEvent? event = await VolunteeringEventDAO.getVolunteeringEvent(eventId);

        if (event!.date.isAfter(DateTime.now())) {
          upcomingVolunteering.add(event!);
        }
      }

      setState(() {
        upcomingVolunteeringEvents.addAll(upcomingVolunteering!);
        areVolunteeringEventsLoading = false;
      });
    } catch (e) {
      //print('Error fetching events: $e');
    }
  }

  Future<void> _fetchHasUnreadChats() async {
    try {
      bool unread = await hasUnreadChats();

      setState(() {
        _hasUnreadChats = unread;
        hasUnreadChatsLoading = false;
      });
    } catch (e) {
      //print('Error fetching events: $e');
    }
  }

  @override
  Widget build(context) {
    return RefreshIndicator(
        onRefresh: _fetchData,
        child: SingleChildScrollView(
            child: Padding(
                padding: const EdgeInsets.only(top: 40, left: 30, right: 30, bottom: 20),
                child: Column(children: [
                  Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                    const Text(
                      'Feed',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 30,
                        decorationColor: Colors.black,
                      ),
                    ),
                    buildMessagesButton(context),
                  ]),
                  SizedBox(height: 25),
                  buildYourRanks(context),
                  SizedBox(height: 25),
                  Row(
                    children: [
                      buildYourTeamsRank(context),
                      SizedBox(width: 25),
                      buildRecentProfileBadge(context),
                    ],
                  ),
                  SizedBox(height: 25),
                  buildTop3Individuals(context),
                  SizedBox(height: 25),
                  buildUpcomingVolunteering(context),
                ]))));
  }

  Widget buildMessagesButton(BuildContext context) {
    return Align(
        alignment: Alignment.centerRight,
        child: Stack(
          children: [
            Container(
              alignment: Alignment.topRight,
              height: 50,
              width: 50,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(15),
                gradient: const LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [Color(0xFF8643FF), Color(0xFF4136F1)],
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.grey.withOpacity(0.3),
                    spreadRadius: 5,
                    blurRadius: 7,
                    offset: const Offset(0, 3),
                  ),
                ],
              ),
              child: Center(
                child: IconButton(
                  onPressed: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (context) => MessagingPage(),
                      ),
                    );
                  },
                  icon: const Icon(
                    Icons.messenger_outline_rounded,
                    color: Colors.white,
                    size: 30,
                  ),
                  color: Color(0xFF4136F1),
                  iconSize: 50,
                ),
              ),
            ),
            if (!hasUnreadChatsLoading && _hasUnreadChats)
              Transform.translate(
                  offset: const Offset(38, -2),
                  child: Positioned(
                      top: 0,
                      right: 0,
                      child: CircleAvatar(
                        child: Text(''),
                        backgroundColor: Colors.red,
                        radius: 7,
                      )))
          ],
        ));
  }

  String _getRankSuffix(int rank) {
    if (rank >= 11 && rank <= 13) {
      return 'th';
    } else {
      switch (rank % 10) {
        case 1:
          return 'st';
        case 2:
          return 'nd';
        case 3:
          return 'rd';
        default:
          return 'th';
      }
    }
  }

  Widget _buildStat(int rank, String label) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              '$rank',
              style: const TextStyle(
                fontSize: 33,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(width: 4),
            Text(
              _getRankSuffix(rank),
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w700,
              ),
            ),
          ],
        ),
        const SizedBox(height: 2),
        Text(
          label,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w400,
          ),
        ),
      ],
    );
  }

  Widget buildYourRanks(BuildContext context) {
    return GestureDetector( //todo this shouldnt make a new nav bar manager should have a call back to change ht ein dec
        onTap: () {
          Navigator.of(context).push(MaterialPageRoute(
              builder: (context) => NavBarManager(
                    initialIndex: 1,
                    searchVolunteeringPage: SearchVolunteeringPage(),
                    feedPage: widget,
                    //profilePage: ProfilePage(),
                    recordVolunteeringPage: RecordVolunteeringPage(),
                    leaderboardPage: LeaderboardPage(isTeamStat: false), mainNavigatorKey: widget.mainNavigatorKey, logInNavigatorKey: widget.logInNavigatorKey,
                  )));
        },
        child: Container(
          width: 324,
          padding: const EdgeInsets.only(top: 20, left: 20, right: 20, bottom: 30),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(30.0),
            boxShadow: [
              BoxShadow(
                color: Colors.grey.withOpacity(0.2),
                spreadRadius: 10,
                blurRadius: 15,
                offset: const Offset(0, 3),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Your Ranks',
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 10),
              areYourRanksLoading
                  ? const CircularProgressIndicator()
                  : Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        _buildStat(_overallIndividualRank, 'Overall'),
                        _buildStat(_teamIndividualRank, 'In your team'),
                      ],
                    ),
            ],
          ),
        ));
  }

  Widget buildTop3Individuals(BuildContext context) {
    return GestureDetector(
        onTap: () {
          Navigator.of(context).push(MaterialPageRoute(
              builder: (context) => NavBarManager(
                    initialIndex: 1,
                    searchVolunteeringPage: SearchVolunteeringPage(),
                    feedPage: widget,
                    //profilePage: ProfilePage(),
                    recordVolunteeringPage: RecordVolunteeringPage(),
                    leaderboardPage: LeaderboardPage(isTeamStat: true), mainNavigatorKey: widget.mainNavigatorKey, logInNavigatorKey: widget.logInNavigatorKey,
                  )));
        },
        child: Container(
          width: 324,
          padding: const EdgeInsets.only(top: 20, left: 10, right: 10, bottom: 10),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(30.0),
            boxShadow: [
              BoxShadow(
                color: Colors.grey.withOpacity(0.2),
                spreadRadius: 10,
                blurRadius: 15,
                offset: const Offset(0, 3),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                '  Top 3 Individuals',
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 10),
              areLeaderboardStatsLoading
                  ? CircularProgressIndicator()
                  : Column(
                      mainAxisAlignment: MainAxisAlignment.start,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: individualLeaderboardStatistics.take(3).toList().asMap().entries.map((entry) {
                        int index = entry.key + 1;
                        LeaderboardStatistic individual = entry.value;
                        return ListTile(
                          leading: CircleAvatar(
                            backgroundImage: NetworkImage(individual.profilePhotoURL),
                          ),
                          title: Text(
                            '${index.toString()}${_getRankSuffix(index)} - ${individual.name}',
                            style: const TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          subtitle: Text('${individual.numHours} hours'),
                        );
                      }).toList(),
                    ),
            ],
          ),
        ));
  }

  Widget buildYourTeamsRank(BuildContext context) {
    return GestureDetector(
        onTap: () {
          Navigator.of(context).push(MaterialPageRoute(
              builder: (context) => NavBarManager(
                    initialIndex: 1,
                    searchVolunteeringPage: SearchVolunteeringPage(),
                    feedPage: widget,
                    //profilePage: ProfilePage(),
                    recordVolunteeringPage: RecordVolunteeringPage(),
                    leaderboardPage: LeaderboardPage(isTeamStat: true),mainNavigatorKey: widget.mainNavigatorKey, logInNavigatorKey: widget.logInNavigatorKey,
                  )));
        },
        child: Container(
          width: 149.5,
          height: 180,
          padding: const EdgeInsets.only(top: 20, left: 20, right: 20, bottom: 20),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(30.0),
            boxShadow: [
              BoxShadow(
                color: Colors.grey.withOpacity(0.2),
                spreadRadius: 10,
                blurRadius: 15,
                offset: const Offset(0, 3),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                "Your team's rank",
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 15),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  isYourTeamsRankLoading ? const CircularProgressIndicator() : _buildStat(_yourTeamsRank, 'Overall'),
                ],
              ),
            ],
          ),
        ));
  }

  Widget buildRecentProfileBadge(BuildContext context) {
    return GestureDetector(
        onTap: () {
          Navigator.of(context).push(MaterialPageRoute(
              builder: (context) => NavBarManager( // todo dont make here.
                    initialIndex: 4,
                    searchVolunteeringPage: SearchVolunteeringPage(),
                    feedPage: widget,
                    //profilePage: ProfilePage(),
                    recordVolunteeringPage: RecordVolunteeringPage(),
                    leaderboardPage: LeaderboardPage(isTeamStat: true),mainNavigatorKey: widget.mainNavigatorKey, logInNavigatorKey: widget.logInNavigatorKey,
                  )));
        },
        child: Container(
          width: 149.5,
          height: 180,
          alignment: Alignment.center,
          padding: const EdgeInsets.only(top: 20, left: 20, right: 20, bottom: 20),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(30.0),
            boxShadow: [
              BoxShadow(
                color: Colors.grey.withOpacity(0.2),
                spreadRadius: 10,
                blurRadius: 15,
                offset: const Offset(0, 3),
              ),
            ],
          ),
          child: Column(children: [
            const Text(
              'Latest badge',
              style: TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 10),
            _areHoursLoading
                ? const CircularProgressIndicator()
                : (_mostRecentBadge == 0)
                    ? Image.asset(
                        'assets/images/badges/locked.png',
                        height: 90,
                        width: 98,
                      )
                    : Image.asset(
                        'assets/images/badges/' + _mostRecentBadge.toString() + '_hours.png',
                        height: 90,
                        width: 98,
                      ),
          ]),
        ));
  }

  Widget buildUpcomingVolunteering(BuildContext context) {
    List<Widget> getWidgets() {
      List<Widget> cards = [];

      for (var event in upcomingVolunteeringEvents) {
        var widget = Container(
          height: 110,
          padding: const EdgeInsets.all(10.0),
          margin: EdgeInsets.only(left: 20),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(30.0),
            color: Colors.white,
            boxShadow: [
              BoxShadow(
                color: Colors.grey.withOpacity(0.1),
                spreadRadius: 10,
                blurRadius: 15,
                offset: const Offset(0, 3),
              ),
            ],
          ),
          child: Stack(
            clipBehavior: Clip.none,
            children: [
              Positioned(
                left: -30,
                child: Container(
                  decoration: BoxDecoration(
                    boxShadow: [
                      BoxShadow(
                        color: Colors.grey.withOpacity(0.15),
                        spreadRadius: 10,
                        blurRadius: 15,
                        offset: const Offset(0, 3),
                      ),
                    ],
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(15),
                    child: Image.network(
                      event.photoUrls[0],
                      width: 90,
                      height: 90,
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
              ),
              InkWell(
                onTap: () {
                  Navigator.of(context).push(MaterialPageRoute(
                    builder: (context) => VolunteeringEventDetailsPage(volunteeringEvent: event),
                  ));
                },
                child: Row(
                  children: [
                    SizedBox(width: 75),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Container(
                            constraints: BoxConstraints(maxWidth: 180),
                            child: Text(
                              event.name,
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: Colors.black,
                              ),
                              overflow: TextOverflow.ellipsis,
                              maxLines: 1,
                            ),
                          ),
                          Row(
                            children: [
                              Icon(Icons.location_on_rounded, color: Colors.grey.shade500, size: 15),
                              SizedBox(width: 5),
                              Container(
                                constraints: BoxConstraints(maxWidth: 160),
                                child: Text(
                                  event.location,
                                  style: TextStyle(
                                    fontWeight: FontWeight.normal,
                                    color: Colors.grey.shade500,
                                  ),
                                  overflow: TextOverflow.ellipsis,
                                  maxLines: 1,
                                ),
                              ),
                            ],
                          ),
                          SizedBox(height: 4),
                          Text(
                            "${DateFormat('dd/MM/yy').format(event.date)}",
                            style: TextStyle(
                              fontWeight: FontWeight.normal,
                              color: Colors.grey.shade500,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
        cards.add(widget);
        cards.add(SizedBox(height: 20));
      }
      if (cards.isEmpty) cards.add(SizedBox(height: 10));
      return cards;
    }

    return Container(
      padding: const EdgeInsets.only(top: 10, left: 10, right: 10, bottom: 0),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(30.0),
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            spreadRadius: 10,
            blurRadius: 15,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Padding(
            padding: const EdgeInsets.only(top: 5, left: 5, right: 10, bottom: 5),
            child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
              const Text(
                " Upcoming events",
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w700,
                ),
              ),
              Text(upcomingVolunteeringEvents.length.toString(),
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                    color: Colors.grey.shade600,
                  )),
            ])),
        areVolunteeringEventsLoading ? const CircularProgressIndicator() : Column(children: getWidgets())
      ]),
    );
  }

  Future<bool> hasUnreadChats() async {
    try {
      final String currentUserId = FirebaseAuth.instance.currentUser!.uid;

      final chatQuerySnapshot = await FirebaseFirestore.instance.collection('chats').where('users', arrayContains: currentUserId).get();

      for (final chatDoc in chatQuerySnapshot.docs) {
        final usersCollectionRef = chatDoc.reference.collection('users');

        final userDocSnapshot = await usersCollectionRef.where('user', isEqualTo: currentUserId).get();

        final bool isRead = userDocSnapshot.docs.isNotEmpty && userDocSnapshot.docs.first['read'];

        if (!isRead) {
          return true;
        }
      }

      return false;
    } catch (e) {
      //print('Error while checking unread chats: $e');
      return false;
    }
  }
}
