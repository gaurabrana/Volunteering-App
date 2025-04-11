import 'package:VolunteeringApp/DataAccessLayer/VolunteeringHistoryDAO.dart';
import 'package:VolunteeringApp/Models/VolunteeringEventRegistration.dart';
import 'package:VolunteeringApp/Models/VolunteeringHistory.dart';
import 'package:autocomplete_textfield/autocomplete_textfield.dart';
import 'package:confetti/confetti.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../Models/VolunteeringEvent.dart';

class RecordVolunteeringPage extends StatefulWidget {
  final String userId;
  final String userName;
  final String eventId;
  final VolunteeringEvent event;
  final VolunteeringEventRegistration registration;
  const RecordVolunteeringPage(
      {super.key,
      required this.userId,
      required this.eventId,
      required this.event,
      required this.registration,
      required this.userName});

  @override
  State<StatefulWidget> createState() => RecordVolunteeringPageState();
}

class RecordVolunteeringPageState extends State<RecordVolunteeringPage> {
  int _hours = 0;
  int _minutes = 0;
  DateTime _date = DateTime.now();
  bool _savingInProgress = false;
  final GlobalKey<AutoCompleteTextFieldState<String>> _autocompleteFormKey =
      GlobalKey();
  bool _durationValid = true;
  bool _roleValid = true;
  bool _taskValid = true;

  String _durationErrorMessage = "";
  final TextEditingController _roleController = TextEditingController();
  final TextEditingController _taskController = TextEditingController();

  @override
  void initState() {
    super.initState();
    intialiseData();
  }

