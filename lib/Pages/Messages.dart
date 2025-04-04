import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import 'Chatroom.dart';
import 'NewGroupChat.dart';

class MessagingPage extends StatefulWidget {
  @override
  _MessagingPageState createState() => _MessagingPageState();
}

class _MessagingPageState extends State<MessagingPage> {
  final _firestore = FirebaseFirestore.instance;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Messages',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 25,
          ),
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.add),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => NewGroupChatPage(),
                ),
              );
            },
          ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: _firestore
                  .collection('chats')
                  .where('users', arrayContains: FirebaseAuth.instance.currentUser!.uid)
                  .orderBy('lastMessageTime', descending: true)
                  .snapshots(),
              builder: (context, snapshot) {
                if (!snapshot.hasData) {
                  return Center(child: CircularProgressIndicator());
                }

                return ListView.builder(
                  itemCount: snapshot.data!.docs.length,
                  itemBuilder: (context, index) {
                    final chat = snapshot.data!.docs[index];
                    final List<dynamic> memberIds = chat['users'];
                    final chatId = chat.id;

                    return ListTile(
                      leading: FutureBuilder<List<DocumentSnapshot>>(
                        future: _fetchMembers(memberIds),
                        builder: (context, usersSnapshot) {
                          if (!usersSnapshot.hasData) {
                            return CircularProgressIndicator();
                          }

                          final profilePhotoUrls = usersSnapshot.data!.map((doc) => doc['profilePhotoUrl']).toList();
                          return buildLeadingProfilePhotos(profilePhotoUrls);
                        },
                      ),
                      title: StreamBuilder<QuerySnapshot>(
                        stream: _firestore.collection('chats/$chatId/users').snapshots(),
                        builder: (context, usersSnapshot) {
                          if (!usersSnapshot.hasData) {
                            return Container();
                          }

                          final bool isUnread = usersSnapshot.data!.docs
                              .where((doc) => doc['user'] == FirebaseAuth.instance.currentUser!.uid && doc['read'] == false)
                              .isNotEmpty;

                          return Text(
                            chat['chatName'],
                            style: TextStyle(
                              fontWeight: isUnread ? FontWeight.bold : FontWeight.normal,
                            ),
                          );
                        },
                      ),
                      subtitle: StreamBuilder<QuerySnapshot>(
                        stream: _firestore.collection('chats/$chatId/users').snapshots(),
                        builder: (context, usersSnapshot) {
                          if (!usersSnapshot.hasData) {
                            return Container();
                          }

                          final bool isUnread = usersSnapshot.data!.docs
                              .where((doc) => doc['user'] == FirebaseAuth.instance.currentUser!.uid && doc['read'] == false)
                              .isNotEmpty;

                          return Text(
                            chat['lastMessage'],
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              fontWeight: isUnread ? FontWeight.bold : FontWeight.normal,
                            ),
                          );
                        },
                      ),
                      trailing: Text(
                        formatLastMessageTime(chat['lastMessageTime']),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(fontWeight: FontWeight.normal, color: Colors.grey.shade600),
                      ),
                      onTap: () {
                        Navigator.of(context, rootNavigator: true).push(MaterialPageRoute(
                          builder: (_) => ChatroomPage(chat: chat),
                        ),
                        );
                      },
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Future<List<DocumentSnapshot>> _fetchMembers(List<dynamic> memberIds) async {
    final List<DocumentSnapshot> members = [];
    int count = 0;
    for (final memberId in memberIds) {
      if (count >= 3) break;
      if (memberId != FirebaseAuth.instance.currentUser!.uid) {
        final member = await _firestore.collection('users').doc(memberId).get();
        members.add(member);
        count++;
      }
    }
    return members;
  }

  Widget buildLeadingProfilePhotos(List<dynamic> profilePhotoUrls) {
    if (profilePhotoUrls.length == 1) {
      return Container(
        margin: const EdgeInsets.only(top: 0, left: 10, right: 10, bottom: 0),
        width: 50,
        height: 50,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.2),
              spreadRadius: 3,
              blurRadius: 3,
              offset: const Offset(0, 2),
            ),
          ],
          image: DecorationImage(
            fit: BoxFit.cover,
            image: NetworkImage(profilePhotoUrls.first),
          ),
        ),
      );
    } else if (profilePhotoUrls.length == 2) {
      return SizedBox(
        width: 70,
        height: 70,
        child: Stack(
          children: [
            Positioned(
              top: 0,
              right: 0,
              child: Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.grey.withOpacity(0.2),
                      spreadRadius: 3,
                      blurRadius: 3,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: CircleAvatar(
                  backgroundImage: NetworkImage(profilePhotoUrls[1]),
                ),
              ),
            ),
            Positioned(
              bottom: 0,
              left: 0,
              child: Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.grey.withOpacity(0.2),
                      spreadRadius: 3,
                      blurRadius: 3,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: CircleAvatar(
                  backgroundImage: NetworkImage(profilePhotoUrls[0]),
                ),
              ),
            ),
          ],
        ),
      );
    } else if (profilePhotoUrls.length == 3) {
      return SizedBox(
        width: 70,
        height: 70,
        child: Stack(
          children: [
            Positioned(
              top: 2,
              right: 20,
              child: Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.grey.withOpacity(0.2),
                      spreadRadius: 3,
                      blurRadius: 3,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: CircleAvatar(
                  radius: 16,
                  backgroundImage: NetworkImage(profilePhotoUrls[1]),
                ),
              ),
            ),
            Positioned(
              bottom: 0,
              left: 5,
              child: Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.grey.withOpacity(0.2),
                      spreadRadius: 3,
                      blurRadius: 3,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: CircleAvatar(
                  radius: 16,
                  backgroundImage: NetworkImage(profilePhotoUrls[0]),
                ),
              ),
            ),
            Positioned(
              bottom: 0,
              right: 5,
              child: Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.grey.withOpacity(0.2),
                      spreadRadius: 3,
                      blurRadius: 3,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: CircleAvatar(
                  radius: 16,
                  backgroundImage: NetworkImage(profilePhotoUrls[2]),
                ),
              ),
            ),
          ],
        ),
      );
    } else {
      return SizedBox(
        width: 70,
        height: 70,
        child: Stack(
          children: [
            CircleAvatar(
              backgroundImage: NetworkImage(profilePhotoUrls[0]),
            ),
            Positioned(
              top: 0,
              right: 0,
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.grey[300],
                  shape: BoxShape.circle,
                ),
                padding: EdgeInsets.all(6),
                child: Text(
                  '+${profilePhotoUrls.length - 1}',
                  style: TextStyle(color: Colors.black),
                ),
              ),
            ),
          ],
        ),
      );
    }
  }

  String formatLastMessageTime(Timestamp timestamp) {
    DateTime lastMessageTime = timestamp.toDate();
    DateTime now = DateTime.now();

    if (lastMessageTime.year == now.year && lastMessageTime.month == now.month && lastMessageTime.day == now.day) {
      return DateFormat.Hm().format(lastMessageTime);
    } else if (lastMessageTime.difference(now).inDays >= -now.weekday && lastMessageTime.difference(now).inDays < 0) {
      return DateFormat.E().format(lastMessageTime);
    } else {
      return DateFormat('MM/dd').format(lastMessageTime);
    }
  }
}
