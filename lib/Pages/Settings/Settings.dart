import 'package:HeartOfExperian/Pages/NavBarManager.dart';
import 'package:HeartOfExperian/Pages/Settings/DeleteAccount.dart';
import 'package:HeartOfExperian/Pages/Settings/ResetPassword.dart';
import 'package:HeartOfExperian/Pages/Settings/SwapTeams.dart';
import 'package:flutter/material.dart';

import '../../DataAccessLayer/FeedbackDAO.dart';
import '../Authentication/SignIn.dart';
import '../CustomWidgets/BackButton.dart';
import '../Feed.dart';
import '../Leaderboard.dart';
import '../Profile.dart';
import '../RecordVolunteering.dart';
import '../SearchVolunteering.dart';
import 'EditProfile.dart';

class SettingsPage extends StatefulWidget {
  final GlobalKey<NavigatorState> mainNavigatorKey;
  final GlobalKey<NavigatorState> logInNavigatorKey;

  const SettingsPage({super.key, required this.mainNavigatorKey, required this.logInNavigatorKey});

  @override
  State<StatefulWidget> createState() => SettingsPageState();
}

class SettingsPageState extends State<SettingsPage> {
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(context) {
    return Scaffold(
        body: Padding(
          padding: const EdgeInsets.only(top: 40.0, left: 20, right: 20, bottom: 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Row(
                children: [
                  GoBackButton(),
                  const Padding(
                    padding: EdgeInsets.only(top: 35.0, left: 60),
                    child: Align(
                      alignment: Alignment.center,
                      child: Text(
                        'Settings',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 30,
                          decorationColor: Colors.black,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              const Text(
                'Account',
                textAlign: TextAlign.left,
                style: TextStyle(
                  fontWeight: FontWeight.w500,
                  fontSize: 20,
                  decorationColor: Colors.black,
                ),
              ),
              TextButton(
                style: TextButton.styleFrom(
                  foregroundColor: Colors.grey.shade600,
                ),
                onPressed: () async {
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (context) => EditProfilePage(),
                    ),
                  );
                },
                child: const Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: <Widget>[
                    Text(
                      'Edit profile  ',
                      style: TextStyle(fontWeight: FontWeight.w500, fontSize: 15),
                    ),
                    Icon(Icons.chevron_right),
                  ],
                ),
              ),
              TextButton(
                style: TextButton.styleFrom(
                  foregroundColor: Colors.grey.shade600,
                ),
                onPressed: () async {
                  showResetPasswordDialog(context);
                },
                child: const Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: <Widget>[
                    Text(
                      'Change password  ',
                      style: TextStyle(fontWeight: FontWeight.w500, fontSize: 15),
                    ),
                    Icon(Icons.chevron_right),
                  ],
                ),
              ),
              TextButton(
                //todo the padding is messed up
                style: TextButton.styleFrom(
                  foregroundColor: Colors.grey.shade600,
                ),
                onPressed: () async {
                  showSwapTeamsDialog(context);
                },
                child: const Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: <Widget>[
                    Text(
                      'Swap teams  ',
                      style: TextStyle(fontWeight: FontWeight.w500, fontSize: 15),
                    ),
                    Icon(Icons.chevron_right),
                  ],
                ),
              ),
              TextButton(
                style: TextButton.styleFrom(
                  foregroundColor: Colors.grey.shade600,
                ),
                onPressed: () async {
                  showDeleteAccountDialog(context);
                },
                child: const Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: <Widget>[
                    Text(
                      'Delete account  ',
                      style: TextStyle(fontWeight: FontWeight.w500, fontSize: 15),
                    ),
                    Icon(Icons.chevron_right),
                  ],
                ),
              ),
              const SizedBox(height: 20),
              const Text(
                'Notifications',
                textAlign: TextAlign.left,
                style: TextStyle(
                  fontWeight: FontWeight.w500,
                  fontSize: 20,
                  decorationColor: Colors.black,
                ), //todo
              ),
              TextButton(
                style: TextButton.styleFrom(
                  foregroundColor: Colors.grey.shade600,
                ),
                onPressed: () async {
                  //todo
                },
                child: const Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: <Widget>[
                    Text(
                      'Allow notifications  ', //todo notifications
                      style: TextStyle(fontWeight: FontWeight.w500, fontSize: 15),
                    ),
                    Icon(Icons.chevron_right),
                  ],
                ),
              ),
              const SizedBox(height: 20),
              const Text(
                'Other',
                textAlign: TextAlign.left,
                style: TextStyle(
                  fontWeight: FontWeight.w500,
                  fontSize: 20,
                  decorationColor: Colors.black,
                ), //todo
              ),
              TextButton(
                style: TextButton.styleFrom(
                  foregroundColor: Colors.grey.shade600,
                ),
                onPressed: () async {
                  //todo
                },
                child: const Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: <Widget>[
                    Text(
                      'Language  ', //todo language
                      style: TextStyle(fontWeight: FontWeight.w500, fontSize: 15),
                    ),
                    Icon(Icons.chevron_right),
                  ],
                ),
              ),
              TextButton(
                style: TextButton.styleFrom(
                  foregroundColor: Colors.grey.shade600,
                ),
                onPressed: () async {
                  await showFeedbackDialog(context);
                },
                child: const Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: <Widget>[
                    Text(
                      'Feedback  ',
                      style: TextStyle(fontWeight: FontWeight.w500, fontSize: 15),
                    ),
                    Icon(Icons.chevron_right),
                  ],
                ),
              ),
              const Spacer(),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    alignment: Alignment.center,
                    height: 60,
                    width: 300,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(30),
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
                    child: TextButton(
                      style: TextButton.styleFrom(
                        foregroundColor: Colors.white,
                      ),
                      onPressed: () async {
                        logOutUser(context, widget.logInNavigatorKey,  widget.mainNavigatorKey);
                      },
                      child: Container(
                          height: 60,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(30),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: <Widget>[
                              Icon(Icons.exit_to_app),
                              Text('  Sign out', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600)),
                            ],
                          )),
                    ),
                  ),
                ],
              ),
            ],
          ),
    ));
  }

  void showResetPasswordDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return ResetPasswordPopUp();
      },
    );
  }

  void showSwapTeamsDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return SwapTeamsPopUp();
      },
    );
  }

  void showDeleteAccountDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return DeleteAccountPopUp(logInNavigatorKey: widget.logInNavigatorKey,mainNavigatorKey: widget.mainNavigatorKey,);
      },
    );
  }

  String feedback = "";

  Future<void> showFeedbackDialog(BuildContext context) async {
    return showDialog<void>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Leave your feedback', style: TextStyle(fontWeight: FontWeight.w800)),
          content: TextField(
            onChanged: (value) {
              feedback = value;
            },
            maxLines: 3,
            decoration: InputDecoration(
              hintText: 'Enter feedback',
              hintStyle: TextStyle(
                color: Colors.grey,
              ),
              filled: true,
              fillColor: Colors.grey.shade100,
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
          actions: <Widget>[
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
                        FeedbackDAO.storeFeedback(feedback);
                        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                          content: Text('Feedback submitted successfully - thank you!'),
                        ));
                        Navigator.of(context).pop();
                      },
                      child: Container(
                        height: 40,
                        width: 310,
                        alignment: Alignment.center,
                        child: const Text("Submit feedback",
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontWeight: FontWeight.w600,
                              fontSize: 20,
                              color: Colors.white,
                            )),
                      )),
                ])))
          ],
        );
      },
    );
  }
}
