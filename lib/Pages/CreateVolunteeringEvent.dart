import 'dart:io';

import 'package:HeartOfExperian/DataAccessLayer/PhotoDAO.dart';
import 'package:HeartOfExperian/Pages/CustomWidgets/BackButton.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';

import '../DataAccessLayer/VolunteeringEventDAO.dart';
import '../DataAccessLayer/VolunteeringHistoryDAO.dart';
import '../Models/VolunteeringEvent.dart';
import 'CustomWidgets/FormInputFields/EventDescriptionInputField.dart';
import 'CustomWidgets/FormInputFields/EventLocationInputField.dart';
import 'CustomWidgets/FormInputFields/EventTitleInputField.dart';
import 'CustomWidgets/FormInputFields/EventWebsiteInputField.dart';
import 'Feed.dart';
import 'Leaderboard.dart';
import 'NavBarManager.dart';
import 'Profile.dart';
import 'RecordVolunteering.dart';
import 'SearchVolunteering.dart';

class CreateVolunteeringEventPage extends StatefulWidget {
  CreateVolunteeringEventPage({Key? key}) : super(key: key);

  @override
  _CreateVolunteeringEventPageState createState() {
    return _CreateVolunteeringEventPageState();
  }
}

class _CreateVolunteeringEventPageState extends State<CreateVolunteeringEventPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Builder(builder: (BuildContext context) {
        return SingleChildScrollView(
            child: Center(
                child: Padding(
                    padding: const EdgeInsets.only(top: 50, left: 30, right: 30, bottom: 0),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: <Widget>[
                        Row(children: [
                          GoBackButton(),
                          const SizedBox(width: 20),
                          const Text('Create event',
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 30,
                              )),
                        ]),
                        _CreateVolunteeringEventForm(),
                      ],
                    ))));
      }),
    );
  }
}

class _CreateVolunteeringEventForm extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => _CreateVolunteeringEventFormState();
}

