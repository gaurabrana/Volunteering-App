import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import 'Chatroom.dart';

class NewGroupChatPage extends StatefulWidget {
  @override
  _NewGroupChatPageState createState() => _NewGroupChatPageState();
}

class _NewGroupChatPageState extends State<NewGroupChatPage> {
  List<String> selectedMembers = [];
  List<DocumentSnapshot> selectedMemberSnapshots = [];
  List<DocumentSnapshot> users = [];

  @override
  void initState() {
    super.initState();
    fetchUsers();
  }

  Future<void> fetchUsers() async {
    final QuerySnapshot snapshot =
        await FirebaseFirestore.instance.collection('users').where('UID', isNotEqualTo: FirebaseAuth.instance.currentUser!.uid).get();
    setState(() {
      users = snapshot.docs;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('New Group Chat'),
        actions: [
          IconButton(
              icon: Icon(Icons.check),
              onPressed: () async {
                final List<String> memberIds = selectedMembers;

                if (selectedMembers.length == 0) return; // todo output nice msg

                final String currentUserId = FirebaseAuth.instance.currentUser!.uid;
                if (!memberIds.contains(currentUserId)) memberIds.add(currentUserId);
                final String chatName = getChatName();

                final chatRef = await FirebaseFirestore.instance
                    .collection('chats')
                    .add({'chatName': chatName, 'users': memberIds, 'lastMessageTime': DateTime.now(), 'lastMessage': ''});

                final usersCollectionRef = chatRef.collection('users');

                for (final userId in memberIds) {
                  await usersCollectionRef.doc(userId).set({
                    'user': userId,
                    'read': false,
                  });
                }

                Navigator.pop(context);

                final chatQuerySnapshot = await FirebaseFirestore.instance.collection('chats').where('users', arrayContains: currentUserId).get();

                final filteredChats = chatQuerySnapshot.docs.where((chatDoc) {
                  List<dynamic> users = chatDoc['users'];
                  bool containsOnlyMemberIds = users.length == memberIds.length && users.every((id) => memberIds.contains(id));
                  return containsOnlyMemberIds;
                }).toList();

                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => ChatroomPage(chat: filteredChats.first),
                  ),
                );
              }),
        ],
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Text(
              'Add Members',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          Expanded(
            child: ListView.builder(
              itemCount: users.length,
              itemBuilder: (context, index) {
                final user = users[index];
                final String userId = user.id;
                final String userName = user['forename'] + " " + user['surname'];

                return ListTile(
                  title: Text(userName),
                  onTap: () {
                    setState(() {
                      selectedMembers.contains(userId) ? selectedMembers.remove(userId) : selectedMembers.add(userId);

                      selectedMemberSnapshots.contains(user) ? selectedMemberSnapshots.remove(user) : selectedMemberSnapshots.add(user);
                    });
                  },
                  leading: CircleAvatar(
                    backgroundImage: NetworkImage(user['profilePhotoUrl']),
                    radius: 16,
                  ),
                  trailing: selectedMembers.contains(userId) ? Icon(Icons.check_circle, color: Colors.blue) : null,
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  String getChatName() {
    if (selectedMemberSnapshots.length == 1) {
      return "${selectedMemberSnapshots[0]['forename']} ${selectedMemberSnapshots[0]['surname']}";
    } else if (selectedMemberSnapshots.length == 2) {
      return "${selectedMemberSnapshots[0]['forename']} & ${selectedMemberSnapshots[1]['forename']}";
    } else if (selectedMemberSnapshots.length == 3) {
      return "${selectedMemberSnapshots[0]['forename']}, ${selectedMemberSnapshots[1]['forename']} & ${selectedMemberSnapshots[2]['forename']}";
    }
    return "${selectedMemberSnapshots[0]['forename']}, ${selectedMemberSnapshots[1]['forename']} & ${selectedMemberSnapshots.length - 2} others";
  }
}
