import 'dart:io';

import 'package:HeartOfExperian/Pages/Settings/SharedPreferences.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

import '../../DataAccessLayer/PhotoDAO.dart';
import '../../DataAccessLayer/UserDAO.dart';
import '../../Models/UserDetails.dart';
import '../../constants/enums.dart';
import '../CustomWidgets/BackButton.dart';
import '../CustomWidgets/FormInputFields/EmailInputField.dart';
import '../CustomWidgets/FormInputFields/UsernameInputField.dart';

class EditProfilePage extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => EditProfilePageState();
}

class EditProfilePageState extends State<EditProfilePage> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  String _photoURL = "";
  String _currentName = "";
  String? _currentEmail = "";
  bool isPhotoLoading = true;
  bool isNameLoading = true;
  bool isEmailLoading = true;
  bool photoChanged = false;
  bool _savingInProgress = false;
  late TextEditingController _nameController;
  late TextEditingController _emailController;
  // Controllers to handle text inputs
  final TextEditingController _missionController = TextEditingController();
  final TextEditingController _activitiesController = TextEditingController();
  final TextEditingController _projectsController = TextEditingController();
  final TextEditingController _benefactorsController = TextEditingController();
  final TextEditingController _certificateController = TextEditingController();

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

  UserDetails? _userDetails; // Store the user details
  bool _isLoading = true; // Loading state

  @override
  void initState() {
    super.initState();
    _fetchData();
  }

  void initialiseData() {
    setState(() {
      _photoURL = "";
      _currentName = "";
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
    await _fetchUserDetails();
    await _fetchProfilePhoto();
    await _fetchNameAndEmail();
  }

  Future<void> _fetchProfilePhoto() async {
    FirebaseAuth auth = FirebaseAuth.instance;
    User? user = auth.currentUser;

    try {
      String photoURL =
          await PhotoDAO.getUserProfilePhotoUrlFromFirestore(user?.uid);
      setState(() {
        _photoURL = photoURL;
        isPhotoLoading = false;
      });
    } catch (e) {
      //print('Error fetching teams: $e');
    }
  }

  Future<void> _fetchUserDetails() async {
    try {
      UserDetails? userDetails =
          await SignInSharedPreferences().getCurrentUserDetails();
      setState(() {
        _userDetails = userDetails;
        _isLoading = false; // Data fetched, no longer loading
      });
      if (userDetails != null && userDetails.role == UserRole.organisation) {
        _fetchOrganisationDetails(userDetails.UID);
      }
    } catch (e) {
      setState(() {
        _isLoading = false; // Even if there's an error, stop loading
      });
      print('Error fetching user details: $e');
    }
  }

  void _fetchOrganisationDetails(String userId) async {
    var details = await UserDAO().fetchOrganisationDetails(userId);
    _missionController.text = details!['mission'];
    _activitiesController.text = details['activities'];
    _projectsController.text = details['completedProjects'];
    _benefactorsController.text = details['benefactors'];
    _certificateController.text = details['certificate'];
  }

  Future<void> _fetchNameAndEmail() async {
    try {
      UserDetails? userDetails =
          await SignInSharedPreferences().getCurrentUserDetails();
      setState(() {
        if (userDetails?.name != null) {
          _currentName = userDetails!.name;
          _currentEmail = userDetails.email;
          _nameController = TextEditingController(text: _currentName);
          _emailController = TextEditingController(
              text: _currentEmail?.replaceAll('@experian.com', ''));
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
    return Scaffold(
      body: RefreshIndicator(
          onRefresh: _fetchData,
          child: SingleChildScrollView(
            child: Padding(
                padding:
                    const EdgeInsets.only(right: 20.0, top: 35.0, left: 20.0),
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
                                        loadingBuilder: (BuildContext context,
                                            Widget child,
                                            ImageChunkEvent? loadingProgress) {
                                          if (loadingProgress == null) {
                                            return child;
                                          } else {
                                            return const CircularProgressIndicator();
                                          }
                                        },
                                        errorBuilder: (BuildContext context,
                                            Object exception,
                                            StackTrace? stackTrace) {
                                          return const Text(
                                              'Failed to load image');
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
                                            borderRadius:
                                                BorderRadius.circular(20),
                                            gradient: const LinearGradient(
                                              begin: Alignment.topLeft,
                                              end: Alignment.bottomRight,
                                              colors: [
                                                Color(0xFF8643FF),
                                                Color(0xFF4136F1)
                                              ],
                                            ),
                                          ),
                                          child: Center(
                                              child: Column(
                                                  mainAxisAlignment:
                                                      MainAxisAlignment.center,
                                                  crossAxisAlignment:
                                                      CrossAxisAlignment.center,
                                                  children: [
                                                IconButton(
                                                  onPressed: getImage,
                                                  icon: const Icon(
                                                    Icons
                                                        .mode_edit_outline_outlined,
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
                      Container(
                        child: isNameLoading
                            ? const CircularProgressIndicator()
                            : UserNameInputField(
                                controller: _nameController,
                              ),
                      ),
                      Container(
                          child: isEmailLoading
                              ? const CircularProgressIndicator()
                              : EmailInputField(
                                  isReadOnly: true,
                                  controller: _emailController,
                                  focusNode: FocusNode())),
                      if (!_isLoading &&
                          _userDetails != null &&
                          _userDetails!.role == UserRole.organisation)
                        ...buildOrganisationExtraDetails(),
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
                              child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  children: [
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
                                              valueColor:
                                                  AlwaysStoppedAnimation<Color>(
                                                      Colors.white),
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
          )),
    );
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
          String? photoUrl =
              await PhotoDAO.uploadImageToFirebaseStorage(_image!);
          if (photoUrl != null) {
            PhotoDAO.storeImageUrlInFirestore(uid, photoUrl);
          } else {
            updateError = "Couldn't update profile picture";
          }
        }
        // if (_emailController.text != _currentEmail) {
        //   await user.updateEmail(_emailController.text); //todo EMAIL UPDATE DOESNT WORK
        // }
        if (_nameController.text != _currentName) {
          if (_userDetails != null) {
            await UserDAO().updateName(_userDetails!, _nameController.text);
            UserDetails? userDetailsUpdated =
                await UserDAO().getUserDetails(user.uid);
            if (userDetailsUpdated != null) {
              SignInSharedPreferences().setCurrentUserDetails(userDetailsUpdated);
            }
          } else {
            //print('Error updating details: No user found.');
          }
        }

        if (_userDetails != null &&
            _userDetails!.role == UserRole.organisation) {
          await UserDAO().storeOrganisationDetails(
              userId: user.uid,
              mission: _missionController.text,
              activities: _activitiesController.text,
              projects: _projectsController.text,
              benefactors: _benefactorsController.text,
              certificate: _certificateController.text);
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

  buildOrganisationExtraDetails() {
    return [
      SizedBox(height: 20),
      // Mission Field
      Container(
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              spreadRadius: 0.5,
              blurRadius: 10,
              offset: const Offset(2, 3),
            ),
          ],
        ),
        child: TextFormField(
          controller: _missionController,
          decoration: InputDecoration(
            hintText: 'Mission',
            hintStyle: TextStyle(
              color: Colors.grey,
            ),
            filled: true,
            fillColor: Colors.white,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.all(Radius.circular(25.0)),
              borderSide: BorderSide.none,
            ),
            focusedBorder: OutlineInputBorder(
              borderSide: BorderSide(color: Colors.grey.shade500, width: 2.0),
              borderRadius: BorderRadius.circular(25.0),
            ),
            errorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(25.0),
              borderSide: BorderSide(
                color: Colors.red.shade700,
                width: 2.0,
              ),
            ),
          ),
          maxLines: 3,
          validator: (value) {
            if (value == null || value.isEmpty) {
              return 'Please enter the mission';
            }
            return null;
          },
        ),
      ),
      SizedBox(height: 20),

      // Activities Field
      Container(
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              spreadRadius: 0.5,
              blurRadius: 10,
              offset: const Offset(2, 3),
            ),
          ],
        ),
        child: TextFormField(
          controller: _activitiesController,
          decoration: InputDecoration(
            hintText: 'Main Activities',
            hintStyle: TextStyle(
              color: Colors.grey,
            ),
            filled: true,
            fillColor: Colors.white,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.all(Radius.circular(25.0)),
              borderSide: BorderSide.none,
            ),
            focusedBorder: OutlineInputBorder(
              borderSide: BorderSide(color: Colors.grey.shade500, width: 2.0),
              borderRadius: BorderRadius.circular(25.0),
            ),
            errorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(25.0),
              borderSide: BorderSide(
                color: Colors.red.shade700,
                width: 2.0,
              ),
            ),
          ),
          maxLines: 3,
          validator: (value) {
            if (value == null || value.isEmpty) {
              return 'Please enter the main activities';
            }
            return null;
          },
        ),
      ),

      SizedBox(height: 20),

      // Projects Field
      Container(
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              spreadRadius: 0.5,
              blurRadius: 10,
              offset: const Offset(2, 3),
            ),
          ],
        ),
        child: TextFormField(
          controller: _projectsController,
          decoration: InputDecoration(
            hintText: 'Completed Projects',
            hintStyle: TextStyle(
              color: Colors.grey,
            ),
            filled: true,
            fillColor: Colors.white,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.all(Radius.circular(25.0)),
              borderSide: BorderSide.none,
            ),
            focusedBorder: OutlineInputBorder(
              borderSide: BorderSide(color: Colors.grey.shade500, width: 2.0),
              borderRadius: BorderRadius.circular(25.0),
            ),
            errorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(25.0),
              borderSide: BorderSide(
                color: Colors.red.shade700,
                width: 2.0,
              ),
            ),
          ),
          maxLines: 3,
          validator: (value) {
            if (value == null || value.isEmpty) {
              return 'Please enter completed projects';
            }
            return null;
          },
        ),
      ),
      SizedBox(height: 20),

      Container(
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              spreadRadius: 0.5,
              blurRadius: 10,
              offset: const Offset(2, 3),
            ),
          ],
        ),
        child: TextFormField(
          controller: _benefactorsController,
          decoration: InputDecoration(
            hintText: 'Number of Benefactors',
            hintStyle: TextStyle(
              color: Colors.grey,
            ),
            filled: true,
            fillColor: Colors.white,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.all(Radius.circular(25.0)),
              borderSide: BorderSide.none,
            ),
            focusedBorder: OutlineInputBorder(
              borderSide: BorderSide(color: Colors.grey.shade500, width: 2.0),
              borderRadius: BorderRadius.circular(25.0),
            ),
            errorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(25.0),
              borderSide: BorderSide(
                color: Colors.red.shade700,
                width: 2.0,
              ),
            ),
          ),
          keyboardType: TextInputType.number,
          validator: (value) {
            if (value == null || value.isEmpty) {
              return 'Please enter the number of benefactors';
            }
            return null;
          },
        ),
      ),
      SizedBox(height: 20),
      // Benefactors Field
      Container(
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              spreadRadius: 0.5,
              blurRadius: 10,
              offset: const Offset(2, 3),
            ),
          ],
        ),
        child: TextFormField(
          controller: _certificateController,
          decoration: InputDecoration(
            hintText: 'Certificate Records',
            hintStyle: TextStyle(
              color: Colors.grey,
            ),
            filled: true,
            fillColor: Colors.white,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.all(Radius.circular(25.0)),
              borderSide: BorderSide.none,
            ),
            focusedBorder: OutlineInputBorder(
              borderSide: BorderSide(color: Colors.grey.shade500, width: 2.0),
              borderRadius: BorderRadius.circular(25.0),
            ),
            errorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(25.0),
              borderSide: BorderSide(
                color: Colors.red.shade700,
                width: 2.0,
              ),
            ),
          ),
          maxLines: 3,
          validator: (value) {
            if (value == null || value.isEmpty) {
              return 'Please enter certificates records';
            }
            return null;
          },
        ),
      ),
    ];
  }
}
