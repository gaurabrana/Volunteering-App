import 'package:HeartOfExperian/DataAccessLayer/VolunteeringEventRegistrationsDAO.dart';
import 'package:HeartOfExperian/Pages/CustomWidgets/VolunteeringTypePieChart.dart';
import 'package:HeartOfExperian/Pages/Settings/Settings.dart';
import 'package:HeartOfExperian/Pages/Settings/SharedPreferences.dart';
import 'package:HeartOfExperian/constants/enums.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:intl/intl.dart';

import '../DataAccessLayer/FollowingDAO.dart';
import '../DataAccessLayer/PhotoDAO.dart';
import '../DataAccessLayer/UserDAO.dart';
import '../DataAccessLayer/VolunteeringEventDAO.dart';
import '../DataAccessLayer/VolunteeringHistoryDAO.dart';
import '../Models/UserDetails.dart';
import '../Models/VolunteeringEvent.dart';
import '../Models/VolunteeringHistory.dart';
import 'CustomWidgets/VolunteeringGraph.dart';
import 'Following.dart';
import 'VolunteeringEventDetails.dart';

class ProfilePage extends StatefulWidget {
  final GlobalKey<NavigatorState> mainNavigatorKey;
  final GlobalKey<NavigatorState> loginNavigatorKey;

  const ProfilePage(
      {super.key,
      required this.loginNavigatorKey,
      required this.mainNavigatorKey});

  @override
  State<StatefulWidget> createState() => ProfilePageState();
}

class ProfilePageState extends State<ProfilePage> {
  late bool isPhotoLoading;
  late bool isNameLoading;
  bool areFollowingLoading = true;
  late bool areHistoricalHoursDetailsLoading;
  bool areVolunteeringEventsLoading = true;
  late String _photoURL;
  late int following;

  late int _hoursThisMonth;
  late int _hoursThisYear;
  late int _hoursAllTime;

  late bool isVolunteeringHistoryLoading;
  late List<VolunteeringHistory> _volunteeringHistory;

  TextEditingController financialYearTextEditingController =
      new TextEditingController();
  int _financialYearShownOnGraph = 24;
  int selectedYearIndex = 0;

  late List<VolunteeringEvent> upcomingVolunteeringEvents = [];
  late List<VolunteeringEvent> completedVolunteeringEvents = [];

