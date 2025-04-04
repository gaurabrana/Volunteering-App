import 'package:HeartOfExperian/DataAccessLayer/VolunteeringHistoryDAO.dart';
import 'package:HeartOfExperian/Models/LeaderboardStatistic.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

import 'ColleagueProfile.dart';
import 'CustomWidgets/VolunteeringStatCard.dart';
import 'Feed.dart';
import 'NavBarManager.dart';
import 'Profile.dart';
import 'RecordVolunteering.dart';
import 'SearchVolunteering.dart';
import 'Team.dart';

class LeaderboardPage extends StatefulWidget {
  final bool isTeamStat;

  const LeaderboardPage({Key? key, required this.isTeamStat}) : super(key: key);

  @override
  State<StatefulWidget> createState() => LeaderboardPageState();
}

class LeaderboardPageState extends State<LeaderboardPage> {
  late List<LeaderboardStatistic> individualLeaderboardStatistics;
  late List<LeaderboardStatistic> teamLeaderboardStatistics;
  bool areLeaderboardStatisticsLoading = true;
  DateTime startDate = DateTime(DateTime.now().year - 1);
  DateTime endDate = DateTime.now();
  late bool isTeamStats;
  int timeframeIndex = 0;
  int volunteeringTypesIndex = 0;
  List<String> timeFrames = ["Year", "Month", "All time"];
  List<String> volunteeringTypes = VolunteeringHistoryDAO.volunteeringTypesWithOther;

  @override
  void initState() {
    super.initState();
    setState(() {
      isTeamStats = widget.isTeamStat;
    });
    fetchData();
  }

  void initialiseData() {
    setState(() {
      volunteeringTypes[0] = "Any";
      areLeaderboardStatisticsLoading = true;
      individualLeaderboardStatistics = [];
      teamLeaderboardStatistics = [];
      setStartDate();
    });
  }

  void setStartDate() {
    setState(() {
      if (timeframeIndex == 0) {
        startDate = DateTime(DateTime.now().year - 1);
      } else if (timeframeIndex == 1) {
        startDate = DateTime(DateTime.now().year, DateTime.now().month - 1);
      } else {
        startDate = DateTime(DateTime.now().year - 6);
      }
    });
    setState(() {
      areLeaderboardStatisticsLoading = true;
    });
  }

  void setVolunteeringTypes() {
    setState(() {
      areLeaderboardStatisticsLoading = true;
    });
    fetchData();
  }

