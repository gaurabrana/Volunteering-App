import 'package:HeartOfExperian/DataAccessLayer/VolunteeringEventRegistrationsDAO.dart';
import 'package:HeartOfExperian/Pages/CustomWidgets/VolunteeringTypePieChart.dart';
import 'package:HeartOfExperian/Pages/Settings/Settings.dart';
import 'package:HeartOfExperian/Pages/Team.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:intl/intl.dart';

import '../DataAccessLayer/FollowingDAO.dart';
import '../DataAccessLayer/PhotoDAO.dart';
import '../DataAccessLayer/TeamDAO.dart';
import '../DataAccessLayer/UserDAO.dart';
import '../DataAccessLayer/VolunteeringEventDAO.dart';
import '../DataAccessLayer/VolunteeringHistoryDAO.dart';
import '../Models/UserDetails.dart';
import '../Models/VolunteeringEvent.dart';
import '../Models/VolunteeringHistory.dart';
import 'CustomWidgets/VolunteeringGraph.dart';
import 'Feed.dart';
import 'Following.dart';
import 'Leaderboard.dart';
import 'NavBarManager.dart';
import 'RecordVolunteering.dart';
import 'SearchVolunteering.dart';
import 'VolunteeringEventDetails.dart';

class ProfilePage extends StatefulWidget {
  final GlobalKey<NavigatorState> mainNavigatorKey;
  final GlobalKey<NavigatorState> loginNavigatorKey;

  const ProfilePage({super.key, required this.loginNavigatorKey, required this.mainNavigatorKey});

  @override
  State<StatefulWidget> createState() => ProfilePageState();
}

class ProfilePageState extends State<ProfilePage> {
  late bool isPhotoLoading;
  late bool isNameLoading;
  late bool areUserDetailsLoading;
  bool areFollowingLoading = true;
  late bool areHistoricalHoursDetailsLoading;
  bool areVolunteeringEventsLoading = true;

  late UserDetails _userDetails;
  late String _photoURL;
  late int following;
  late String _teamName;

  late int _hoursThisMonth;
  late int _hoursThisYear;
  late int _hoursAllTime;

  late bool isVolunteeringHistoryLoading;
  late List<VolunteeringHistory> _volunteeringHistory;

  TextEditingController financialYearTextEditingController = new TextEditingController();
  int _financialYearShownOnGraph = 24;
  int selectedYearIndex = 0;

  bool _5_hour_badge_earned = false;
  bool _10_hour_badge_earned = false;
  bool _15_hour_badge_earned = false;
  bool _30_hour_badge_earned = false;
  bool _50_hour_badge_earned = false;
  bool _100_hour_badge_earned = false;

  late List<VolunteeringEvent> upcomingVolunteeringEvents = [];
  late List<VolunteeringEvent> completedVolunteeringEvents = [];

  @override
  void initState() {
    super.initState();
    _fetchData();
  }

  _initialiseData() {
    setState(() {
      _photoURL = "";
      isPhotoLoading = true;
      isNameLoading = true;
      areUserDetailsLoading = true;
      _hoursThisMonth = 0;
      _hoursThisYear = 0;
      _hoursAllTime = 0;
      areHistoricalHoursDetailsLoading = true;
      isVolunteeringHistoryLoading = true;
      _volunteeringHistory = [];
      _financialYearShownOnGraph = 24;
      _5_hour_badge_earned = false;
      _10_hour_badge_earned = false;
      _15_hour_badge_earned = false;
      _30_hour_badge_earned = false;
      _50_hour_badge_earned = false;
      _100_hour_badge_earned = false;
      following = 0;
      upcomingVolunteeringEvents = [];
      completedVolunteeringEvents = [];
      areVolunteeringEventsLoading = true;
      selectedYearIndex = 0;
      _teamName = "";
      areFollowingLoading = true;
    });
  }

