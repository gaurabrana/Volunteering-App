import 'dart:io';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

import '../../DataAccessLayer/PhotoDAO.dart';
import '../Feed.dart';
import '../Leaderboard.dart';
import '../NavBarManager.dart';
import '../Profile.dart';
import '../RecordVolunteering.dart';
import '../SearchVolunteering.dart';

class UploadProfilePhotoPage extends StatefulWidget {
  final GlobalKey<NavigatorState> mainNavigatorKey;
  final GlobalKey<NavigatorState> logInNavigatorKey;

  const UploadProfilePhotoPage({super.key, required this.mainNavigatorKey, required this.logInNavigatorKey});

  @override
  _UploadProfilePhotoPageState createState() {
    return _UploadProfilePhotoPageState();
  }
}

class _UploadProfilePhotoPageState extends State<UploadProfilePhotoPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Builder(builder: (BuildContext context) {
        return Center(
            child: Padding(
                padding: const EdgeInsets.all(20.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    const SizedBox(height: 50),
                    Center(
                      child: Container(
                        constraints: BoxConstraints(maxWidth: (MediaQuery.of(context).size.width) - 100),
                        child: const Text(
                          'Upload profile photo',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 30,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 120),
                    UploadPhotoForm(mainNavigatorKey: widget.mainNavigatorKey, logInNavigatorKey: widget.logInNavigatorKey,),
                    const Spacer(),
                    TextButton(
                      onPressed: () async {
                        showDialog(
                          context: context,
                          builder: (BuildContext context) {
                            return AlertDialog(
                              title: Container(
                                width: MediaQuery.of(context).size.width * 0.8,
                                child: Text(
                                  'Account created successfully!',
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 20,
                                  ),
                                  maxLines: 3,
                                  textAlign: TextAlign.center,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                              contentPadding: EdgeInsets.symmetric(vertical: 10.0, horizontal: 20.0),
                              actions: <Widget>[
                                TextButton(
                                  onPressed: () {
                                    Navigator.of(context).push(MaterialPageRoute(
                                        builder: (context) => NavBarManager(
                                          initialIndex: 0,
                                          searchVolunteeringPage: SearchVolunteeringPage(),
                                          feedPage: FeedPage( mainNavigatorKey: widget.mainNavigatorKey, logInNavigatorKey: widget.logInNavigatorKey),
                                          //profilePage: ,
                                          recordVolunteeringPage: RecordVolunteeringPage(),
                                          leaderboardPage: LeaderboardPage(isTeamStat: false), mainNavigatorKey: widget.mainNavigatorKey, logInNavigatorKey: widget.logInNavigatorKey,
                                        )));
                                  },
                                  child: const Text('OK'),
                                ),
                              ],
                            );
                          },
                        );
                        await Future.delayed(Duration(seconds: 5));
                        Navigator.of(context).push(MaterialPageRoute(
                            builder: (context) => NavBarManager(
                              initialIndex: 0,
                              searchVolunteeringPage: SearchVolunteeringPage(),
                              feedPage: FeedPage( mainNavigatorKey: widget.mainNavigatorKey, logInNavigatorKey: widget.logInNavigatorKey),
                              //profilePage: ,
                              recordVolunteeringPage: RecordVolunteeringPage(),
                              leaderboardPage: LeaderboardPage(isTeamStat: false), mainNavigatorKey: widget.mainNavigatorKey, logInNavigatorKey: widget.logInNavigatorKey,
                            ),
                                ));
                      },
                      child: Text('Skip',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 20,
                            decorationColor: Colors.grey[700],
                          )),
                    ),
                  ],
                )));
      }),
    );
  }
}

class UploadPhotoForm extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => _UploadProfilePhotoFormState();

  final GlobalKey<NavigatorState> mainNavigatorKey;
  final GlobalKey<NavigatorState> logInNavigatorKey;

  const UploadPhotoForm({super.key, required this.mainNavigatorKey, required this.logInNavigatorKey});
}

class _UploadProfilePhotoFormState extends State<UploadPhotoForm> {
  File? _image;

