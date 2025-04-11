import 'package:VolunteeringApp/DataAccessLayer/VolunteeringEventDAO.dart';
import 'package:VolunteeringApp/DataAccessLayer/VolunteeringHistoryDAO.dart';
import 'package:VolunteeringApp/Pages/VolunteerAssignAndTrack.dart';
import 'package:VolunteeringApp/constants/enums.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../Models/UserDetails.dart';
import '../Models/VolunteeringEvent.dart';
import '../Models/VolunteeringHistory.dart';
import 'CreateVolunteeringEvent.dart';
import 'Messages.dart';
import 'Settings/SharedPreferences.dart';
import 'VolunteeringEventDetails.dart';
import 'common_helper.dart';

class Homepage extends StatefulWidget {
  final GlobalKey<NavigatorState> mainNavigatorKey;
  final GlobalKey<NavigatorState> logInNavigatorKey;

  const Homepage(
      {super.key,
      required this.mainNavigatorKey,
      required this.logInNavigatorKey});

  @override
  State<StatefulWidget> createState() => HomepageState();
}

class HomepageState extends State<Homepage> {
  bool _hasUnreadChats = false;
  bool hasUnreadChatsLoading = false;
  UserDetails? _userDetails;
  bool isUserLoading = true;
  List<VolunteeringHistory> performanceOfVolunteers = [];

  @override
  void initState() {
    super.initState();
    _fetchData();
  }

  Future<void> _fetchUserDetails() async {
    try {
      UserDetails? userDetails =
          await SignInSharedPreferences().getCurrentUserDetails();
      if (userDetails != null) {
        setState(() {
          _userDetails = userDetails;
        });
      }
      setState(() {
        isUserLoading = false;
      });
    } catch (e) {
      print('Error fetching user details: $e');
    }
  }

  Future<void> _fetchData() async {
    await _fetchUserDetails();
    await getPerformanceOfVolunteer();
  }

  Future<void> getPerformanceOfVolunteer() async {
    performanceOfVolunteers =
        await VolunteeringHistoryDAO.getHistoryByOrganiser(_userDetails!.UID);

    // Call setState to update the UI
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return RefreshIndicator(
      onRefresh: _fetchData,
      child: SingleChildScrollView(
        child: Padding(
          padding:
              const EdgeInsets.only(top: 40, left: 30, right: 30, bottom: 20),
          child: isUserLoading
              ? Center(child: CircularProgressIndicator())
              : (_userDetails != null &&
                      _userDetails!.role == UserRole.organisation)
                  ? buildOrganisationDashboard(context)
                  : buildVolunteerDashboard(),
        ),
      ),
    );
  }

  Column buildOrganisationDashboard(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              'Dashboard',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 30,
              ),
            ),
            buildAddEventButton(context),
          ],
        ),
        const SizedBox(height: 25),

        const Text(
          'Volunteer Management',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 22,
          ),
        ),
        const SizedBox(height: 20),

        // Volunteer Assignment and Tracking
        _buildVolunteerAssignmentSection(),
        const SizedBox(height: 20),
        _buildVolunteerTrackingSection(),
      ],
    );
  }

  Widget buildAddEventButton(BuildContext context) {
    return Align(
      alignment: Alignment.center,
      child: Container(
        alignment: Alignment.center,
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
                    builder: (context) => CreateVolunteeringEventPage(
                        callbackOnCreateSuccess: redirectToAnotherPage)),
              );
            },
            icon: const Icon(Icons.add_rounded, color: Colors.white, size: 35),
            color: const Color(0xFF4136F1),
          ),
        ),
      ),
    );
  }

// Volunteer Assignment Section
  Widget _buildVolunteerAssignmentSection() {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text("Assign & Schedule Volunteers",
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
            const SizedBox(height: 10),
            ElevatedButton(
                onPressed: () {
                  // Navigate to assignment/scheduling screen
                  Navigator.of(context).push(MaterialPageRoute(
                    builder: (context) => VolunteerAssignandTrack(),
                  ));
                },
                child: const Text("Manage Assignments"))
          ],
        ),
      ),
    );
  }

