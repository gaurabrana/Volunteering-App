import 'package:HeartOfExperian/Models/UserDetails.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import '../DataAccessLayer/PhotoDAO.dart';
import '../DataAccessLayer/TeamDAO.dart';
import '../DataAccessLayer/UserDAO.dart';
import '../DataAccessLayer/VolunteeringHistoryDAO.dart';
import '../Models/LeaderboardStatistic.dart';
import 'CustomWidgets/BackButton.dart';
import 'CustomWidgets/VolunteeringStatCard.dart';
import 'Settings/EditTeam.dart';

class TeamPage extends StatefulWidget {
  final String teamId;

  const TeamPage({Key? key, required this.teamId}) : super(key: key);

  @override
  State<StatefulWidget> createState() => TeamPageState();
}

class TeamPageState extends State<TeamPage> {
  bool isCurrentUsersTeam = false;
  late String _teamName;
  List<UserDetails> teamMembers = [];
  bool areTeamDetailsLoading = true;
  late List<LeaderboardStatistic> leaderboardStatistics;
  DateTime startDate = DateTime(DateTime.now().year - 1);
  DateTime endDate = DateTime.now();
  String _photoURL = "";
  bool isPhotoLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchData();
  }

  Future<void> _fetchData() async {
    setState(() {
      areTeamDetailsLoading = true;
      isPhotoLoading = true;
      teamMembers = [];
      isCurrentUsersTeam = false;
    });
    await _fetchTeamDetails();
    await _fetchProfilePhoto();
  } //todo dont let users follow themselves.

  Future<void> _fetchTeamDetails() async {
    try {
      List<UserDetails?> users = await UserDAO.getTeamMembers(widget.teamId);
      List<LeaderboardStatistic> userStats = await VolunteeringHistoryDAO.getLeaderboardStatisticsWithinTeam(startDate, endDate, "Any", users);
      bool currentUsersTeam = await TeamDAO.isUserInTeam(FirebaseAuth.instance.currentUser!.uid, widget.teamId);
      String? teamName = await TeamDAO.getTeamName(widget.teamId);
      setState(() {
        teamMembers.addAll(users.toSet() as Iterable<UserDetails>);
        leaderboardStatistics = userStats;
        _teamName = teamName!;
        isCurrentUsersTeam = currentUsersTeam;
        areTeamDetailsLoading = false;
      });
    } catch (e) {
      //print('Error fetching team details: $e');
    }
  }

  Future<void> _fetchProfilePhoto() async {
    try {
      String photoURL = await PhotoDAO.getTeamProfilePhotoUrlFromFirestore(widget.teamId);
      setState(() {
        _photoURL = photoURL;
        isPhotoLoading = false;
      });
    } catch (e) {
      //print('Error fetching photo: $e');
    }
  }

  @override
  Widget build(context) {
    return Scaffold(
        backgroundColor: Colors.white,
        body: RefreshIndicator(
            onRefresh: _fetchData,
            child: SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                child: Padding(
                    padding: const EdgeInsets.only(top: 40, left: 20, right: 20, bottom: 20),
                    child: Column(children: [
                      Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                        buildBackButton(context),
                        isCurrentUsersTeam ? buildEditButton(context) : Container(),
                      ]),
                      buildProfilePhoto(context),
                      SizedBox(height: 10),
                      buildTeamName(context),
                      SizedBox(height: 20),
                      areTeamDetailsLoading ? const Center(child: CircularProgressIndicator()) : buildTeamMembersList(context, teamMembers),
                    ])))));
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

  Widget buildEditButton(BuildContext context) {
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
                  builder: (context) => EditTeamPage(
                    teamName: _teamName,
                    teamId: widget.teamId,
                  ),
                ),
              );
            },
            icon: const Icon(
              Icons.edit,
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

  Widget buildTeamName(BuildContext context) {
    return Container(
      child: areTeamDetailsLoading
          ? const CircularProgressIndicator()
          : Text(
              _teamName,
              textAlign: TextAlign.left,
              style: const TextStyle(
                fontWeight: FontWeight.w700,
                fontSize: 27,
                decorationColor: Colors.black,
              ),
            ),
    );
  }

  Widget buildBackButton(BuildContext context) {
    return Row(
      children: [
        GoBackButton(),
      ],
    );
  }

  Widget buildTeamMembersList(BuildContext context, List<UserDetails> users) {
    return Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: leaderboardStatistics.asMap().entries.map((entry) {
          final userData = entry.value;
          return UserVolunteeringStatCard(
            id: userData.ID,
            name: userData.name,
            profilePhotoURL: userData.profilePhotoURL,
            hours: userData.numHours,
            rank: userData.rank,
            isTeamStat: false,
            isCurrentUser: (FirebaseAuth.instance.currentUser?.uid == userData.ID),
          );
        }).toList());
  }
}