  Future<void> _fetchData() async {
    _initialiseData();

    await _fetchProfilePhoto();
    await _fetchUserDetails();
    await _fetchHistoricalHours();
    await _fetchAllVolunteeringHistory();
    await _fetchNumberFollowing();
    await _fetchVolunteeringEvents();
  }

  Future<void> _fetchNumberFollowing() async {
    int num = await FollowingDAO.getNumberFollowing(FirebaseAuth.instance.currentUser!.uid);
    setState(() {
      following = num;
      areFollowingLoading = false;
    });
  }

  Future<void> _fetchProfilePhoto() async {
    FirebaseAuth auth = FirebaseAuth.instance;
    User? user = auth.currentUser;

    try {
      String photoURL = await PhotoDAO.getUserProfilePhotoUrlFromFirestore(user?.uid);
      setState(() {
        _photoURL = photoURL;
        isPhotoLoading = false;
      });
    } catch (e) {
      //print('Error fetching photo: $e');
    }
  }

  Future<void> _fetchUserDetails() async {
    try {
      FirebaseAuth auth = FirebaseAuth.instance;
      User? user = auth.currentUser;
      UserDetails? userDetails = await UserDAO.getUserDetails(user?.uid);
      String? teamName = await TeamDAO.getTeamName(userDetails!.team!);
      setState(() {
        _userDetails = userDetails!;
        _teamName = teamName!;
        areUserDetailsLoading = false;
      });
    } catch (e) {
      //print('Error fetching user details: $e');
    }
  }

  Future<void> _fetchHistoricalHours() async {
    try {
      FirebaseAuth auth = FirebaseAuth.instance;
      User? user = auth.currentUser;

      int monthHours = await VolunteeringHistoryDAO.getUsersVolunteeringHoursOfPastMonth(user?.uid, "Any");
      int yearHours = await VolunteeringHistoryDAO.getUsersVolunteeringHoursThisFinancialYear(user?.uid, "Any");
      int allTimeHours = await VolunteeringHistoryDAO.getUsersAllTimeVolunteeringHours(user?.uid);
      setState(() {
        _hoursThisMonth = monthHours;
        _hoursThisYear = yearHours;
        _hoursAllTime = allTimeHours;
        areHistoricalHoursDetailsLoading =
            false; //todo have a cool animation to show it flicking thorugh to find the numbers rather than the loading symbol
      });
    } catch (e) {
      //print('Error fetching user details: $e');
    }
  }

  Future<void> _fetchAllVolunteeringHistory() async {
    try {
      FirebaseAuth auth = FirebaseAuth.instance;
      User? user = auth.currentUser;

      List<VolunteeringHistory>? volunteeringHistory = await VolunteeringHistoryDAO.getAllUsersVolunteeringHistory(user?.uid);
      setState(() {
        if (volunteeringHistory != null) {
          _volunteeringHistory = volunteeringHistory;
        }
        _5_hour_badge_earned = _hoursAllTime > 5;
        _10_hour_badge_earned = _hoursAllTime > 10;
        _15_hour_badge_earned = _hoursAllTime > 15;
        _30_hour_badge_earned = _hoursAllTime > 30;
        _50_hour_badge_earned = _hoursAllTime > 50;
        _100_hour_badge_earned = _hoursAllTime > 100;
        isVolunteeringHistoryLoading = false;
      });
    } catch (e) {
      //print('Error fetching user details: $e');
    }
  }

  Future<void> _fetchVolunteeringEvents() async {
    try {
      List<VolunteeringEvent> upcomingVolunteering = [];
      List<VolunteeringEvent> completedVolunteering = [];

      List<String> allEventIds = await VolunteeringEventRegistrationsDAO.getAllEventIdsForUser(FirebaseAuth.instance.currentUser!.uid);

      for (var eventId in allEventIds) {
        VolunteeringEvent? event = await VolunteeringEventDAO.getVolunteeringEvent(eventId);

        if (event!.date.isAfter(DateTime.now())) {
          upcomingVolunteering.add(event!);
        } else {
          completedVolunteering.add(event!);
        }
      }

      setState(() {
        if (upcomingVolunteeringEvents != null) {
          upcomingVolunteeringEvents.addAll(upcomingVolunteering!);
        }
        if (completedVolunteeringEvents != null) {
          completedVolunteeringEvents.addAll(completedVolunteering!);
        }
        areVolunteeringEventsLoading = false;
      });
    } catch (e) {
      //print('Error fetching events: $e');
    }
  }

