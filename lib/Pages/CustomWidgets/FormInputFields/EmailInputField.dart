import 'package:flutter/material.dart';

import '../../../DataAccessLayer/UserDAO.dart';

class EmailInputField extends StatefulWidget {
  final TextEditingController controller;
  final Function(BuildContext, FocusNode) focusNextField;
  final FocusNode focusNode;

  const EmailInputField({super.key, required this.controller, this.focusNextField = _defaultFocusNextField, required this.focusNode});

  static void _defaultFocusNextField(BuildContext context, FocusNode focusNode) {}

  @override
  State<StatefulWidget> createState() => EmailInputFieldState();
}

class EmailInputFieldState extends State<EmailInputField> {
  @override
  Widget build(context) {
    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            spreadRadius: 0.5,
            blurRadius: 10,//todo show errors inline, validate all forms (Events?)
            offset: const Offset(2, 3),//todo check handling no results returned from a query
          ),//todo help options, support page, tutorial
        ],// todo on date picker have calendar icon. then have text as like select and then replace the date, same for time or duraton
      ),//todo support text for required/not required
      child: TextFormField(//todo label text should always be visible
          focusNode: widget.focusNode,
         // textAlign: TextAlign.right,//todo check align to the right
          onFieldSubmitted: (_) {
            widget.focusNextField(context, widget.focusNode);
          },
          controller: widget.controller,
          keyboardType: TextInputType.emailAddress,
          decoration: InputDecoration(
            hintText: 'Email',
            alignLabelWithHint: true,
            hintStyle: TextStyle(
              color: Colors.grey,
            ),
            prefixIcon: Icon(
              Icons.email,
              color: Colors.grey,
            ),
            suffixText: UserDAO.defaultDomain,
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
          validator: (String? value) {
            if (value!.isEmpty) {
              return 'Please enter an email';
            }
            if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(value + UserDAO.defaultDomain)) {
              return 'Please enter a valid email address';
            }
            return null;
          }),
    );
  }
}