// Volunteer Tracking Section
  Widget _buildVolunteerTrackingSection() {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text("Volunteer Performance",
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
            const SizedBox(height: 10),
            if (performanceOfVolunteers.isEmpty)
              Text("Record some logs first to appear here"),
            ...performanceOfVolunteers.map((e) {
              // Return the _buildVolunteerRow widget using the user details and volunteer data
              return _buildVolunteerRow(e);
            })
          ],
        ),
      ),
    );
  }

  Widget _buildVolunteerRow(VolunteeringHistory history) {
    String formattedDate = DateFormat('yyyy-MM-dd').format(history.date);

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 4),
      child: Container(
        padding: EdgeInsets.all(16),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(10),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.1),
              blurRadius: 5,
              spreadRadius: 1,
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // User Name and Profile Image
            Text(
              history.userName,
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 18,
              ),
            ),
            SizedBox(height: 8),

            // Hours and Role
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  "${history.hours} hrs ${history.minutes} mins",
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Colors.blueAccent,
                  ),
                ),
                Flexible(
                  child: Text(
                    "Role: ${history.role}",
                    style: TextStyle(
                      fontStyle: FontStyle.italic,
                      color: Colors.grey[600],
                    ),
                  ),
                ),
              ],
            ),
            SizedBox(height: 8),

            // Event and Task Completed
            Text(
              "Worked at: ${history.eventName}",
              style: TextStyle(
                fontSize: 13,
                color: Colors.black87,
              ),
            ),
            SizedBox(height: 4),
            Text(
              "Tasks: ${history.task}",
              style: TextStyle(
                fontSize: 13,
                color: Colors.grey[700],
              ),
            ),
            SizedBox(height: 8),

            // Date
            Text(
              "Date: $formattedDate",
              style: TextStyle(
                fontSize: 13,
                color: Colors.grey[600],
                fontStyle: FontStyle.italic,
              ),
            ),
          ],
        ),
      ),
    );
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

  buildVolunteerDashboard() {
    return FutureBuilder<List<VolunteeringEvent>?>(
      future: VolunteeringEventDAO()
          .getAllFutureVolunteeringEventsWithStatus(_userDetails?.UID ?? ''),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          // While loading, show a loading indicator
          return Center(child: CircularProgressIndicator());
        } else if (snapshot.hasError) {
          // If there was an error fetching events
          return Center(child: Text('Error: ${snapshot.error}'));
        } else if (snapshot.hasData && snapshot.data != null) {
          // If data is available, show the events
          List<VolunteeringEvent> events = snapshot.data!;
          // Separate the active events
          List<VolunteeringEvent> activeEvents = events
              .where((event) =>
                  event.currentUserRegistration != null &&
                  event.currentUserRegistration!.isAssigned)
              .toList();

          // Separate the applied events (but exclude already active events)
          List<VolunteeringEvent> appliedEvents = events
              .where((event) =>
                  event.currentUserRegistration != null &&
                  !activeEvents.contains(
                      event)) // Make sure we don't add already active events
              .toList();

          // Remaining ones (events that the user has neither applied to nor been assigned to)
          List<VolunteeringEvent> remainingEvents = events
              .where((event) =>
                  event.currentUserRegistration == null ||
                  !activeEvents.contains(event) &&
                      !appliedEvents.contains(event))
              .toList();

          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: const Text(
                  'Explore Events',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 24,
                  ),
                ),
              ),
              SizedBox(height: 20),
              // Active Events
              if (activeEvents.isNotEmpty) buildEventList(activeEvents),
              if (appliedEvents.isNotEmpty) buildEventList(appliedEvents),
              if (remainingEvents.isNotEmpty) buildEventList(remainingEvents),
            ],
          );
        } else {
          // Handle empty data
          return Center(child: Text('No events available.'));
        }
      },
    );
  }

  // Helper method to display events in a list
  Widget buildEventList(List<VolunteeringEvent> events) {
    return Column(
      children: events.map((event) {
        return GestureDetector(
            onTap: () {
              Navigator.of(context).push(MaterialPageRoute(
                builder: (context) =>
                    VolunteeringEventDetailsPage(volunteeringEvent: event),
              ));
            },
            child: CommonWidget.buildEventCard(event, context));
      }).toList(),
    );
  }

  // Helper method to build section titles
  Widget buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: Text(
        title,
        style: TextStyle(
          fontSize: 20,
          fontWeight: FontWeight.bold,
          color: Colors.black87,
        ),
      ),
    );
  }

  redirectToAnotherPage(int indexToNavigate) {
    CommonHelper.redirectToAnotherPage(
        indexToNavigate: indexToNavigate,
        context: context,
        logInNavigatorKey: widget.logInNavigatorKey,
        mainNavigatorKey: widget.mainNavigatorKey);
  }
}
