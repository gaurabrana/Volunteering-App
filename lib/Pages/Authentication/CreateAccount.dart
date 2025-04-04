import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import '../../DataAccessLayer/UserDAO.dart';
import '../CustomWidgets/BackButton.dart';
import '../CustomWidgets/FormInputFields/ConfirmPasswordInputField.dart';
import '../CustomWidgets/FormInputFields/EmailInputField.dart';
import '../CustomWidgets/FormInputFields/ForenameInputField.dart';
import '../CustomWidgets/FormInputFields/PasswordInputField.dart';
import '../CustomWidgets/FormInputFields/SurnameInputField.dart';
import '../CustomWidgets/FormInputFields/TeamInputField.dart';
import '../Settings/SharedPreferences.dart';
import 'CreateTeam.dart';
import 'UploadInitialProfilePhoto.dart';

final FirebaseAuth _auth = FirebaseAuth.instance;

class CreateAccountPage extends StatefulWidget {

  final GlobalKey<NavigatorState> mainNavigatorKey;
  final GlobalKey<NavigatorState> logInNavigatorKey;

  const CreateAccountPage({super.key, required this.mainNavigatorKey, required this.logInNavigatorKey});
  @override
  _CreateAccountPageState createState() {
    return _CreateAccountPageState();
  }
}

class _CreateAccountPageState extends State<CreateAccountPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Builder(builder: (BuildContext context) {
        return SingleChildScrollView(
            child: Padding(
                padding: const EdgeInsets.only(top: 100, left: 20, right: 20, bottom: 20),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: <Widget>[
                    Row(children: [
                      GoBackButton(),
                      const SizedBox(width: 20),
                      const Text('Create account',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 30,
                          )),
                    ]),
                    const SizedBox(height: 20),
                    _CreateAccountForm(mainNavigatorKey: widget.mainNavigatorKey, logInNavigatorKey: widget.logInNavigatorKey,),
                  ],
                )));
      }),
    );
  }
}

class _CreateAccountForm extends StatefulWidget {
  final String title = 'Registration';
  final GlobalKey<NavigatorState> mainNavigatorKey;
  final GlobalKey<NavigatorState> logInNavigatorKey;

  const _CreateAccountForm({super.key, required this.mainNavigatorKey, required this.logInNavigatorKey});

  @override
  State<StatefulWidget> createState() => _CreateAccountFormState();
}

class _CreateAccountFormState extends State<_CreateAccountForm> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final TextEditingController _forenameController = TextEditingController();
  final TextEditingController _surnameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmPasswordController = TextEditingController();

  late final FocusNode _nameFocusNode = FocusNode();
  late final FocusNode _emailFocusNode = FocusNode();
  late final FocusNode _passwordFocusNode = FocusNode();
  late final FocusNode _confirmPasswordFocusNode = FocusNode();

  String _selectedTeamName = "";
  String _userEmail = "";
  String _registrationErrorMessage = "";

  void updateSelectedTeamName(String name) {
    setState(() {
      _selectedTeamName = name;
    });
  }

  @override
  void initState() {
    super.initState();
  }

  void _focusNextField(BuildContext context, FocusNode currentFocusNode) {
    if (currentFocusNode == _nameFocusNode) {
      FocusScope.of(context).requestFocus(_emailFocusNode);
    } else if (currentFocusNode == _emailFocusNode) {
      FocusScope.of(context).requestFocus(_passwordFocusNode);
    } else if (currentFocusNode == _passwordFocusNode) {
      FocusScope.of(context).requestFocus(_confirmPasswordFocusNode);
    }
  }

  @override
  Widget build(context) {
    return Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.end,
          mainAxisAlignment: MainAxisAlignment.end,
          children: <Widget>[
            TeamInputField(
              updateSelectedTeamName: updateSelectedTeamName,
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).push(MaterialPageRoute(builder: (context) => CreateTeamPage()));
              },
              child: RichText(
                textAlign: TextAlign.center,
                text: TextSpan(
                  text: "Don't have a team?  ",
                  style: TextStyle(color: Colors.grey[700], fontSize: 15, fontFamily: 'Poppins'),
                  children: <TextSpan>[
                    TextSpan(
                      text: 'Create one ',
                      style: TextStyle(color: Colors.grey[700], fontWeight: FontWeight.bold, fontFamily: 'Poppins'),
                    )
                  ],
                ),
              ),
            ),
            Row(children: [
              ForenameInputField(
                controller: _forenameController,
              ),
              SurnameInputField(
                controller: _surnameController,
              ),
            ]),
            EmailInputField(controller: _emailController, focusNextField: _focusNextField, focusNode: _emailFocusNode, key: UniqueKey()),
            PasswordInputField(controller: _passwordController, focusNextField: _focusNextField, focusNode: _passwordFocusNode, key: UniqueKey()),
            ConfirmPasswordInputField(
                password1controller: _passwordController,
                password2controller: _confirmPasswordController,
                focusNextField: _focusNextField,
                focusNode: _confirmPasswordFocusNode),
            Container(
                padding: const EdgeInsets.symmetric(vertical: 20.0),
                alignment: Alignment.topRight,
                child: Row(mainAxisAlignment: MainAxisAlignment.end, children: <Widget>[
                  const Text('Create',
                      textAlign: TextAlign.right,
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 30,
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
                          _register();
                        }
                      },
                    ),
                  )
                ])),
            Container(
              alignment: Alignment.center,
              child: Text(_registrationErrorMessage, style: const TextStyle(color: Colors.red)),
            ),
          ],
        ));
  }

  void _register() async {
    try {
      final user =
          (await _auth.createUserWithEmailAndPassword(email: (_emailController.text + "@experian.com"), password: _passwordController.text)).user;
      if (user != null) {
        await UserDAO.storeUserDetails(
            user.uid, _forenameController.text, _surnameController.text, _selectedTeamName, (_emailController.text + "@experian.com"));

        setState(() {
          _userEmail = user.email as String;
          _registrationErrorMessage = "";
          SignInSharedPreferences.setSignedIn(true);
          getUserToUploadProfilePhoto(context);
        });
      } else {
        setState(() {
          _registrationErrorMessage = "Registration error";
        });
      }
    } catch (e) {
      if (e is FirebaseAuthException) {
        setState(() {
          _registrationErrorMessage = _handleRegistrationError(e.code);
        });
      }
    }
  }

  getUserToUploadProfilePhoto(BuildContext context) async {
    Navigator.of(context).push(MaterialPageRoute(builder: (context) => UploadProfilePhotoPage(mainNavigatorKey: widget.mainNavigatorKey, logInNavigatorKey: widget.logInNavigatorKey,)));
  }

  String _handleRegistrationError(String errorCode) {
    switch (errorCode) {
      case "email-already-in-use":
        return "Email address is already in use by another account.";
      case "invalid-email":
        return "Email address is not valid.";
      case "weak-password":
        return "Password too weak - must be at least 8 characters and include a combination of letters, numbers, and special characters.";
      case "too-many-requests":
        return "Too many account creation requests. Try again later.";
      default:
        return "Registration failed. Please try again.";
    }
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _forenameController.dispose();
    _surnameController.dispose();
    _confirmPasswordController.dispose();
    _nameFocusNode.dispose();
    _emailFocusNode.dispose();
    _passwordFocusNode.dispose();
    _confirmPasswordFocusNode.dispose();
    super.dispose();
  }
}