  UserDetails? _userDetails; // Store the user details
  bool _isLoading = true; // Loading state
  Map<String, dynamic>? organisationDetails;

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
      _hoursThisMonth = 0;
      _hoursThisYear = 0;
      _hoursAllTime = 0;
      areHistoricalHoursDetailsLoading = true;
      isVolunteeringHistoryLoading = true;
      _volunteeringHistory = [];
      _financialYearShownOnGraph = 24;
      following = 0;
      upcomingVolunteeringEvents = [];
      completedVolunteeringEvents = [];
      areVolunteeringEventsLoading = true;
      selectedYearIndex = 0;
      areFollowingLoading = true;
    });
  }

  Future<void> _fetchData() async {
    _initialiseData();
    _fetchUserDetails();

    await _fetchProfilePhoto();
    await _fetchHistoricalHours();
    await _fetchAllVolunteeringHistory();
    await _fetchNumberFollowing();
    await _fetchVolunteeringEvents();
  }

  Future<void> _fetchNumberFollowing() async {
    int num = await FollowingDAO.getNumberFollowing(
        FirebaseAuth.instance.currentUser!.uid);
    setState(() {
      following = num;
      areFollowingLoading = false;
    });
  }

  Future<void> _fetchProfilePhoto() async {
    FirebaseAuth auth = FirebaseAuth.instance;
    User? user = auth.currentUser;

    try {
      String photoURL =
          await PhotoDAO.getUserProfilePhotoUrlFromFirestore(user?.uid);
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
      UserDetails? userDetails =
          await SignInSharedPreferences.getCurrentUserDetails();
      setState(() {
        _userDetails = userDetails;
        _isLoading = false; // Data fetched, no longer loading
      });
      if (userDetails != null && userDetails.role == UserRole.organisation) {
        _fetchOrganisationDetails(userDetails.UID);
      }
    } catch (e) {
      setState(() {
        _isLoading = false; // Even if there's an error, stop loading
      });
      print('Error fetching user details: $e');
    }
  }

  Future<void> _fetchHistoricalHours() async {
    try {
      FirebaseAuth auth = FirebaseAuth.instance;
      User? user = auth.currentUser;

      int monthHours =
          await VolunteeringHistoryDAO.getUsersVolunteeringHoursOfPastMonth(
              user?.uid, "Any");
      int yearHours = await VolunteeringHistoryDAO
          .getUsersVolunteeringHoursThisFinancialYear(user?.uid, "Any");
      int allTimeHours =
          await VolunteeringHistoryDAO.getUsersAllTimeVolunteeringHours(
              user?.uid);
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

      List<VolunteeringHistory>? volunteeringHistory =
          await VolunteeringHistoryDAO.getAllUsersVolunteeringHistory(
              user?.uid);
      setState(() {
        if (volunteeringHistory != null) {
          _volunteeringHistory = volunteeringHistory;
        }
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

      List<String> allEventIds =
          await VolunteeringEventRegistrationsDAO.getAllEventIdsForUser(
              FirebaseAuth.instance.currentUser!.uid);

      for (var eventId in allEventIds) {
        VolunteeringEvent? event =
            await VolunteeringEventDAO.getVolunteeringEvent(eventId);

        if (event!.date.isAfter(DateTime.now())) {
          upcomingVolunteering.add(event);
        } else {
          completedVolunteering.add(event);
        }
      }

      setState(() {
        upcomingVolunteeringEvents.addAll(upcomingVolunteering);
        completedVolunteeringEvents.addAll(completedVolunteering);
        areVolunteeringEventsLoading = false;
      });
    } catch (e) {
      //print('Error fetching events: $e');
    }
  }

  @override
  Widget build(context) {
    return Scaffold(
        body: RefreshIndicator(
            onRefresh: _fetchData,
            child: SingleChildScrollView(
                child: Padding(
              padding: const EdgeInsets.only(
                  top: 40, left: 30, right: 30, bottom: 20),
              child: Column(
                children: [
                  buildSettingsButton(context),
                  buildProfilePhoto(context),
                  const SizedBox(height: 20),
                  buildUserInformation(),
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
              Navigator.of(context)
                  .push(
                MaterialPageRoute(
                  builder: (context) => SettingsPage(
                    mainNavigatorKey: widget.mainNavigatorKey,
                    logInNavigatorKey: widget.loginNavigatorKey,
                  ),
                ),
              )
                  .then(
                (value) {
                  _fetchUserDetails();
                },
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
                        loadingBuilder: (BuildContext context, Widget child,
                            ImageChunkEvent? loadingProgress) {
                          if (loadingProgress == null) {
                            // Image has finished loading
                            return child;
                          } else {
                            // Image is still loading
                            return const CircularProgressIndicator();
                          }
                        },
                        errorBuilder: (BuildContext context, Object exception,
                            StackTrace? stackTrace) {
                          return const Text('Failed to load image');
                        },
                      )
                    : const SizedBox(), // Placeholder when photo URL is empty
              ),
            ),
    );
  }

  Widget buildProfileName(BuildContext context, String name) {
    return Text(
      name,
      textAlign: TextAlign.left,
      style: const TextStyle(
        fontWeight: FontWeight.w700,
        fontSize: 27,
        decorationColor: Colors.black,
      ),
    );
  }

  Widget buildFollowingButton(BuildContext context) {
    return TextButton(
      onPressed: () {
        Navigator.of(context).push(
          MaterialPageRoute(builder: (context) => FollowingPage()),
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
                  style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                      color: Colors.black),
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
        : (completedVolunteeringEvents.isNotEmpty ||
                upcomingVolunteeringEvents.isNotEmpty)
            ? Container(
                alignment: Alignment.center,
                padding: const EdgeInsets.only(
                    top: 5, left: 25, right: 20, bottom: 10),
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
            icon: const FaIcon(FontAwesomeIcons.sliders,
                color: Colors.white, size: 25), //todo adjust thickness
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
            financialYearTextEditingController.text =
                _financialYearShownOnGraph.toString();
          });
        },
        style: ButtonStyle(
          backgroundColor: MaterialStateProperty.resolveWith<Color>(
              (Set<MaterialState> states) {
            return Colors.white;
          }),
          textStyle: MaterialStateProperty.resolveWith<TextStyle>(
              (Set<MaterialState> states) {
            return selectedYearIndex ==
                    i // todo the old button style is not changing back
                ? TextStyle(color: Colors.black, fontWeight: FontWeight.bold)
                : TextStyle(
                    color: Colors.grey.shade600, fontWeight: FontWeight.normal);
          }),
          side: MaterialStateProperty.resolveWith<BorderSide>(
              (Set<MaterialState> states) {
            return selectedYearIndex == i
                ? BorderSide(color: Colors.purple, width: 2.0)
                : BorderSide(color: Colors.grey, width: 1.0);
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
              ? const TextStyle(
                  color: Colors.black,
                  fontWeight: FontWeight.bold,
                  fontFamily: 'Poppins')
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
          content: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
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
                    child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                      TextButton(
                          onPressed: () async {
                            int newFinancialYear = int.tryParse(
                                    financialYearTextEditingController.text) ??
                                24;
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
                              Icon(Icons.location_on_rounded,
                                  color: Colors.grey.shade500, size: 15),
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
                          SizedBox(
                              height: 4), // Spacer between location and date
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
            padding:
                const EdgeInsets.only(top: 10, left: 10, right: 10, bottom: 0),
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
            child:
                Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Padding(
                  padding: const EdgeInsets.only(
                      top: 5, left: 5, right: 10, bottom: 5),
                  child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
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
                    builder: (context) =>
                        VolunteeringEventDetailsPage(volunteeringEvent: event),
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
                              Icon(Icons.location_on_rounded,
                                  color: Colors.grey.shade500, size: 15),
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
            padding:
                const EdgeInsets.only(top: 10, left: 10, right: 10, bottom: 0),
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
            child:
                Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Padding(
                  padding: const EdgeInsets.only(
                      top: 5, left: 5, right: 10, bottom: 5),
                  child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
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

  List<Widget> buildUserProfile() {
    return [
      buildFollowingButton(context),
      const SizedBox(height: 10),
      buildHistoricalHoursSection(context),
      const SizedBox(height: 25),
      buildVolunteeringGraph(context),
      const SizedBox(height: 25),
      buildUpcomingVolunteering(context),
      const SizedBox(height: 25),
      buildCompletedVolunteering(context),
      const SizedBox(height: 25),
      buildVolunteeringTypePieChart(context),
    ];
  }

  List<Widget> buildOrganisationDetails() {
    return [
      SizedBox(
        height: 20,
      ),
      buildSection('Mission', organisationDetails!['mission']),
      buildSection('Main Activities', organisationDetails!['activities']),
      buildSection(
          'Completed Projects', organisationDetails!['completedProjects']),
      buildSection(
          'Number of Benefactors', organisationDetails!['benefactors']),
      buildSection('Certifications', organisationDetails!['certificate']),
    ];
  }

  Widget buildUserInformation() {
    if (_isLoading) {
      // While loading, show a loading indicator
      return Center(child: CircularProgressIndicator());
    } else if (_userDetails == null) {
      // If there's no user details available
      return Text("No user details available.");
    } else {
      // Build the UI with the fetched user details
      return Column(
        children: [
          buildProfileName(context, _userDetails!.name),
          if (_userDetails!.role == UserRole.user) ...buildUserProfile(),
          if (_userDetails!.role == UserRole.organisation &&
              organisationDetails != null)
            ...buildOrganisationDetails(),
        ],
      );
    }
  }

  // Helper method to build a section with title and content
  Widget buildSection(String title, String content) {
    return Container(
      width: MediaQuery.of(context).size.width,
      margin: const EdgeInsets.only(bottom: 20),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.2),
            spreadRadius: 2,
            blurRadius: 4,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          buildSectionTitle(title),
          SizedBox(height: 8),
          buildSectionContent(content),
        ],
      ),
    );
  }

  // Beautified section title
  Widget buildSectionTitle(String title) {
    return Text(
      title,
      style: TextStyle(
        fontSize: 20,
        fontWeight: FontWeight.bold,
        color: Colors.deepPurple,
      ),
    );
  }

  // Beautified section content
  Widget buildSectionContent(String content) {
    return Text(
      content,
      style: TextStyle(
        fontSize: 16,
        color: Colors.black87,
        height: 1.5,
      ),
    );
  }

  void _fetchOrganisationDetails(String userId) async {
    var details = await UserDAO.fetchOrganisationDetails(userId);
    setState(() {
      organisationDetails = details;
    });
  }
}
