import 'package:HeartOfExperian/DataAccessLayer/VolunteeringHistoryDAO.dart';
import 'package:HeartOfExperian/Models/VolunteeringHistory.dart';
import 'package:autocomplete_textfield/autocomplete_textfield.dart';
import 'package:confetti/confetti.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../DataAccessLayer/VolunteeringCauseDAO.dart';

class RecordVolunteeringPage extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => RecordVolunteeringPageState();
}

class RecordVolunteeringPageState extends State<RecordVolunteeringPage> {
  int _hours = 0;
  int _minutes = 0;
  DateTime _date = DateTime.now();
  List<String> types = VolunteeringHistoryDAO.volunteeringTypesWithOther;
  int selectedTypeIndex = 0;
  bool _savingInProgress = false;
  bool _causesLoading = true;
  late List<String> _causes;
  late TextEditingController _causesTextController;
  final GlobalKey<AutoCompleteTextFieldState<String>> _autocompleteFormKey = GlobalKey();
  String selectedCause = "";
  bool _durationValid = true;
  bool _causeValid = true;
  String _durationErrorMessage = "";
  String _causeErrorMessage = "";

  @override
  void initState() {
    super.initState();
    _causesTextController = TextEditingController(text: selectedCause);
    _fetchCauses();
  }

  void intialiseData() {
    _hours = 0;
    _minutes = 0;
    _date = DateTime.now();
    selectedTypeIndex = 0;
    _savingInProgress = false;
    _causesLoading = true;
    _causes = [];
    _causesTextController;
    selectedCause = "";
    _durationValid = true;
    _causeValid = true;
    _durationErrorMessage = "";
    _causeErrorMessage = "";
  }

  @override
  void dispose() {
    _causesTextController.dispose();
    super.dispose();
  }

  Future<void> _fetchCauses() async {
    intialiseData();
    var causes = await VolunteeringCauseDAO.getAllCauses();
    setState(() {
      _causes = causes;
      _causesLoading = false;
    });
  }

  @override
  Widget build(context) {
    return Padding(
        padding: const EdgeInsets.only(top: 50, left: 30, right: 30, bottom: 0),
        child: SingleChildScrollView(
            child: Column(crossAxisAlignment: CrossAxisAlignment.center, children: [
          buildTitle(context),
          buildRecordVolunteeringForm(context),
        ])));
  }

  Widget buildTitle(BuildContext context) {
    return const Text(
      'Record volunteering',
      textAlign: TextAlign.center,
      style: TextStyle(
        fontWeight: FontWeight.bold,
        fontSize: 30,
        decorationColor: Colors.black,
      ),
    );
  }

  Widget buildRecordVolunteeringForm(BuildContext context) {
    // todo maybe add little 'i' icons which come up with more info on the fields.
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
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
      const Text(
        "Type",
        style: TextStyle(
          fontWeight: FontWeight.bold,
          fontSize: 16,
        ),
      ),
      const SizedBox(height: 5),
      buildVolunteeringTypeOptions(context),
      const SizedBox(height: 15),
      const Text(
        "Volunteering cause",
        style: TextStyle(
          fontWeight: FontWeight.bold,
          fontSize: 16,
        ),
      ),
      _causesLoading ? const CircularProgressIndicator() : buildVolunteeringCausePicker(context),
      !_causeValid
          ? Text(
              _causeErrorMessage,
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
            border: _durationValid ? null : Border.all(color: Colors.red.shade500, width: 2)),
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
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2015, 8),
      lastDate: DateTime.now(),
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

  Widget buildVolunteeringCausePicker(BuildContext context) {
    AutoCompleteTextField<String>? searchTextField;
    setState(() {
      _causesTextController.text = selectedCause;
    });
    searchTextField = AutoCompleteTextField<String>(
      controller: _causesTextController,
      decoration: InputDecoration(
        hintText: 'Search',
        hintStyle: const TextStyle(
          color: Colors.grey,
        ),
        filled: true,
        border: InputBorder.none,
        fillColor: Colors.grey.shade100,
        prefixIcon: const Icon(
          Icons.search_rounded,
          color: Colors.grey,
        ),
      ),
      itemFilter: (item, query) {
        return item.toLowerCase().startsWith(query.toLowerCase());
      },
      itemSorter: (a, b) {
        return a.compareTo(b);
      },
      textChanged: (text) {
        setState(() {
          selectedCause = text;
          _causesTextController.text = selectedCause;
        });
      },
      itemSubmitted: (item) {
        setState(() {
          _causesTextController.text = item;
          searchTextField?.controller?.text = item;
          selectedCause = item;
        });
      },
      itemBuilder: (context, item) {
        return ListTile(
          title: Text(item),
        );
      },
      key: _autocompleteFormKey,
      suggestions: _causes,
    );
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Container(
          height: 60,
          padding: const EdgeInsets.all(10),
          margin: const EdgeInsets.symmetric(vertical: 10),
          decoration: BoxDecoration(
              color: Colors.grey.shade100,
              borderRadius: BorderRadius.circular(20),
              border: _causeValid ? null : Border.all(color: Colors.red.shade500, width: 2)),
          child: searchTextField,
        ),
      ],
    );
  }

  ConfettiController _controllerTop = ConfettiController(duration: const Duration(seconds: 10));

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
                if (!_durationValid || !_causeValid) {
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
                    type: types[selectedTypeIndex],
                    cause: selectedCause,
                    UID: FirebaseAuth.instance.currentUser!.uid,
                  );
                  await VolunteeringHistoryDAO.addVolunteeringHistory(volunteeringLog);
                  _fetchCauses();
                  _controllerTop.play();
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
                              colors: const [Colors.purple, Colors.blue, Colors.pink],
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
    if (selectedCause.isEmpty) {
      setState(() {
        _causeValid = false;
        _causeErrorMessage = "Please enter a volunteering cause";
      });
    } else {
      setState(() {
        _causeValid = true;
        _causeErrorMessage = "";
      });
    }

    if (_causeValid && _durationValid) {
      setState(() {
        _durationValid = true;
        _causeValid = true;
      });
    }
  }
}

//todo ref https://m3.material.io/components/time-pickers/specs in report
