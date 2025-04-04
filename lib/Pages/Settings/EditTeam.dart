import 'dart:io';

import 'package:HeartOfExperian/Pages/CustomWidgets/FormInputFields/NameInputField.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

import '../../DataAccessLayer/PhotoDAO.dart';
import '../../DataAccessLayer/TeamDAO.dart';
import '../CustomWidgets/BackButton.dart';

class EditTeamPage extends StatefulWidget {
  String teamName;
  String teamId;

  EditTeamPage({Key? key, required this.teamName, required this.teamId}) : super(key: key);

  @override
  State<StatefulWidget> createState() => EditTeamPageState();
}

class EditTeamPageState extends State<EditTeamPage> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  String _photoURL = "";
  bool isPhotoLoading = true;
  bool photoChanged = false;
  bool _savingInProgress = false;
  final TextEditingController _nameController = TextEditingController();
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
    _nameController.text = widget.teamName;
    _fetchProfilePhoto();
  }

  Future<void> _fetchProfilePhoto() async {
    try {
      String photoURL = await PhotoDAO.getTeamProfilePhotoUrlFromFirestore(widget.teamId);
      setState(() {
        _photoURL = photoURL;
        isPhotoLoading = false;
      });
    } catch (e) {
      //print('Error fetching team photo: $e');
    }
  }

  @override
  Widget build(context) {
    return Scaffold(
        body: SingleChildScrollView(
            child: Padding(
      padding: const EdgeInsets.only(right: 25.0, top: 35.0, left: 25.0),
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
                                  borderRadius: BorderRadius.circular(10),
                                  gradient: const LinearGradient(
                                    begin: Alignment.topLeft,
                                    end: Alignment.bottomRight,
                                    colors: [Color(0xFF8643FF), Color(0xFF4136F1)],
                                  ),
                                ),
                                child: Center(
                                    child:
                                        Column(mainAxisAlignment: MainAxisAlignment.center, crossAxisAlignment: CrossAxisAlignment.center, children: [
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
            NameInputField(
              controller: _nameController,
              focusNode: FocusNode(),
            ),
          ]),
        ),
        const SizedBox(height: 10),
        Container(
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
                    String updateError = "";
                    setState(() {
                      _savingInProgress = true;
                    });
                    try {
                      if (photoChanged) {
                        String? photoUrl = await PhotoDAO.uploadImageToFirebaseStorage(_image!);
                        if (photoUrl != null) {
                          PhotoDAO.storeTeamImageUrlInFirestore(widget.teamId, photoUrl);
                        } else {
                          updateError = "Couldn't update profile picture";
                        }
                      }
                      if (_nameController.text != widget.teamName) {
                        await TeamDAO.updateName(widget.teamId, _nameController.text);
                        widget.teamName = _nameController.text;
                      }
                      setState(() {
                        _savingInProgress = false;
                      });
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
                            )),
                  )),
            ])))
      ]),
    )));
  }
}