class _CreateVolunteeringEventFormState extends State<_CreateVolunteeringEventForm> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _locationController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  final TextEditingController _websiteController = TextEditingController();
  DateTime _date = DateTime.now();
  List<String> types = VolunteeringHistoryDAO.volunteeringTypesWithOther;
  int selectedTypeIndex = 0;
  List<File> _images = <File>[];
  bool _savingInProgress = false;
  bool _isHappyToBeContacted = false;
  bool online = true;
  late LocationInputInputField locationInputField;

  @override
  void initState() {
    super.initState();
    locationInputField = LocationInputInputField(locationController: _locationController);
  }

  @override
  Widget build(context) {
    return Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.start,
          children: <Widget>[
            SizedBox(height: 10),
            const Text(
              'Title',
              textAlign: TextAlign.left,
              style: TextStyle(
                fontWeight: FontWeight.w700,
                fontSize: 15,
                decorationColor: Colors.black,
              ),
            ),
            EventTitleInputField(controller: _nameController),
            SizedBox(height: 10),
            const Text(
              'Date',
              textAlign: TextAlign.left,
              style: TextStyle(
                fontWeight: FontWeight.w700,
                fontSize: 15,
                decorationColor: Colors.black,
              ),
            ),
            buildDatePicker(context),
            SizedBox(height: 10),
            buildOnlineSwitch(context),
            !online ? SizedBox(height: 10) : Container(),
            !online
                ? const Text(
                    'Location',
                    textAlign: TextAlign.left,
                    style: TextStyle(
                      fontWeight: FontWeight.w700,
                      fontSize: 15,
                      decorationColor: Colors.black,
                    ),
                  )
                : Container(),
            !online ? locationInputField : Container(),
            SizedBox(height: 10),
            const Text(
              //todo add info buttons
              'Description',
              textAlign: TextAlign.left,
              style: TextStyle(
                fontWeight: FontWeight.w700,
                fontSize: 15,
                decorationColor: Colors.black,
              ),
            ),
            EventDescriptionInputField(controller: _descriptionController),
            SizedBox(height: 10),
            const Text(
              'Type',
              textAlign: TextAlign.left,
              style: TextStyle(
                fontWeight: FontWeight.w700,
                fontSize: 15,
                decorationColor: Colors.black,
              ),
            ),
            buildVolunteeringTypeOptions(context),
            SizedBox(height: 10),
            const Text(
              'Website',
              textAlign: TextAlign.left,
              style: TextStyle(
                fontWeight: FontWeight.w700,
                fontSize: 15,
                decorationColor: Colors.black,
              ),
            ),
            EventWebsiteInputField(controller: _websiteController),
            SizedBox(height: 10),
            const Text(
              'Photos',
              textAlign: TextAlign.left,
              style: TextStyle(
                fontWeight: FontWeight.w700,
                fontSize: 15,
                decorationColor: Colors.black,
              ),
            ),
            IconButton(
              // todo make the button better
              onPressed: _getImage,
              tooltip: 'Pick Image',
              icon: Icon(Icons.add_a_photo),
            ),
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: _images.map((image) => _buildImagePreview(image)).toList(),
              ),
            ),
            SizedBox(height: 10),
            buildContactSwitch(context),
            SizedBox(height: 10),
            buildSaveButton(context),
            SizedBox(height: 20),
          ],
        ));
  }

  Widget buildSaveButton(BuildContext context) {
    return Container(
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
                uploadEvent();
              },
              child: Container(
                height: 40,
                width: 400,
                alignment: Alignment.center,
                child: _savingInProgress
                    ? const CircularProgressIndicator(
                        valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                      )
                    : const Text("Upload",
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontWeight: FontWeight.w600,
                          fontSize: 20,
                          color: Colors.white,
                        )), // todo could i have a cool animation here
              ))
        ])));
  }

  Widget buildDatePicker(BuildContext context) {
    return GestureDetector(
      onTap: () {
        _selectDate(context);
      },
      child: Container(
        height: 60,
        padding: const EdgeInsets.all(10),
        margin: const EdgeInsets.symmetric(vertical: 10),
        decoration: BoxDecoration(
          color: Colors.grey.shade100,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              "${DateFormat('dd/MM/yy').format(_date)}",
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey.shade700,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now().add(Duration(days: 1)),
      firstDate: DateTime.now().add(Duration(days: 1)),
      lastDate: DateTime(2030, 1),
    );
    setState(() {
      if (picked != null) _date = picked;
    });
    //if (picked != null) print({picked.toString()});
  }

  Widget buildVolunteeringTypeOptions(BuildContext context) {
    List<Widget> widgets = [];

    for (int i = 0; i < types.length; i++) {
      widgets.add(TextButton(
        onPressed: () {
          setState(() {
            selectedTypeIndex = i;
          });
        },
        style: ButtonStyle(
          backgroundColor: MaterialStateProperty.resolveWith<Color>((Set<MaterialState> states) {
            return Colors.white;
          }),
          textStyle: MaterialStateProperty.resolveWith<TextStyle>((Set<MaterialState> states) {
            return selectedTypeIndex == i
                ? const TextStyle(color: Colors.black, fontWeight: FontWeight.bold)
                : TextStyle(color: Colors.grey.shade600); // Set the text color and style based on selection
          }),
          side: MaterialStateProperty.resolveWith<BorderSide>((Set<MaterialState> states) {
            return selectedTypeIndex == i
                ? const BorderSide(color: Colors.purple, width: 2.0)
                : const BorderSide(color: Colors.grey, width: 1.0); // Set the border color and width based on selection
          }),
          shape: MaterialStateProperty.all<RoundedRectangleBorder>(
            RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20.0), // Set the border radius
            ),
          ),
        ),
        child: Text(
          types[i],
          style: selectedTypeIndex == i
              ? const TextStyle(color: Colors.black, fontWeight: FontWeight.bold, fontFamily: 'Poppins')
              : TextStyle(color: Colors.grey.shade600, fontFamily: 'Poppins'),
        ),
      ));
    }
    ;

    return Wrap(
      spacing: 10.0, // spacing between buttons
      runSpacing: 2.0, // spacing between rows
      children: widgets,
    );
  }

  Future<void> _getImage() async {
    final picker = ImagePicker();
    final images = await picker.pickMultiImage();
    setState(() {
      if (images != null) {
        for (var image in images) {
          _images.add(File(image.path));
        }
      } else {
        print('No images selected.');
      }
    });
  }

  Widget _buildImagePreview(File image) {
    return Stack(
      children: [
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: Image.file(
            image,
            width: 100,
            height: 100,
            fit: BoxFit.cover,
          ),
        ),
        Positioned(
          top: 0,
          right: 0,
          child: GestureDetector(
            onTap: () {
              _removeImage(image);
            },
            child: Container(
              padding: EdgeInsets.all(3),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.grey,
              ),
              child: Icon(
                Icons.close,
                color: Colors.white,
                size: 17,
              ),
            ),
          ),
        ),
      ],
    );
  }

  void _removeImage(File image) {
    setState(() {
      _images.remove(image);
    });
  }

  Widget buildOnlineSwitch(BuildContext context) {
    return Row(
      children: [
        const Text('Online event?',
            style: TextStyle(
              fontWeight: FontWeight.w500,
              fontSize: 15,
            )),
        const Spacer(),
        Switch(
          value: online,
          onChanged: (value) {
            setState(() {
              online = value;
            });
          },
        ),
      ],
    );
  }

  Widget buildContactSwitch(BuildContext context) {
    return Row(
      children: [
        SizedBox(width: 20),
        Column(children: [
          Text(
            'Are you happy to be',
            style: TextStyle(
              fontWeight: FontWeight.w500,
              fontSize: 12,
            ),
          ),
          Text(
            'contacted about the event?',
            style: TextStyle(
              fontWeight: FontWeight.w500,
              fontSize: 12,
            ),
          ),
        ]),
        Spacer(), // Add a spacer to push the switch to the end
        Switch(
          value: _isHappyToBeContacted,
          onChanged: (value) {
            setState(() {
              _isHappyToBeContacted = value;
            });
          },
        ),
        SizedBox(width: 20), // Add some space after the switch
      ],
    );
  }

  Future<void> uploadEvent() async {
    setState(() {
      _savingInProgress = true;
    });
    //validateForm(); todo validate
    // if (!_durationValid || !_causeValid){
    //   return;
    // }
    try {
      List<String> photoUrls = [];
      for (var image in _images) {
        String? url = await PhotoDAO.uploadImageToFirebaseStorage(image!);
        photoUrls.add(url!);
      }

      if (photoUrls.isEmpty) {
        photoUrls.add(PhotoDAO.defaultVolunteeringPhotoURL);
      }

      if (!online) {
        await locationInputField.getLocationCoordinates();

        if (!locationInputField.locationFound) {
          setState(() {
            _savingInProgress = false;
          });
          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
            content: Text('Error: Location not found'),
          ));
          return;
        }
      }

      VolunteeringEvent volunteeringEvent = VolunteeringEvent(
        date: _date,
        type: types[selectedTypeIndex],
        name: _nameController.text,
        organiserContactConsent: _isHappyToBeContacted,
        location: !online ? _locationController.text : "Online",
        description: _descriptionController.text,
        website: _websiteController.text,
        organiserUID: FirebaseAuth.instance.currentUser!.uid,
        photoUrls: photoUrls,
        longitude: !online ? locationInputField.longitude! : 0,
        latitude: !online ? locationInputField.latitude! : 0,
        online: online,
      );
      VolunteeringEventDAO.addVolunteeringEvent(volunteeringEvent);
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        content: Text('Volunteering event created successfully'),
      ));
    } catch (e) {
      print(e);
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        content: Text('Error while uploading volunteering event'),
      ));
    }
    setState(() {
      _savingInProgress = false;
    });
  }

  @override
  void dispose() {
    _locationController.dispose();
    _descriptionController.dispose();
    _nameController.dispose();
    _websiteController.dispose();
    super.dispose();
  }
}