  void intialiseData() {
    _hours = 0;
    _minutes = 0;
    _date = widget.registration!.assignedStartDate!;
    _savingInProgress = false;
    _durationValid = true;
    _durationErrorMessage = "";
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(context) {
    return Scaffold(
      appBar: AppBar(
        title: buildTitle(context),
      ),
      body: Padding(
          padding:
              const EdgeInsets.only(top: 10, left: 30, right: 30, bottom: 0),
          child: SingleChildScrollView(
              child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                buildRecordVolunteeringForm(context),
              ]))),
    );
  }

  Widget buildTitle(BuildContext context) {
    return Text(
      'Record volunteering',
      textAlign: TextAlign.center,
      style: TextStyle(
        fontWeight: FontWeight.bold,
        fontSize: 24,
        decorationColor: Colors.black,
      ),
    );
  }

  Widget buildRecordVolunteeringForm(BuildContext context) {
    // todo maybe add little 'i' icons which come up with more info on the fields.
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Text(
        "Event: ${widget.event.name}",
        style: TextStyle(
          fontWeight: FontWeight.bold,
          fontSize: 16,
        ),
      ),
      Text(
        "Volunteer Name: ${widget.userName}",
        style: TextStyle(
          fontSize: 16,
        ),
      ),
      const SizedBox(height: 20),
      const Text(
        "Duration",
        style: TextStyle(
          fontWeight: FontWeight.bold,
          fontSize: 16,
        ),
      ),
      buildDurationPicker(context),
      !_durationValid
          ? Text(
              _durationErrorMessage,
              style: TextStyle(
                fontWeight: FontWeight.normal,
                fontSize: 14,
                color: Colors.red.shade600,
              ),
            )
          : Container(),
      const SizedBox(height: 10),
      const Text(
        "Date",
        style: TextStyle(
          fontWeight: FontWeight.bold,
          fontSize: 16,
        ),
      ),
      buildDatePicker(context),
      const SizedBox(height: 10),
      buildRoleField(),
      !_roleValid
          ? Text(
              "Enter role filled by volunteer",
              style: TextStyle(
                fontWeight: FontWeight.normal,
                fontSize: 14,
                color: Colors.red.shade600,
              ),
            )
          : Container(),
      const SizedBox(height: 10),
      buildTaskDoneField(),
      !_taskValid
          ? Text(
              "Enter tasks completed by volunteer",
              style: TextStyle(
                fontWeight: FontWeight.normal,
                fontSize: 14,
                color: Colors.red.shade600,
              ),
            )
          : Container(),
      const SizedBox(height: 40),
      buildSaveButton(context),
    ]);
  }

  Widget buildDurationPicker(BuildContext context) {
    return GestureDetector(
      onTap: () {
        _selectTime(context);
      },
      child: Container(
        height: 60,
        padding: const EdgeInsets.all(10),
        margin: const EdgeInsets.symmetric(vertical: 10),
        decoration: BoxDecoration(
            color: Colors.grey.shade100,
            borderRadius: BorderRadius.circular(20),
            border: _durationValid
                ? null
                : Border.all(color: Colors.red.shade500, width: 2)),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              "${_hours} hours ${_minutes.remainder(60)} minutes",
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

  Future<void> _selectTime(BuildContext context) async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: const TimeOfDay(hour: 0, minute: 0),
      builder: (BuildContext? context, Widget? child) {
        return child!;
      },
    );
    setState(() {
      if (picked != null) _hours = picked.hour;
      if (picked != null) _minutes = picked.minute;
    });
    //if (picked != null) print({'time selected: ' + picked.hour.toString() + ':' + picked.minute.toString()});
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
    // Ensure that assignedStartDate and assignedEndDate are not null
    DateTime? startDate = widget.registration?.assignedStartDate;
    DateTime? endDate = widget.registration?.assignedEndDate;

    // If either startDate or endDate is null, set appropriate bounds.
    // In this case, use DateTime.now() for null values to prevent errors.
    DateTime firstDate = startDate ?? DateTime.now();
    DateTime lastDate = endDate ?? DateTime.now();

    // Show the date picker
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: firstDate,
      firstDate: firstDate,
      lastDate: lastDate,
    );

    // If a valid date is picked, update the state
    setState(() {
      if (picked != null) {
        _date = picked;
      }
    });

    // Uncomment to debug the picked date
    // if (picked != null) print(picked.toString());
  }

  ConfettiController _controllerTop =
      ConfettiController(duration: const Duration(seconds: 10));

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
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            TextButton(
              onPressed: () async {
                validateForm();
                if (!_durationValid) {
                  return;
                }
                setState(() {
                  _savingInProgress = true;
                });

                try {
                  VolunteeringHistory volunteeringLog = VolunteeringHistory(
                      hours: _hours,
                      minutes: _minutes,
                      date: _date,
                      role: _roleController.text.trim(),
                      task: _taskController.text.trim(),
                      userId: widget.userId,
                      eventId: widget.eventId,
                      eventName: widget.event.name,
                      userName: widget.userName,
                      organiserId: FirebaseAuth.instance.currentUser!.uid);
                  await VolunteeringHistoryDAO.addVolunteeringHistory(
                      volunteeringLog);
                  _controllerTop.play();
                  resetInfo();
                  showDialog(
                    context: context,
                    builder: (BuildContext context) {
                      return Dialog(
                        backgroundColor: Colors.transparent,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(30.0),
                        ),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            ConfettiWidget(
                              confettiController: _controllerTop,
                              blastDirection: -3.141 / 2,
                              emissionFrequency: 0.1,
                              numberOfParticles: 10,
                              gravity: 0.05,
                              shouldLoop: false,
                              colors: const [
                                Colors.purple,
                                Colors.blue,
                                Colors.pink
                              ],
                            ),
                            Container(
                              height: 100,
                              width: 300,
                              padding: const EdgeInsets.all(10),
                              alignment: Alignment.center,
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(30.0),
                                color: Colors.white,
                              ),
                              child: Text(
                                'Volunteering recorded successfully!',
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 20,
                                ),
                              ),
                            )
                          ],
                        ),
                      );
                    },
                  );
                } catch (e) {
                  //print(e);
                  showDialog(
                    context: context,
                    builder: (BuildContext context) {
                      return AlertDialog(
                        backgroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10.0),
                        ),
                        title: Text(
                          'Error while uploading volunteering',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontWeight: FontWeight.w500,
                            fontSize: 20,
                            decorationColor: Colors.black,
                          ),
                        ),
                      );
                    },
                  );
                }
                setState(() {
                  _savingInProgress = false;
                });
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
                        )),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void validateForm() {
    if (_hours + _minutes == 0) {
      setState(() {
        _durationValid = false;
        _durationErrorMessage = "Duration must be greater than 0 minutes";
      });
    } else {
      setState(() {
        _durationValid = true;
        _durationErrorMessage = "";
      });
    }

    if (_roleController.text.trim().isEmpty) {
      _roleValid = false;
    }
    if (_taskController.text.trim().isEmpty) {
      _taskValid = false;
    }
    setState(() {});
  }

// Build UI for the Role TextField
  Widget buildRoleField() {
    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
      ),
      child: TextField(
        controller: _roleController,
        decoration: InputDecoration(
          labelText: 'Role', // The label of the input field
          hintText: 'Enter the role of the volunteer', // Placeholder text
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
      ),
    );
  }

// Build UI for the Task Done TextField
  Widget buildTaskDoneField() {
    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
      ),
      child: TextField(
        controller: _taskController,
        maxLines: 3,
        decoration: InputDecoration(
          labelText: 'Task Done', // The label of the input field
          hintText:
              'Enter the task the volunteer has completed', // Placeholder text
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
      ),
    );
  }

  void resetInfo() {
    _hours = 0;
    _minutes = 0;
    _date = DateTime.now();
    _roleController.text = "";
    _taskController.text = "";
  }
}

//todo ref https://m3.material.io/components/time-pickers/specs in report
