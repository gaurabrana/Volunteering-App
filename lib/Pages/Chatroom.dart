import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class ChatroomPage extends StatefulWidget {
  final QueryDocumentSnapshot chat;

  ChatroomPage({required this.chat});

  @override
  _ChatroomPageState createState() => _ChatroomPageState();
}

class _ChatroomPageState extends State<ChatroomPage> {
  final _firestore = FirebaseFirestore.instance;
  final _textController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _updateReadStatus();
  }

  Future<void> _updateReadStatus() async {
    final userId = FirebaseAuth.instance.currentUser!.uid;

    final userQuerySnapshot = await _firestore.collection('chats').doc(widget.chat.id).collection('users').where('user', isEqualTo: userId).get();

    if (userQuerySnapshot.docs.isNotEmpty) {
      final userRef = _firestore.collection('chats').doc(widget.chat.id).collection('users').doc(userQuerySnapshot.docs.first.id);

      await userRef.update({'read': true});
    }
  }

  Future<void> newMessageSent() async {
    final usersRef = _firestore.collection('chats').doc(widget.chat.id).collection('users');

    final userQuerySnapshot = await usersRef.get();

    for (final userDoc in userQuerySnapshot.docs) {
      final userId = userDoc['user'];

      if (userId == FirebaseAuth.instance.currentUser!.uid) {
        continue;
      }

      await usersRef.doc(userDoc.id).update({'read': false});
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      bottomNavigationBar: null,
        appBar: AppBar(
          title: Text(widget.chat['chatName'],
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 25,
              )),
        ),
        body: Padding(
            padding: const EdgeInsets.only(top: 0, left: 20, right: 20, bottom: 20),
            child: Column(children: [
              Expanded(
                child: StreamBuilder<QuerySnapshot>(
                  stream:
                      _firestore.collection('chats').doc(widget.chat.id).collection('messages').orderBy('timestamp', descending: true).snapshots(),
                  builder: (context, snapshot) {
                    if (!snapshot.hasData) {
                      return Center(child: CircularProgressIndicator());
                    }

                    return ListView.builder(
                      reverse: true,
                      itemCount: snapshot.data!.docs.length,
                      itemBuilder: (context, index) {
                        final message = snapshot.data!.docs[index];
                        final senderUid = message['sender'];
                        final isFirstMessageInSequence =
                            index == snapshot.data!.docs.length - 1 || snapshot.data!.docs[index + 1]['sender'] != senderUid;
                        final isLastMessageInSequence = index == 0 || snapshot.data!.docs[index - 1]['sender'] != senderUid;

                        return FutureBuilder<DocumentSnapshot>(
                          future: _firestore.collection('users').doc(senderUid).get(),
                          builder: (context, userSnapshot) {
                            if (!userSnapshot.hasData) {
                              return Container();
                            }

                            final userData = userSnapshot.data!.data() as Map<String, dynamic>?;
                            final senderName = userData?['forename'] + " " + userData?['surname'] ?? 'Unknown User';
                            final profilePhotoUrl = userData?['profilePhotoUrl'];

                            return Column(
                              crossAxisAlignment:
                                  senderUid == FirebaseAuth.instance.currentUser!.uid ? CrossAxisAlignment.end : CrossAxisAlignment.start,
                              children: [
                                Row(
                                  mainAxisAlignment:
                                      senderUid == FirebaseAuth.instance.currentUser!.uid ? MainAxisAlignment.end : MainAxisAlignment.start,
                                  children: [
                                    SizedBox(width: 36),
                                    if (isFirstMessageInSequence) Text(senderName),
                                  ],
                                ),
                                Align(
                                  alignment: senderUid == FirebaseAuth.instance.currentUser!.uid ? Alignment.centerRight : Alignment.centerLeft,
                                  child: Row(
                                      mainAxisAlignment:
                                          senderUid == FirebaseAuth.instance.currentUser!.uid ? MainAxisAlignment.end : MainAxisAlignment.start,
                                      children: [
                                        if (senderUid != FirebaseAuth.instance.currentUser!.uid && isLastMessageInSequence && profilePhotoUrl != null)
                                          CircleAvatar(
                                            backgroundImage: NetworkImage(profilePhotoUrl),
                                            radius: 16,
                                          ),
                                        if (senderUid != FirebaseAuth.instance.currentUser!.uid && isLastMessageInSequence && profilePhotoUrl == null)
                                          const CircleAvatar(
                                            radius: 16,
                                            child: Icon(Icons.person),
                                          ),
                                        isLastMessageInSequence ? SizedBox(width: 4) : SizedBox(width: 36),
                                        Container(
                                          constraints: BoxConstraints(maxWidth: 240),
                                          padding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                                          margin: EdgeInsets.symmetric(horizontal: 0, vertical: 4),
                                          decoration: BoxDecoration(
                                            color: Colors.grey.shade300,
                                            gradient: senderUid == FirebaseAuth.instance.currentUser!.uid
                                                ? LinearGradient(
                                                    begin: Alignment.topLeft,
                                                    end: Alignment.bottomRight,
                                                    colors: [Color(0xFF8643FF), Color(0xFF4136F1)],
                                                  )
                                                : null,
                                            borderRadius: BorderRadius.circular(12),
                                          ),
                                          child: Text(
                                            message['text'],
                                            maxLines: 100,
                                            overflow: TextOverflow.ellipsis,
                                            style: TextStyle(
                                              color: senderUid == FirebaseAuth.instance.currentUser!.uid ? Colors.white : Colors.black,
                                            ),
                                          ),
                                        ),
                                      ]),
                                ),
                                if (isLastMessageInSequence) const SizedBox(height: 10)
                              ],
                            );
                          },
                        );
                      },
                    );
                  },
                ),
              ),
              Container(
                  padding: EdgeInsets.symmetric(horizontal: 8),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(20),
                    color: Colors.white,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.1),
                        spreadRadius: 0.5,
                        blurRadius: 10,
                        offset: const Offset(2, 3),
                      ),
                    ],
                  ),
                  child: Row(children: [
                    Expanded(
                        child: TextField(
                      controller: _textController,
                      textCapitalization: TextCapitalization.sentences,
                      decoration: const InputDecoration(
                        hintText: 'Type a message...',
                        filled: true,
                        fillColor: Colors.white,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.all(Radius.circular(20.0)),
                          borderSide: BorderSide.none,
                        ),
                      ),
                    )),
                    Container(
                      height: 40,
                      width: 40,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(30),
                        gradient: LinearGradient(
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          colors: [Color(0xFF8643FF), Color(0xFF4136F1)],
                        ),
                      ),
                      child: IconButton(
                        icon: Icon(
                          Icons.arrow_upward_rounded,
                          color: Colors.white,
                        ),
                        onPressed: () {
                          if (_textController.text.isNotEmpty) {
                            _firestore.collection('chats').doc(widget.chat.id).collection('messages').add({
                              'sender': FirebaseAuth.instance.currentUser!.uid,
                              'text': _textController.text,
                              'timestamp': FieldValue.serverTimestamp(),
                            });

                            _firestore.collection('chats').doc(widget.chat.id).update({
                              'lastMessage': _textController.text,
                              'lastMessageTime': FieldValue.serverTimestamp(),
                            });

                            _textController.clear();

                            newMessageSent();
                          }
                        },
                      ),
                    ),
                  ])),
            ])));
  }
}
