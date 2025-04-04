import 'package:HeartOfExperian/Pages/CustomWidgets/FormInputFields/EmailInputField.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import '../../DataAccessLayer/UserDAO.dart';

class ForgotPasswordPopUp extends StatefulWidget {
  const ForgotPasswordPopUp({super.key});

  @override
  State<StatefulWidget> createState() => ForgotPasswordPopUpState();
}

class ForgotPasswordPopUpState extends State<ForgotPasswordPopUp> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final TextEditingController _emailController = TextEditingController();

  @override
  void initState() {
    super.initState();
  }

//   @override
// Widget build(context) {
//     return AlertDialog(
//         backgroundColor: Colors.white,
//         shape: RoundedRectangleBorder(
//           borderRadius: BorderRadius.circular(20.0),
//         ),
//         title: const Text(
//           'Reset password',textAlign: TextAlign.center,
//             style: TextStyle(
//               fontWeight: FontWeight.w700,
//               fontSize: 25,
//               decorationColor: Colors.black,
//             ),),
//       content: const Text(
//         'Send a password reset email to your email address?',
//         textAlign: TextAlign.center,
//         style: TextStyle(
//           fontWeight: FontWeight.w400,
//           fontSize: 15,
//           decorationColor: Colors.black,
//         ),
//       ),
//         actions: <Widget>[
//           Container(
//           padding: const EdgeInsets.symmetric(vertical: 20.0),
//           alignment: Alignment.topRight,
//           child: Row(mainAxisAlignment: MainAxisAlignment.end, children: <Widget>[
//           const Text('Reset',
//               textAlign: TextAlign.right,
//               style: TextStyle(
//               fontWeight: FontWeight.bold,
//               fontSize: 20,
//           ))]),)],
//     );

  @override
  Widget build(context) {
    return AlertDialog(
        backgroundColor: Colors.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20.0),
        ),
        title: const Text(
          'Reset password',
          textAlign: TextAlign.center,
          style: TextStyle(
            fontWeight: FontWeight.w700,
            fontSize: 25,
            decorationColor: Colors.black,
          ),
        ),
        content: const Text(
          'Send a password reset email to your email address?',
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
              EmailInputField(controller: _emailController, focusNode: FocusNode(), key: UniqueKey()),
            ]),
          ),
          Container(
              padding: const EdgeInsets.symmetric(vertical: 20.0),
              alignment: Alignment.topRight,
              child: Row(mainAxisAlignment: MainAxisAlignment.end, children: <Widget>[
                const Text('Reset',
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
                      String email = _emailController.text + UserDAO.defaultDomain;
                      try {
                        await FirebaseAuth.instance.sendPasswordResetEmail(email: email);
                        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                          content: Text('Password reset email sent to $email'),
                        ));
                      } catch (error) {
                        print('Error sending password reset email: $error');
                        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                          content: Text('Failed to send password reset email'),
                        ));
                      }
                      Navigator.of(context).pop(); // Close the dialog
                    },
                  ),
                )
              ]))
        ]);
  }
}