  Future<void> fetchData() async {
    initialiseData();
    try {
      List<LeaderboardStatistic> individualStats =
          await VolunteeringHistoryDAO.getLeaderboardStatistics(startDate, endDate, volunteeringTypes[volunteeringTypesIndex]);
      List<LeaderboardStatistic> teamStats =
          await VolunteeringHistoryDAO.getTeamLeaderboardStatistics(startDate, endDate, volunteeringTypes[volunteeringTypesIndex]);
      setState(() {
        individualLeaderboardStatistics = individualStats;
        teamLeaderboardStatistics = teamStats;
        areLeaderboardStatisticsLoading = false;
      });
    } catch (error) {
      //print('Error fetching data: $error');
    }
  }

// todo your rank at the top in pruple
  @override
  Widget build(BuildContext context) {
    return RefreshIndicator(
        onRefresh: fetchData,
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          child: Padding(
            padding: const EdgeInsets.only(top: 40, left: 20, right: 20, bottom: 20),
            child: Column(
              children: [
                Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                  const SizedBox(width: 40),
                  const Text(
                    'Leaderboard',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 30,
                      decorationColor: Colors.black,
                    ),
                  ),
                  buildFilterButton(context),
                ]),
                const SizedBox(height: 10),
                _buildLeaderboardToggle(context, Colors.grey[200]!),
                const SizedBox(height: 15),
                areLeaderboardStatisticsLoading
                    ? const CircularProgressIndicator()
                    : _buildTopThreeUsers(), // todo only display is there is > 3 people, or if none only display those?
                const SizedBox(height: 16),
                areLeaderboardStatisticsLoading
                    ? const CircularProgressIndicator()
                    : Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: !isTeamStats
                            ? individualLeaderboardStatistics.asMap().entries.where((entry) => entry.key >= 3).map((entry) {
                                final userData = entry.value;
                                return UserVolunteeringStatCard(
                                  id: userData.ID,
                                  name: userData.name,
                                  profilePhotoURL: userData.profilePhotoURL,
                                  hours: userData.numHours,
                                  rank: userData.rank,
                                  isTeamStat: isTeamStats,
                                  isCurrentUser: (FirebaseAuth.instance.currentUser?.uid == userData.ID),
                                );
                              }).toList()
                            : teamLeaderboardStatistics.asMap().entries.where((entry) => entry.key >= 3).map((entry) {
                                final teamData = entry.value;
                                return UserVolunteeringStatCard(
                                  id: teamData.ID,
                                  name: teamData.name,
                                  profilePhotoURL: teamData.profilePhotoURL,
                                  hours: teamData.numHours,
                                  rank: teamData.rank,
                                  isTeamStat: isTeamStats,
                                  isCurrentUser: (FirebaseAuth.instance.currentUser?.uid == teamData.ID),
                                );
                              }).toList(),
                      ),
              ],
            ),
          ),
        ));
  }

  Widget _buildTopThreeUsers() {
    List<Widget> topThreeWidgets = [];

    for (int i in [2, 0, 1]) {
      final LeaderboardStatistic statisticData = isTeamStats ? teamLeaderboardStatistics[i] : individualLeaderboardStatistics[i];

      Color crownColor;
      switch (i) {
        case 0:
          crownColor = Colors.yellow.shade600;
          break;
        case 1:
          crownColor = Colors.grey;
          break;
        case 2:
          crownColor = const Color(0xFFCD7F32);
          break;
        default:
          crownColor = Colors.black;
      }

      topThreeWidgets.add(Expanded(
        child: Column(
          children: [
            FaIcon(FontAwesomeIcons.crown, color: crownColor, size: 17),
            const SizedBox(height: 8),
            Stack(
              alignment: Alignment.bottomRight,
              children: [
                InkWell(
                  onTap: () {
                    if (isTeamStats) {
                      Navigator.of(context).push(MaterialPageRoute(
                        builder: (context) => TeamPage(
                          teamId: statisticData.ID,
                        ),
                      ));
                    } else {
                      Navigator.of(context).push(MaterialPageRoute(
                        builder: (context) => ColleagueProfilePage(
                            UID: statisticData.ID),
                      ));
                    }
                  },
                  child: CircleAvatar(
                    radius: (i == 0) ? 50 : 40,
                    backgroundColor: crownColor,
                    child: CircleAvatar(
                      radius: (i == 0) ? 45 : 35,
                      backgroundColor: Colors.white,
                      backgroundImage: NetworkImage(statisticData.profilePhotoURL),
                    ),
                  ),
                ),
                Positioned(
                  bottom: (i == 0) ? 1 : 0,
                  child: Container(
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: crownColor,
                      ),
                      padding: EdgeInsets.all((i == 0) ? 8 : 5),
                      child: Text(
                        '${i + 1}',
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      )),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              statisticData.name,
              style: const TextStyle(fontWeight: FontWeight.bold),
              textAlign: TextAlign.center,
              overflow: TextOverflow.ellipsis,
              maxLines: 2,
            ),
            Text(
              '${statisticData.numHours} hours',
              style: const TextStyle(color: Colors.grey),
            ),
          ],
        ),
      ));
    }

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: topThreeWidgets,
    );
  }

  Widget _buildLeaderboardToggle(BuildContext context, Color backgroundColor) {
    return Container(
      height: 35,
      width: 250,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        color: backgroundColor,
      ),
      child: Row(
        children: [
          Expanded(
            child: InkWell(
              onTap: () {
                setState(() {
                  isTeamStats = !isTeamStats;
                });
              },
              child: Container(
                decoration: BoxDecoration(
                  gradient: isTeamStats
                      ? const LinearGradient(
                          colors: [Color(0xFF4136F1), Color(0xFF8643FF)],
                          begin: Alignment.centerLeft,
                          end: Alignment.centerRight,
                        )
                      : null,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Center(
                  child: Text(
                    'Team',
                    style: TextStyle(
                      color: !isTeamStats ? Colors.grey[700] : Colors.white,
                    ),
                  ),
                ),
              ),
            ),
          ),
          Expanded(
            child: InkWell(
              onTap: () {
                setState(() {
                  isTeamStats = !isTeamStats;
                });
              },
              child: Container(
                decoration: BoxDecoration(
                  gradient: !isTeamStats
                      ? const LinearGradient(
                          colors: [Color(0xFF4136F1), Color(0xFF8643FF)],
                          begin: Alignment.centerLeft,
                          end: Alignment.centerRight,
                        )
                      : null,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Center(
                  child: Text(
                    'Individual',
                    style: TextStyle(
                      color: isTeamStats ? Colors.grey[700] : Colors.white,
                    ),
                  ),
                ),
              ),
            ),
          )
        ],
      ),
    );
  }

  Widget buildFilterButton(BuildContext context) {
    return Align(
      alignment: Alignment.centerRight,
      child: Container(
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
              _showFilterPopup(context);
            },
            icon: const FaIcon(FontAwesomeIcons.sliders, color: Colors.white, size: 25), //todo adjust thickness
            color: Color(0xFF4136F1),
          ),
        ),
      ),
    );
  }

  void _showFilterPopup(BuildContext context) {
    List<Widget> timeframeButtons = [];
    List<Widget> volunteeringTypeButtons = [];

    for (int i = 0; i < timeFrames.length; i++) {
      timeframeButtons.add(TextButton(
        onPressed: () {
          setState(() {
            timeframeIndex = i;
            setStartDate();
          });
        },
        style: ButtonStyle(
          backgroundColor: MaterialStateProperty.resolveWith<Color>((Set<MaterialState> states) {
            return Colors.white;
          }),
          textStyle: MaterialStateProperty.resolveWith<TextStyle>((Set<MaterialState> states) {
            return timeframeIndex == i
                ? const TextStyle(color: Colors.black, fontWeight: FontWeight.bold)
                : TextStyle(color: Colors.grey.shade600); // Set the text color and style based on selection
          }),
          side: MaterialStateProperty.resolveWith<BorderSide>((Set<MaterialState> states) {
            return timeframeIndex == i
                ? const BorderSide(color: Colors.purple, width: 2.0)
                : const BorderSide(color: Colors.grey, width: 1.0); // Set the border color and width based on selection
          }),
          shape: MaterialStateProperty.all<RoundedRectangleBorder>(
            RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20.0), // Set the border radius
            ),
          ),
        ),
        child: Text(
          timeFrames[i],
          style: timeframeIndex == i
              ? const TextStyle(color: Colors.black, fontWeight: FontWeight.bold, fontFamily: 'Poppins')
              : TextStyle(color: Colors.grey.shade600, fontFamily: 'Poppins'),
        ),
      ));
    }
    ;

    for (int i = 0; i < volunteeringTypes.length; i++) {
      volunteeringTypeButtons.add(TextButton(
        onPressed: () {
          setState(() {
            volunteeringTypesIndex = i; // todo allow to select > 1
            setVolunteeringTypes();
          });
        },
        style: ButtonStyle(
          backgroundColor: MaterialStateProperty.resolveWith<Color>((Set<MaterialState> states) {
            return Colors.white;
          }),
          textStyle: MaterialStateProperty.resolveWith<TextStyle>((Set<MaterialState> states) {
            return volunteeringTypesIndex == i
                ? const TextStyle(color: Colors.black, fontWeight: FontWeight.bold)
                : TextStyle(color: Colors.grey.shade600); // Set the text color and style based on selection
          }),
          side: MaterialStateProperty.resolveWith<BorderSide>((Set<MaterialState> states) {
            return volunteeringTypesIndex == i
                ? const BorderSide(color: Colors.purple, width: 2.0)
                : const BorderSide(color: Colors.grey, width: 1.0); // Set the border color and width based on selection
          }),
          shape: MaterialStateProperty.all<RoundedRectangleBorder>(
            RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20.0), // Set the border radius
            ),
          ),
        ),
        child: Text(
          volunteeringTypes[i],
          style: volunteeringTypesIndex == i
              ? const TextStyle(color: Colors.black, fontWeight: FontWeight.bold, fontFamily: 'Poppins')
              : TextStyle(color: Colors.grey.shade600, fontFamily: 'Poppins'),
        ),
      ));
    }
    ;

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text(
            'Filter',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontWeight: FontWeight.w700,
              fontSize: 25,
              decorationColor: Colors.black,
            ),
          ),
          content: Column(crossAxisAlignment: CrossAxisAlignment.start, mainAxisSize: MainAxisSize.min, children: [
            _buildLeaderboardToggle(context, Colors.white),
            SizedBox(height: 15),
            const Text(
              'Timeframe',
              textAlign: TextAlign.left,
              style: TextStyle(
                fontWeight: FontWeight.w700,
                fontSize: 15,
                decorationColor: Colors.black,
              ),
            ),
            SizedBox(height: 10),
            Wrap(
              spacing: 10.0, // spacing between buttons
              runSpacing: 2.0, // spacing between rows
              children: timeframeButtons,
            ),
            const Text(
              'Types',
              textAlign: TextAlign.left,
              style: TextStyle(
                fontWeight: FontWeight.w700,
                fontSize: 15,
                decorationColor: Colors.black,
              ),
            ),
            SizedBox(height: 10),
            Wrap(
              spacing: 10.0, // spacing between buttons
              runSpacing: 2.0, // spacing between rows
              children: volunteeringTypeButtons,
            )
          ]),
          actions: <Widget>[
            Container(
                alignment: Alignment.center,
                height: 60,
                width: 500,
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
                    child: Column(mainAxisAlignment: MainAxisAlignment.center, crossAxisAlignment: CrossAxisAlignment.center, children: [
                  TextButton(
                      onPressed: () async {
                        Navigator.of(context).pop();
                      },
                      child: Container(
                        height: 40,
                        width: 310,
                        alignment: Alignment.center,
                        child: const Text("Save",
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontWeight: FontWeight.w600,
                              fontSize: 20,
                              color: Colors.white,
                            )), // todo could i have a cool animation here
                      )),
                ])))
          ],
        );
      },
    );
  }
}

//todo your rank summarised at top and when you click it scrolls you down to your place in the list
//todo not connected to wifi erro msg
// todo seems to load forever when you filter.
// todo tutorial when you first download app.
