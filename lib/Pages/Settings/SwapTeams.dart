import 'package:HeartOfExperian/DataAccessLayer/UserDAO.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import '../../Models/UserDetails.dart';
import '../CustomWidgets/FormInputFields/TeamInputField.dart';

class SwapTeamsPopUp extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => SwapTeamsPopUpState();
}

class SwapTeamsPopUpState extends State<SwapTeamsPopUp> {
  @override
  void initState() {
    super.initState();
  }

  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  String _selectedTeamName = "";

  void updateSelectedTeamName(String name) {
    setState(() {
      _selectedTeamName = name;
    });
  }

  @override
  Widget build(context) {
    return AlertDialog(
      backgroundColor: Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20.0),
      ),
      title: const Text(
        'Swap teams',
        textAlign: TextAlign.center,
        style: TextStyle(
          fontWeight: FontWeight.w700,
          fontSize: 25,
          decorationColor: Colors.black,
        ),
      ),
      content: const Text(
        'Select your new team',
        textAlign: TextAlign.center,
        style: TextStyle(
          fontWeight: FontWeight.w400,
          fontSize: 15,
          decorationColor: Colors.black,
        ),
      ),
      actions: <Widget>[
        Form(
          key: _formKey,
          child: Column(crossAxisAlignment: CrossAxisAlignment.end, mainAxisAlignment: MainAxisAlignment.end, children: <Widget>[
            TeamInputField(
              updateSelectedTeamName: updateSelectedTeamName,
            ),
          ]),
        ),
        Container(
            padding: const EdgeInsets.symmetric(vertical: 20.0),
            alignment: Alignment.topRight,
            child: Row(mainAxisAlignment: MainAxisAlignment.end, children: <Widget>[
              const Text('Swap team',
                  textAlign: TextAlign.right,
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 20,
                  )),
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
                    if (_formKey.currentState!.validate()) {
                      User? user = FirebaseAuth.instance.currentUser;
                      if (user != null) {
                        UserDetails? userDetails = await UserDAO.getUserDetails(user.uid);
                        if (userDetails != null) {
                          UserDAO.updateTeam(userDetails, _selectedTeamName);
                          ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                            content: Text('You have successfully joined ' + _selectedTeamName),
                          ));
                        } else {
                          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                            content: Text('Error: team swap unsuccessful'),
                          ));
                        }
                      } else {
                        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                          content: Text('Error: team swap unsuccessful'),
                        ));
                      }
                    }
                  },
                ),
              )
            ])),
      ],
    );
  }
}
