import 'package:HeartOfExperian/Models/UserDetails.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import '../DataAccessLayer/FollowingDAO.dart';
import '../DataAccessLayer/UserDAO.dart';
import 'ColleagueProfile.dart';
import 'CustomWidgets/BackButton.dart';

class FollowingPage extends StatefulWidget {

  const FollowingPage({Key? key}) : super(key: key);

  @override
  State<StatefulWidget> createState() => FollowingPageState();
}

class FollowingPageState extends State<FollowingPage> {
  List<UserDetails> _users = [];
  bool areUserDetailsLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchUserDetails();
  }

  Future<void> _fetchUserDetails() async {
    try {
      List<String> userIds = await FollowingDAO.getAllFollowingsForUser(FirebaseAuth.instance.currentUser!.uid);
      List<UserDetails> users = [];
      for (var userId in userIds) {
        var user = await UserDAO.getUserDetails(userId);
        users.add(user!);
      }
      setState(() {
        _users.addAll(users);
        areUserDetailsLoading = false;
      });
    } catch (e) {
      print('Error fetching users details: $e');
    }
  }

  @override
  Widget build(context) {
    return Scaffold(
        backgroundColor: Colors.white,
        body: Padding(
            padding: const EdgeInsets.only(top: 40.0, left: 20, right: 20, bottom: 20),
            child: Column(children: [
              buildTeamNameTitleAndBackButton(context),
              Expanded(
                child: areUserDetailsLoading ? const Center(child: CircularProgressIndicator()) : buildUsersList(context, _users),
              ),
            ])));
  }

  Widget buildTeamNameTitleAndBackButton(BuildContext context) {
    return Row(
      children: [
        GoBackButton(),
        const SizedBox(width: 15),
        Text('Following',
            textAlign: TextAlign.left,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 30,
              decorationColor: Colors.black,
            ))
      ],
    );
  }

  Widget buildUsersList(BuildContext context, List<UserDetails> users) {
    return ListView.builder(
      physics: const AlwaysScrollableScrollPhysics(),
      itemCount: users.length,
      itemBuilder: (BuildContext context, int index) {
        UserDetails user = users[index];
        return ListTile(
          leading: CircleAvatar(
            backgroundImage: NetworkImage(user.profilePhotoUrl),
          ),
          title: Text(user.forename + " " + user.surname),
          onTap: () {
            Navigator.of(context).push(MaterialPageRoute(
              builder: (context) => ColleagueProfilePage(UID: user.UID),
            ));
          },
        );
      },
    );
  }
}
