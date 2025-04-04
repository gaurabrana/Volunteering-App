import 'dart:math';

import 'package:HeartOfExperian/Pages/Authentication/CreateAccount.dart';
import 'package:HeartOfExperian/Pages/Settings/ForgotPassword.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart' as material;
import 'package:flutter/material.dart';
import 'package:rive/rive.dart';

import '../../DataAccessLayer/UserDAO.dart';
import '../CustomWidgets/FormInputFields/EmailInputField.dart';
import '../CustomWidgets/FormInputFields/PasswordInputField.dart';
import '../Feed.dart';
import '../Leaderboard.dart';
import '../NavBarManager.dart';
import '../Profile.dart';
import '../RecordVolunteering.dart';
import '../SearchVolunteering.dart';
import '../Settings/SharedPreferences.dart';

final FirebaseAuth _auth = FirebaseAuth.instance;

class SignInPage extends StatefulWidget {
  final GlobalKey<NavigatorState> logInNavigatorKey;
  final GlobalKey<NavigatorState> mainNavigatorKey;

  const SignInPage({super.key, required this.logInNavigatorKey, required this.mainNavigatorKey});

  @override
  _SignInPageState createState() {
    return _SignInPageState();
  }
}

class _SignInPageState extends State<SignInPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: SingleChildScrollView(
            primary: false,
            physics: AlwaysScrollableScrollPhysics(),
            child: Column(children: [
              Transform.rotate(
                  angle: pi,
                  child: Transform.translate(
                      offset: const Offset(0, 10),
                      child: Container(
                        height: 250,
                        width: double.infinity,
                        child: RiveAnimation.asset(
                          'assets/animations/simple_wave.riv',
                        ),
                      ))),
              Center(
                  child: Padding(
                      padding: const EdgeInsets.only(top: 0, left: 20, right: 20, bottom: 0),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: <Widget>[
                          _LogInForm(logInNavigatorKey: widget.logInNavigatorKey, mainNavigatorKey: widget.mainNavigatorKey),
                          Container(
                              alignment: Alignment.center,
                              child: Column(mainAxisAlignment: MainAxisAlignment.end, children: [
                                SizedBox(height: 40),
                                const Text("No account?"),
                                Container(
                                  width: 500.0,
                                  child: TextButton(
                                    onPressed: () async {
                                      Navigator.of(context).push(MaterialPageRoute(builder: (context) => CreateAccountPage(mainNavigatorKey:  widget.mainNavigatorKey,logInNavigatorKey: widget.logInNavigatorKey, )));
                                    },
                                    child: const Text('Create account',
                                        textAlign: TextAlign.center,
                                        style: TextStyle(
                                          fontWeight: FontWeight.bold,
                                          fontSize: 20,
                                          decorationColor: Colors.black,
                                        )),
                                  ),
                                ),
                              ])),
                        ],
                      )))
            ])), bottomNavigationBar: null,);
  }
}

// logOutUser(BuildContext context, GlobalKey<NavigatorState> navKey) async {
//   SignInSharedPreferences.setSignedIn(false);
//   User user;
//   if (_auth.currentUser != null) {
//     user = _auth.currentUser as User;
//     await _auth.signOut();
//     final String email = user.email!;
//     ScaffoldMessenger.of(context).showSnackBar(SnackBar(
//       content: Text(email + ' has successfully signed out.'),
//     ));
//     // navKey.currentState?.pushAndRemoveUntil(
//     //   MaterialPageRoute(builder: (context) => SignInPage()),
//     //       (route) => false,
//     // );
//     Navigator.of(context).popUntil((route) => route.isFirst);
//     Navigator.of(context).pushReplacement(MaterialPageRoute(builder: (context) => SignInPage()));
//   } else {
//     ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
//       content: Text('No one has signed in.'),
//     ));
//     return;
//   }
// }

logOutUser(BuildContext context, GlobalKey<NavigatorState> loginNavigationKey, GlobalKey<NavigatorState> mainNavigatorKey,) async {
  SignInSharedPreferences.setSignedIn(false);
  if (_auth.currentUser != null) {
    await _auth.signOut();
    final String email = _auth.currentUser!.email ?? '';
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text('$email has successfully signed out.'),
    ));
    loginNavigationKey.currentState?.pushReplacement(MaterialPageRoute(builder: (context) => SignInPage(logInNavigatorKey: loginNavigationKey, mainNavigatorKey: mainNavigatorKey,)));
  } else {
    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
      content: Text('No one has signed in.'),
    ));
  }
}


class _LogInForm extends StatefulWidget {
  final GlobalKey<NavigatorState> logInNavigatorKey;
  final GlobalKey<NavigatorState> mainNavigatorKey;

  const _LogInForm({super.key, required this.logInNavigatorKey, required this.mainNavigatorKey});

  @override
  State<StatefulWidget> createState() => _LogInFormState();
}

