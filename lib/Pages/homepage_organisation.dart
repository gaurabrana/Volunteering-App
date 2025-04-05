import 'package:HeartOfExperian/constants/enums.dart';
import 'package:flutter/material.dart';

import '../Models/UserDetails.dart';
import 'CreateVolunteeringEvent.dart';
import 'Messages.dart';
import 'Settings/SharedPreferences.dart';
import 'common_helper.dart';

class HomepageOrganisation extends StatefulWidget {
  final GlobalKey<NavigatorState> mainNavigatorKey;
  final GlobalKey<NavigatorState> logInNavigatorKey;

  const HomepageOrganisation(
      {super.key,
      required this.mainNavigatorKey,
      required this.logInNavigatorKey});

  @override
  State<StatefulWidget> createState() => HomepageOrganisationState();
}

class HomepageOrganisationState extends State<HomepageOrganisation> {
  bool _hasUnreadChats = false;
  bool hasUnreadChatsLoading = false;
  UserDetails? _userDetails;
  bool isUserLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchUserDetails();
    _fetchData();
  }

  Future<void> _fetchUserDetails() async {
    try {
      UserDetails? userDetails =
          await SignInSharedPreferences.getCurrentUserDetails();
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

  Future<void> _fetchData() async {}

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

        // Performance Widgets
        _buildPerformanceCard(
          title: "Volunteer Recruitment",
          percentage: 76,
          color: Colors.blueAccent,
        ),
        _buildPerformanceCard(
          title: "Project Delivery Effectiveness",
          percentage: 89,
          color: Colors.green,
        ),
        _buildPerformanceCard(
          title: "Financial Development Drive",
          percentage: 64,
          color: Colors.deepOrange,
        ),
        const SizedBox(height: 30),

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

// Performance Card Widget
  Widget _buildPerformanceCard(
      {required String title, required int percentage, required Color color}) {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      margin: const EdgeInsets.symmetric(vertical: 10),
      child: ListTile(
        leading: CircularProgressIndicator(
          value: percentage / 100,
          backgroundColor: Colors.grey[300],
          color: color,
        ),
        title: Text(title),
        trailing:
            Text("$percentage%", style: TextStyle(fontWeight: FontWeight.bold)),
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
            _buildVolunteerRow("Alex", 20, "Logistics"),
            _buildVolunteerRow("Sophie", 35, "Outreach"),
          ],
        ),
      ),
    );
  }

  Widget _buildVolunteerRow(String name, int hours, String role) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 5),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(name),
          Text("$hours hrs"),
          Text(role),
        ],
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

  buildVolunteerDashboard() {}

  redirectToAnotherPage(int indexToNavigate) {
    CommonHelper.redirectToAnotherPage(
        indexToNavigate: indexToNavigate,
        context: context,
        logInNavigatorKey: widget.logInNavigatorKey,
        mainNavigatorKey: widget.mainNavigatorKey);
  }
}
