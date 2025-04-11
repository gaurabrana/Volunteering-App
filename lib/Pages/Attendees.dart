import 'package:VolunteeringApp/Models/UserDetails.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import '../Models/VolunteeringEvent.dart';
import 'Chatroom.dart';
import 'ColleagueProfile.dart';
import 'CustomWidgets/BackButton.dart';

class AttendeesPage extends StatefulWidget {
  final List<UserDetails> users;
  final VolunteeringEvent event;

  const AttendeesPage({Key? key, required this.users, required this.event})
      : super(key: key);

  @override
  State<StatefulWidget> createState() => AttendeesPageState();
}

class AttendeesPageState extends State<AttendeesPage> {
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(context) {
    return Scaffold(
      body: Padding(
          padding:
              const EdgeInsets.only(top: 40.0, left: 20, right: 20, bottom: 20),
          child: Column(children: [
            buildTeamNameTitleAndBackButton(context),
            Expanded(
              child: buildUsersList(context, widget.users),
            ),
          ])),
    );
  }

  Widget buildTeamNameTitleAndBackButton(BuildContext context) {
    return Row(
      children: [
        GoBackButton(),
        const SizedBox(width: 15),
        Text('Attendees',
            textAlign: TextAlign.left,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 30,
              decorationColor: Colors.black,
            )),
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
          title: Text(user.name),
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
