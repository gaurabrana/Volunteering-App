import 'package:HeartOfExperian/Models/UserDetails.dart';
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

  const AttendeesPage({Key? key, required this.users, required this.event}) : super(key: key);

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
    return Padding(
            padding: const EdgeInsets.only(top: 40.0, left: 20, right: 20, bottom: 20),
            child: Column(children: [
              buildTeamNameTitleAndBackButton(context),
              Expanded(
                child: buildUsersList(context, widget.users),
              ),
              buildJoinGroupChatButton(context),
            ]));
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

  Widget buildJoinGroupChatButton(BuildContext context) {
    return Container(
        alignment: Alignment.bottomCenter,
        height: 60,
        width: 350,
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
                joinGroupChat(context);
              },
              child: Container(
                height: 40,
                width: 400,
                alignment: Alignment.center,
                child: const Text("Group chat",
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontWeight: FontWeight.w600,
                      fontSize: 20,
                      color: Colors.white,
                    )),
              ))
        ])));
  }

  void joinGroupChat(BuildContext context) async {
    try {
      final String eventID = widget.event.reference.id;
      final String userIdToAdd = FirebaseAuth.instance.currentUser!.uid;

      final chatQuerySnapshot = await FirebaseFirestore.instance.collection('chats').where('eventId', isEqualTo: eventID).get();

      if (chatQuerySnapshot.docs.isNotEmpty) {
        final chatDoc = chatQuerySnapshot.docs.first;

        final usersCollectionRef = chatDoc.reference.collection('users');

        final userDoc = await usersCollectionRef.doc(userIdToAdd).get();
        if (userDoc.exists) {
          Navigator.of(context, rootNavigator: true).push(MaterialPageRoute(
            builder: (_) => ChatroomPage(chat: chatDoc),
          ),
          );
          return;
        }

        await usersCollectionRef.doc(userIdToAdd).set({
          'user': userIdToAdd,
          'read': false,
        });

        List<String> currentUsers = List<String>.from(chatDoc['users']);

        currentUsers.add(userIdToAdd);

        await chatDoc.reference.update({
          'users': currentUsers,
        });

        Navigator.of(context, rootNavigator: true).push(MaterialPageRoute(
          builder: (_) => ChatroomPage(chat: chatDoc),
        ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text('There was an error while trying to add you to the group chat.'),
        ));
      }
    } catch (e) {
      //print('Error while trying to add user to group chat: ' + e.toString());
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text('There was an error while trying to add you to the group chat.'),
      ));
    }
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
