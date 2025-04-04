import 'package:HeartOfExperian/DataAccessLayer/UserDAO.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import '../Authentication/SignIn.dart';

class DeleteAccountPopUp extends StatefulWidget {
  final GlobalKey<NavigatorState> logInNavigatorKey;
  final GlobalKey<NavigatorState> mainNavigatorKey;

  const DeleteAccountPopUp({super.key, required this.mainNavigatorKey, required this.logInNavigatorKey});

  @override
  State<StatefulWidget> createState() => DeleteAccountPopUpState();
}

class DeleteAccountPopUpState extends State<DeleteAccountPopUp> {
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
        'Are you sure you want to delete your account?',
        textAlign: TextAlign.center,
        style: TextStyle(
          fontWeight: FontWeight.w700,
          fontSize: 25,
          decorationColor: Colors.black,
        ),
      ),
      content: const Text(
        'This action cannot be undone.',
        textAlign: TextAlign.center,
        style: TextStyle(
          fontWeight: FontWeight.w500,
          fontSize: 15,
          decorationColor: Colors.black,
        ),
      ),
      actions: <Widget>[
        Container(
            alignment: Alignment.center,
            height: 60,
            width: 500,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(15),
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [Colors.red.shade600, Colors.red.shade300],
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
                  child: Text('Delete account', style: TextStyle(color: Colors.white, fontSize: 20)),
                  onPressed: () async {
                    try {
                      await UserDAO.deleteUser(FirebaseAuth.instance.currentUser!.uid);
                      deleteUserAccount();
                      logOutUser(context, widget.logInNavigatorKey,  widget.mainNavigatorKey);
                      Navigator.of(context).push(MaterialPageRoute(builder: (context) => SignInPage(logInNavigatorKey: widget.logInNavigatorKey, mainNavigatorKey:  widget.mainNavigatorKey,)));
                    } catch (e) {
                      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                        content: Text('Error: Unable to delete your account' + _selectedTeamName),
                      ));
                    }
                  })
            ])))
      ],
    );
  }
}

Future<void> deleteUserAccount() async {
  try {
    User? user = FirebaseAuth.instance.currentUser;

    await user?.delete();
  } catch (error) {
    print("Error deleting account: $error");
  }
}