  final picker = ImagePicker();

  Future getImage() async {
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);

    setState(() {
      if (pickedFile != null) {
        _image = File(pickedFile.path);
      } else {
        //print('No image selected.');
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: <Widget>[
        Stack(
          alignment: Alignment.bottomRight,
          children: [
            _image == null
                ? ClipRRect(
                    borderRadius: BorderRadius.circular(30),
                    child: Image.network(
                      PhotoDAO.getDefaultProfilePictureURL(),
                      width: 200,
                      height: 200,
                      fit: BoxFit.cover,
                    ),
                  )
                : ClipRRect(
                    borderRadius: BorderRadius.circular(30),
                    child: Image.file(
                      _image!,
                      width: 200,
                      height: 200,
                      fit: BoxFit.cover,
                    ),
                  ),
            Positioned(
                bottom: 0,
                right: 0,
                child: Transform.translate(
                    offset: const Offset(10, 10),
                    child: Container(
                        height: 50,
                        width: 50,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(20),
                          gradient: const LinearGradient(
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                            colors: [Color(0xFF8643FF), Color(0xFF4136F1)],
                          ),
                        ),
                        child: Center(
                            child: Column(mainAxisAlignment: MainAxisAlignment.center, crossAxisAlignment: CrossAxisAlignment.center, children: [
                          IconButton(
                            onPressed: getImage,
                            icon: const Icon(
                              Icons.add,
                              color: Colors.white,
                              size: 30,
                            ),
                            color: Color(0xFF4136F1),
                            iconSize: 50,
                          ),
                        ])))))
          ],
        ),
        //upload button
        const SizedBox(height: 150),
        Container(
          padding: const EdgeInsets.symmetric(vertical: 20.0),
          alignment: Alignment.topRight,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: <Widget>[
              const Text(
                'Upload',
                textAlign: TextAlign.right,
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 30,
                ),
              ),
              const SizedBox(width: 15.0),
              Container(
                height: 50,
                width: 100,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(30),
                  gradient: const LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [Color(0xFF8643FF), Color(0xFF4136F1)],
                  ),
                ),
                child: IconButton(
                  icon: const Icon(
                    Icons.arrow_forward,
                    color: Colors.white,
                    size: 30,
                  ),
                  onPressed: () async {
                    User? user = FirebaseAuth.instance.currentUser;
                    if (user != null) {
                      String uid = user.uid;
                      String? photoUrl = await PhotoDAO.uploadImageToFirebaseStorage(_image!);
                      if (photoUrl != null) {
                        PhotoDAO.storeImageUrlInFirestore(uid, photoUrl);
                        showDialog(
                          context: context,
                          builder: (BuildContext context) {
                            return AlertDialog(
                              title: const Text('Upload Successful'),
                              content: const Text('Profile picture uploaded successfully!'),
                              actions: <Widget>[
                                TextButton(
                                  onPressed: () {
                                    Navigator.of(context).push(
                                      MaterialPageRoute(
                                        builder: (context) => NavBarManager(
                                          initialIndex: 0,
                                          searchVolunteeringPage: SearchVolunteeringPage(),
                                          feedPage: FeedPage( mainNavigatorKey: widget.mainNavigatorKey, logInNavigatorKey: widget.logInNavigatorKey),
                                          //profilePage: ,
                                          recordVolunteeringPage: RecordVolunteeringPage(),
                                          leaderboardPage: LeaderboardPage(isTeamStat: false), mainNavigatorKey: widget.mainNavigatorKey, logInNavigatorKey: widget.logInNavigatorKey,
                                        ),
                                      ),
                                    );
                                  },
                                  child: const Text('OK'),
                                ),
                              ],
                            );
                          },
                        );
                      } else {
                        //print('Photo URL is null');
                      }
                    } else {
                      //print('Error uploading photo: No user is currently logged in.');
                    }
                  },
                ),
              )
            ],
          ),
        ),
      ],
    );
  }

  @override
  void dispose() {
    super.dispose();
  }
}
//todo also maybe allow them to take a photo rather than upload from library only.