class _LogInFormState extends State<_LogInForm> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  String _userEmail = "";
  String _loginMessage = "";
  late FocusNode _emailFocusNode = FocusNode();
  late FocusNode _passwordFocusNode = FocusNode();
  Key _emailKey = UniqueKey();
  Key _passwordKey = UniqueKey();

  @override
  void initState() {
    super.initState();
    _emailFocusNode = FocusNode();
    _passwordFocusNode = FocusNode();
  }

  @override
  void dispose() {
    _emailFocusNode.dispose();
    _passwordFocusNode.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _focusNextField(BuildContext context, FocusNode currentFocusNode) {
    if (currentFocusNode == _emailFocusNode) {
      FocusScope.of(context).requestFocus(_passwordFocusNode);
    }
    setState(() {
      _emailKey = UniqueKey();
      _passwordKey = UniqueKey();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Form(
      key: _formKey,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        // crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          const Text('Hello',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 60,
              )),
          const Text('Sign into your account',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontWeight: FontWeight.normal,
                fontSize: 20,
              )),
          EmailInputField(controller: _emailController, focusNextField: _focusNextField, focusNode: _emailFocusNode, key: _emailKey),
          PasswordInputField(controller: _passwordController, focusNextField: _focusNextField, focusNode: _passwordFocusNode, key: _passwordKey),
          Align(
            alignment: Alignment.centerRight,
            child: TextButton(
              onPressed: () async {
                showForgotPasswordDialog(context);
              },
              child: Text('Forgot password?',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: Colors.grey.shade600,
                    fontWeight: FontWeight.normal,
                    fontSize: 15,
                    decorationColor: Colors.black,
                  )),
            ),
          ),
          GestureDetector(
              onTap: () async {
                if (_formKey.currentState!.validate()) {
                  _signInWithEmailAndPassword();
                }
              },
              child: Container(
                  padding: const EdgeInsets.symmetric(vertical: 20.0),
                  alignment: Alignment.topRight,
                  child: Row(mainAxisAlignment: MainAxisAlignment.end, children: <Widget>[
                    const Text('Sign in',
                        textAlign: TextAlign.right,
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 30,
                        )),
                    SizedBox(width: 15.0),
                    Container(
                      height: 50,
                      width: 100,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(30),
                        gradient: material.LinearGradient(
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          colors: [Color(0xFF8643FF), Color(0xFF4136F1)],
                        ),
                      ),
                      child: IconButton(
                        icon: Icon(
                          Icons.arrow_forward,
                          color: Colors.white,
                          size: 30,
                        ),
                        onPressed: () async {
                          if (_formKey.currentState!.validate()) {
                            _signInWithEmailAndPassword();
                          }
                        },
                      ),
                    )
                  ]))),
          Container(
            alignment: Alignment.center,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Text(_loginMessage, style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  void _signInWithEmailAndPassword() async {
    setState(() {
      _loginMessage = ''; // Clear previous login message
    });

    try {
      final userCredential = await _auth.signInWithEmailAndPassword(
        email: (_emailController.text + UserDAO.defaultDomain),
        password: _passwordController.text,
      );

      final user = userCredential.user;
      if (user != null) {
        setState(() {
          _userEmail = user.email as String;
          _loginMessage = '';
        });
        SignInSharedPreferences.setSignedIn(true);
        redirectToMainApp(context);
      } else {
        setState(() {
          _loginMessage = 'No account found with that email. Please sign up or try a different email address.';
        });
      }
    } catch (e) {
      if (e is FirebaseAuthException) {
        //print('e.code: ' + e.code);
        if (e.code == 'user-not-found') {
          setState(() {
            _loginMessage = 'No account found with that email. Please sign up or try a different email address.';
          });
        } else if (e.code == 'wrong-password') {
          setState(() {
            _loginMessage = 'Incorrect password. Please double-check your credentials and try again.';
          });
        } else if (e.code == 'too-many-requests') {
          setState(() {
            _loginMessage = 'Too many incorrect attempts. Please try again later.';
          });
        } else if (e.code == 'INVALID_LOGIN_CREDENTIALS') {
          setState(() {
            _loginMessage = 'Email or password incorrect.';
          });
        } else {
          setState(() {
            _loginMessage = 'Error logging in. Please try again1.';
          });
        }
      } else {
        setState(() {
          _loginMessage = 'Error logging in. Please try again2.';
        });
      }
    }
  }

  void showForgotPasswordDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return ForgotPasswordPopUp();
      },
    );
  }

  redirectToMainApp(BuildContext context) async {
    widget.logInNavigatorKey.currentState?.push(
      MaterialPageRoute(
        builder: (context) => NavBarManager(
          initialIndex: 0,
          searchVolunteeringPage: SearchVolunteeringPage(),
          feedPage: FeedPage(mainNavigatorKey: widget.mainNavigatorKey, logInNavigatorKey: widget.logInNavigatorKey,),
          //profilePage: ProfilePage(),
          recordVolunteeringPage: RecordVolunteeringPage(),
          leaderboardPage: LeaderboardPage(isTeamStat: false), mainNavigatorKey: widget.mainNavigatorKey, logInNavigatorKey: widget.logInNavigatorKey,
        ),
      ),
    );
  }
}
// todo sign in via biometrics.
