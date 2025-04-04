import 'dart:io';

import 'package:HeartOfExperian/Pages/Settings/Settings.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

import '../../DataAccessLayer/PhotoDAO.dart';
import '../../DataAccessLayer/UserDAO.dart';
import '../../Models/UserDetails.dart';
import '../CustomWidgets/BackButton.dart';
import '../CustomWidgets/FormInputFields/EmailInputField.dart';
import '../CustomWidgets/FormInputFields/ForenameInputField.dart';
import '../CustomWidgets/FormInputFields/SurnameInputField.dart';

class EditProfilePage extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => EditProfilePageState();
}

class EditProfilePageState extends State<EditProfilePage> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  String _photoURL = "";
  String _currentForename = "";
  String _currentSurname = "";
  String? _currentEmail = "";
  bool isPhotoLoading = true;
  bool isNameLoading = true;
  bool isEmailLoading = true;
  bool photoChanged = false;
  bool _savingInProgress = false;
  late TextEditingController _forenameController;
  late TextEditingController _surnameController;
  late TextEditingController _emailController;

  File? _image;

  final picker = ImagePicker();

  Future getImage() async {
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);

    setState(() {
      if (pickedFile != null) {
        _image = File(pickedFile.path);
        photoChanged = true;
      } else {
        //print('No image selected.');
      }
    });
  }

  @override
  void initState() {
    super.initState();
    _fetchData();
  }

  void initialiseData() {
    setState(() {
      _photoURL = "";
      _currentForename = "";
      _currentSurname = "";
      _currentEmail = "";
      isPhotoLoading = true;
      isNameLoading = true;
      isEmailLoading = true;
      photoChanged = false;
      _savingInProgress = false;
    });
  }

  Future<void> _fetchData() async {
    initialiseData();
    await _fetchProfilePhoto();
    await _fetchNameAndEmail();
  }

  Future<void> _fetchProfilePhoto() async {
    FirebaseAuth auth = FirebaseAuth.instance;
    User? user = auth.currentUser;

    try {
      String photoURL = await PhotoDAO.getUserProfilePhotoUrlFromFirestore(user?.uid);
      setState(() {
        _photoURL = photoURL;
        isPhotoLoading = false;
      });
    } catch (e) {
      //print('Error fetching teams: $e');
    }
  }

  Future<void> _fetchNameAndEmail() async {
    try {
      FirebaseAuth auth = FirebaseAuth.instance;
      User? user = auth.currentUser;

      UserDetails? userDetails = await UserDAO.getUserDetails(user?.uid);
      setState(() {
        if (userDetails?.forename != null && userDetails?.surname != null) {
          _currentForename = userDetails!.forename;
          _currentSurname = userDetails!.surname;
          _currentEmail = userDetails!.email;
          _forenameController = TextEditingController(text: _currentForename);
          _surnameController = TextEditingController(text: _currentSurname);
          _emailController = TextEditingController(text: _currentEmail?.replaceAll('@experian.com', ''));
        }
        isNameLoading = false;
        isEmailLoading = false;
      });
    } catch (e) {
      //print('Error fetching name: $e');
    }
  }

  @override
  Widget build(context) {
    return RefreshIndicator(
        onRefresh: _fetchData,
        child: SingleChildScrollView(
          child: Padding(
              padding: const EdgeInsets.only(right: 20.0, top: 35.0, left: 20.0),
              child: Column(children: <Widget>[
                const SizedBox(height: 10.0),
                GoBackButton(),
                Container(
                  child: isPhotoLoading
                      ? const CircularProgressIndicator()
                      : Stack(
                          alignment: Alignment.bottomRight,
                          children: [
                            ClipRRect(
                              borderRadius: BorderRadius.circular(20),
                              child: (photoChanged)
                                  ? Image.file(
                                      _image!,
                                      width: 150,
                                      height: 150,
                                      fit: BoxFit.cover,
                                    )
                                  : Image.network(
                                      width: 150,
                                      height: 150,
                                      fit: BoxFit.cover,
                                      _photoURL,
                                      loadingBuilder: (BuildContext context, Widget child, ImageChunkEvent? loadingProgress) {
                                        if (loadingProgress == null) {
                                          return child;
                                        } else {
                                          return const CircularProgressIndicator();
                                        }
                                      },
                                      errorBuilder: (BuildContext context, Object exception, StackTrace? stackTrace) {
                                        return const Text('Failed to load image');
                                      },
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
                                            child: Column(
                                                mainAxisAlignment: MainAxisAlignment.center,
                                                crossAxisAlignment: CrossAxisAlignment.center,
                                                children: [
                                              IconButton(
                                                onPressed: getImage,
                                                icon: const Icon(
                                                  Icons.mode_edit_outline_outlined,
                                                  color: Colors.white,
                                                  size: 30,
                                                ),
                                                color: Color(0xFF4136F1),
                                                iconSize: 50,
                                              ),
                                            ])))))
                          ],
                        ),
                ),
                const SizedBox(height: 20),
                Form(
                  key: _formKey,
                  child: Column(children: [
                    Row(children: [
                      Container(
                        child: isNameLoading
                            ? const CircularProgressIndicator()
                            : ForenameInputField(
                                controller: _forenameController,
                              ),
                      ),
                      Container(
                        child: isNameLoading
                            ? const CircularProgressIndicator()
                            : SurnameInputField(
                                controller: _surnameController,
                              ),
                      ),
                    ]),
                    Container(
                        child: isEmailLoading
                            ? const CircularProgressIndicator()
                            : EmailInputField(controller: _emailController, focusNode: FocusNode())),
                  ]),
                ),
                Container(
                    padding: const EdgeInsets.all(10),
                    child: Container(
                        alignment: Alignment.center,
                        height: 60,
                        width: 500,
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
                                await updateProfileDetails();
                              },
                              child: Container(
                                height: 40,
                                width: 310,
                                alignment: Alignment.center,
                                child: _savingInProgress
                                    ? const CircularProgressIndicator(
                                        valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                                      )
                                    : const Text("Save",
                                        textAlign: TextAlign.center,
                                        style: TextStyle(
                                          fontWeight: FontWeight.w600,
                                          fontSize: 20,
                                          color: Colors.white,
                                        )), // todo could i have a cool animation here
                              )),
                        ]))))
              ])),
        ));
  }

  Future<void> updateProfileDetails() async {
    String updateError = "";
    setState(() {
      _savingInProgress = true;
    });
    try {
      User? user = FirebaseAuth.instance.currentUser;
      if (user != null) {
        if (photoChanged) {
          String uid = user.uid;
          String? photoUrl = await PhotoDAO.uploadImageToFirebaseStorage(_image!);
          if (photoUrl != null) {
            PhotoDAO.storeImageUrlInFirestore(uid, photoUrl);
          } else {
            updateError = "Couldn't update profile picture";
          }
        }
        // if (_emailController.text != _currentEmail) {
        //   await user.updateEmail(_emailController.text); //todo EMAIL UPDATE DOESNT WORK
        // }
        if (_forenameController.text != _currentForename || _surnameController.text != _currentSurname) {
          UserDetails? userDetails = await UserDAO.getUserDetails(user.uid);
          if (userDetails != null) {
            await UserDAO.updateName(userDetails, _forenameController.text, _surnameController.text);
          } else {
            //print('Error updating details: No user found.');
          }
        }
        setState(() {
          _savingInProgress = false;
        });
      } else {
        updateError = 'Error updating details: No user is currently logged in.';
      }
    } catch (e) {
      updateError = 'Error updating details';
      //print(e);
    }
    setState(() {
      _savingInProgress = false;
    });
    if (updateError == "") {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        content: Text('Details updated successfully'),
      ));
    } else {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text(updateError),
      ));
    }
  }
}