  @override
  Widget build(context) {
    return Scaffold(body:RefreshIndicator(
        onRefresh: _fetchData,
        child: SingleChildScrollView(
            child: Padding(
          padding: const EdgeInsets.only(top: 40, left: 30, right: 30, bottom: 20),
          child: Column(
            children: [
              buildSettingsButton(context),
              buildProfilePhoto(context),
              const SizedBox(height: 20),
              buildProfileName(context),
              buildTeamButton(context),
              buildFollowingButton(context),
              const SizedBox(height: 10),
              buildHistoricalHoursSection(context),
              const SizedBox(height: 25),
              buildProfileBadges(context),
              const SizedBox(height: 25),
              buildVolunteeringGraph(context),
              const SizedBox(height: 25),
              buildUpcomingVolunteering(context),
              const SizedBox(height: 25),
              buildCompletedVolunteering(context),
              const SizedBox(height: 25),
              buildVolunteeringTypePieChart(context),
            ],
          ),
        ))));
  }

  Widget buildSettingsButton(BuildContext context) {
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
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (context) => SettingsPage(mainNavigatorKey: widget.mainNavigatorKey, logInNavigatorKey: widget.loginNavigatorKey,),
                ),
              );
            },
            icon: const Icon(
              Icons.settings_outlined,
              color: Colors.white,
              size: 30,
            ),
            color: Color(0xFF4136F1),
            iconSize: 50,
          ),
        ),
      ),
    );
  }

  Widget buildProfilePhoto(BuildContext context) {
    return Container(
      child: isPhotoLoading
          ? const CircularProgressIndicator()
          : ClipRRect(
              borderRadius: BorderRadius.circular(20),
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.grey.withOpacity(0.5),
                      spreadRadius: 5,
                      blurRadius: 7,
                      offset: const Offset(0, 3),
                    ),
                  ],
                ),
                child: _photoURL.isNotEmpty
                    ? Image.network(
                        _photoURL,
                        width: 150,
                        height: 150,
                        fit: BoxFit.cover,
                        loadingBuilder: (BuildContext context, Widget child, ImageChunkEvent? loadingProgress) {
                          if (loadingProgress == null) {
                            // Image has finished loading
                            return child;
                          } else {
                            // Image is still loading
                            return const CircularProgressIndicator();
                          }
                        },
                        errorBuilder: (BuildContext context, Object exception, StackTrace? stackTrace) {
                          return const Text('Failed to load image');
                        },
                      )
                    : const SizedBox(), // Placeholder when photo URL is empty
              ),
            ),
    );
  }

  Widget buildProfileName(BuildContext context) {
    return Container(
      child: areUserDetailsLoading
          ? const CircularProgressIndicator()
          : Text(
              _userDetails.forename + " " + _userDetails.surname,
              textAlign: TextAlign.left,
              style: const TextStyle(
                fontWeight: FontWeight.w700,
                fontSize: 27,
                decorationColor: Colors.black,
              ),
            ),
    );
  }

  Widget buildTeamButton(BuildContext context) {
    return TextButton(
        onPressed: () async {
          Navigator.of(context).push(
            MaterialPageRoute(builder: (context) => TeamPage(teamId: _userDetails.team)),
          );
        },
        child: areUserDetailsLoading
            ? const CircularProgressIndicator()
            : Text(_teamName,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 20,
                  decorationColor: Colors.black,
                )));
  } //todo make this button prettier

  Widget buildFollowingButton(BuildContext context) {
    return TextButton(
      onPressed: () {
        Navigator.of(context).push(
          MaterialPageRoute(
              builder: (context) => FollowingPage()),
        );
      },
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            'Following ',
            style: TextStyle(fontSize: 16, color: Colors.black),
          ),
          areFollowingLoading
              ? CircularProgressIndicator()
              : Text(
                  following.toString(),
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Colors.black),
                ),
        ],
      ),
    );
  }

  Widget buildHistoricalHoursSection(BuildContext context) {
    return areHistoricalHoursDetailsLoading
        ? const CircularProgressIndicator()
        : Container(
            alignment: Alignment.center,
            padding: const EdgeInsets.all(12.0),
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
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _buildStat(_hoursThisMonth, 'This month'),
                _buildStat(_hoursThisYear, 'This year'),
                _buildStat(_hoursAllTime, 'All time'),
              ],
            ),
          );
  }

  Widget _buildStat(int hours, String label) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          '$hours',
          style: const TextStyle(
            fontSize: 33,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 2),
        const Text(
          'hours',
          style: TextStyle(
            fontSize: 16,
          ),
        ),
      ],
    );
  }

  Widget buildVolunteeringGraph(BuildContext context) {
    return isVolunteeringHistoryLoading
        ? const CircularProgressIndicator()
        : Container(
            alignment: Alignment.center,
            padding: const EdgeInsets.all(10.0),
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
              Container(
                  padding: const EdgeInsets.only(
                    top: 10,
                    left: 10,
                    right: 10,
                  ),
                  child: Row(children: [
                    Text(
                      "FY$_financialYearShownOnGraph",
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const Spacer(),
                    buildFilterButton(context),
                  ])),
              YearVolunteeringHistoryLineGraph(
                volunteeringHistory: _volunteeringHistory,
                financialYear: _financialYearShownOnGraph,
              ),
            ]));
  }

  Widget buildVolunteeringTypePieChart(BuildContext context) {
    List<VolunteeringEvent> allEvents = [];
    if (!areVolunteeringEventsLoading) {
      allEvents.addAll(completedVolunteeringEvents);
      allEvents.addAll(upcomingVolunteeringEvents);
    }

    return areVolunteeringEventsLoading
        ? const CircularProgressIndicator()
        : (completedVolunteeringEvents.isNotEmpty || upcomingVolunteeringEvents.isNotEmpty)
            ? Container(
                alignment: Alignment.center,
                padding: const EdgeInsets.only(top: 5, left: 25, right: 20, bottom: 10),
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
                child: VolunteeringTypePieChart(
                  volunteeringEvents: allEvents,
                ))
            : Container();
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
              _showFilterPopup();
            },
            icon: const FaIcon(FontAwesomeIcons.sliders, color: Colors.white, size: 25), //todo adjust thickness
            color: Color(0xFF4136F1),
          ),
        ),
      ),
    );
  }

  void _showFilterPopup() {
    List<int> recentFYs = getRecentFinancialYears();
    List<Widget> widgets = [];

    for (int i = 0; i < recentFYs.length; i++) {
      widgets.add(TextButton(
        onPressed: () {
          setState(() {
            selectedYearIndex = i;
            _financialYearShownOnGraph = recentFYs[selectedYearIndex];
            financialYearTextEditingController.text = _financialYearShownOnGraph.toString();
          });
        },
        style: ButtonStyle(
          backgroundColor: MaterialStateProperty.resolveWith<Color>((Set<MaterialState> states) {
            return Colors.white;
          }),
          textStyle: MaterialStateProperty.resolveWith<TextStyle>((Set<MaterialState> states) {
            return selectedYearIndex == i // todo the old button style is not changing back
                ? TextStyle(color: Colors.black, fontWeight: FontWeight.bold)
                : TextStyle(color: Colors.grey.shade600, fontWeight: FontWeight.normal);
          }),
          side: MaterialStateProperty.resolveWith<BorderSide>((Set<MaterialState> states) {
            return selectedYearIndex == i ? BorderSide(color: Colors.purple, width: 2.0) : BorderSide(color: Colors.grey, width: 1.0);
          }),
          shape: MaterialStateProperty.all<RoundedRectangleBorder>(
            RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20.0),
            ),
          ),
        ),
        child: Text(
          "FY${recentFYs[i]}",
          style: selectedYearIndex == i
              ? const TextStyle(color: Colors.black, fontWeight: FontWeight.bold, fontFamily: 'Poppins')
              : TextStyle(color: Colors.grey.shade600, fontFamily: 'Poppins'),
        ),
      ));
    }
    ;

    showDialog(
      context: context,
      builder: (BuildContext context) {
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
            const Text(
              'Financial Year',
              textAlign: TextAlign.left,
              style: TextStyle(
                fontWeight: FontWeight.w700,
                fontSize: 17,
                decorationColor: Colors.black,
              ),
            ),
            Wrap(
              spacing: 10.0, // spacing between buttons
              runSpacing: 1.0, // spacing between rows
              children: widgets,
            )
          ]),
          actions: <Widget>[
            // todo company averages.!!!
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
                        int newFinancialYear = int.tryParse(financialYearTextEditingController.text) ?? 24;
                        setState(() {
                          _financialYearShownOnGraph = newFinancialYear;
                        });
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
                            )),
                      )),
                ])))
          ],
        );
      },
    );
  }

  List<int> getRecentFinancialYears() {
    int currentYear = DateTime.now().year;
    int currentMonth = DateTime.now().month;
    int currentFY;
    List<int> recentYears = [];

    if (currentMonth >= 4) {
      currentFY = currentYear + 1;
    } else {
      currentFY = currentYear;
    }

    for (int i = 0; i <= 5; i++) {
      recentYears.add((currentFY - i) % 100);
    }

    return recentYears;
  }

  Widget buildProfileBadges(BuildContext context) {
    return isVolunteeringHistoryLoading
        ? const CircularProgressIndicator()
        : Container(
            alignment: Alignment.center,
            padding: const EdgeInsets.only(top: 20, left: 0, right: 0, bottom: 20),
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
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    if (_5_hour_badge_earned)
                      GestureDetector(
                        onTap: () {
                          showCongratulationDialog(context, 5, 'assets/images/badges/5_hours.png');
                        },
                        child: Image.asset(
                          'assets/images/badges/5_hours.png',
                          height: 100,
                          width: 98,
                        ),
                      )
                    else
                      Image.asset(
                        'assets/images/badges/locked.png',
                        height: 100,
                        width: 98,
                      ),
                    if (_10_hour_badge_earned)
                      GestureDetector(
                        onTap: () {
                          showCongratulationDialog(context, 10, 'assets/images/badges/10_hours.png');
                        },
                        child: Image.asset(
                          'assets/images/badges/10_hours.png',
                          height: 100,
                          width: 98,
                        ),
                      )
                    else
                      Image.asset(
                        'assets/images/badges/locked.png',
                        height: 100,
                        width: 98,
                      ),
                    if (_15_hour_badge_earned)
                      GestureDetector(
                        onTap: () {
                          showCongratulationDialog(context, 15, 'assets/images/badges/15_hours.png');
                        },
                        child: Image.asset(
                          'assets/images/badges/15_hours.png',
                          height: 100,
                          width: 98,
                        ),
                      )
                    else
                      Image.asset(
                        'assets/images/badges/locked.png',
                        height: 100,
                        width: 98,
                      ),
                  ],
                ),
                SizedBox(height: 10),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    if (_30_hour_badge_earned)
                      GestureDetector(
                        onTap: () {
                          showCongratulationDialog(context, 30, 'assets/images/badges/30_hours.png');
                        },
                        child: Image.asset(
                          'assets/images/badges/30_hours.png',
                          height: 100,
                          width: 98,
                        ),
                      )
                    else
                      Image.asset(
                        'assets/images/badges/locked.png',
                        height: 100,
                        width: 98,
                      ),
                    if (_50_hour_badge_earned)
                      GestureDetector(
                        onTap: () {
                          showCongratulationDialog(context, 50, 'assets/images/badges/50_hours.png');
                        },
                        child: Image.asset(
                          'assets/images/badges/50_hours.png',
                          height: 100,
                          width: 98,
                        ),
                      )
                    else
                      Image.asset(
                        'assets/images/badges/locked.png',
                        height: 100,
                        width: 98,
                      ),
                    if (_100_hour_badge_earned)
                      GestureDetector(
                        onTap: () {
                          showCongratulationDialog(context, 100, 'assets/images/badges/100_hours.png');
                        },
                        child: Image.asset(
                          'assets/images/badges/100_hours.png',
                          height: 100,
                          width: 98,
                        ),
                      )
                    else
                      Image.asset(
                        'assets/images/badges/locked.png',
                        height: 100,
                        width: 98,
                      ),
                  ],
                ),
              ],
            ),
          );
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
                    builder: (context) => VolunteeringEventDetailsPage(
                      volunteeringEvent: event,
                    ),
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
                          SizedBox(height: 4), // Spacer between location and date
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

    return areVolunteeringEventsLoading
        ? const CircularProgressIndicator()
        : Container(
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
                      " Upcoming",
                      style: TextStyle(
                        fontSize: 20,
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
              Column(children: getWidgets())
            ]),
          );
  }

  Widget buildCompletedVolunteering(BuildContext context) {
    List<Widget> getWidgets() {
      List<Widget> cards = [];

      for (var event in completedVolunteeringEvents) {
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

    return areVolunteeringEventsLoading
        ? const CircularProgressIndicator()
        : Container(
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
                      " Completed",
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    Text(completedVolunteeringEvents.length.toString(),
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w700,
                          color: Colors.grey.shade600,
                        )),
                  ])),
              Column(children: getWidgets())
            ]),
          );
  }

  void showCongratulationDialog(BuildContext context, int hours, String badgePhotoURL) {
    String title = "";
    String message = "";

    switch (hours) {
      case 5:
        title = "Blossoming Volunteer";
        message = "Congratulations on completing 5 hours of volunteering! Keep spreading your positivity and watch your garden of impact grow!";
        break;
      case 10:
        title = "Galactic Volunteer";
        message = "You've reached 10 hours of volunteering! Your impact is out of this world. Keep shining bright!";
        break;
      case 15:
        title = "Soaring Volunteer";
        message =
            "You're really taking off! With 15 hours of volunteering, your impact is soaring high. Keep reaching new heights with your generosity and dedication!";
        break;
      case 30:
        title = "Heartfelt Helper";
        message =
            "30 hours complete! Your generosity and kindness have touched many hearts. Thank you for spreading love through your volunteer work.";
        break;
      case 50:
        title = "Electrifying Contributor";
        message =
            "You've powered through 50 hours of volunteering! Your energy and enthusiasm are electrifying, like a bolt of lightning. Keep sparking positive change!";
        break;
      case 100:
        title = "Volunteer Royalty";
        message =
            "You're the reigning champion of volunteering with 100 hours under your belt! Wear your crown proudly, for you are making a real impact on the world.";
        break;
      default:
        title = "Error";
        message = "";
    }

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
            title: Text(
              title,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontWeight: FontWeight.w700,
                fontSize: 25,
                decorationColor: Colors.black,
              ),
            ),
            content: Column(mainAxisSize: MainAxisSize.min, children: [
              Image.asset(
                badgePhotoURL,
                height: 200,
                width: 150,
              ),
              SizedBox(height: 10),
              Text(
                message,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontWeight: FontWeight.w500,
                  fontSize: 15,
                  decorationColor: Colors.black,
                ),
              ),
            ]));
      },
    );
  }
}
