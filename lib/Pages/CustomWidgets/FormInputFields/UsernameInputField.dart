import 'package:flutter/material.dart';

class UserNameInputField extends StatefulWidget {
  final TextEditingController controller;

  const UserNameInputField({super.key, required this.controller});

  @override
  State<StatefulWidget> createState() => UserNameInputFieldState();
}

class UserNameInputFieldState extends State<UserNameInputField> {
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
            blurRadius: 10,
            offset: const Offset(2, 3),
          ),
        ],
      ),
      child: TextFormField(
          controller: widget.controller,
          textInputAction: TextInputAction.next,
          textCapitalization: TextCapitalization.words,
          keyboardType: TextInputType.name,
          decoration: InputDecoration(
            hintText: 'Name',
            hintStyle: TextStyle(
              color: Colors.grey,
            ),
            prefixIcon: Icon(
              Icons.person,
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
          validator: (String? value) {
            if (value!.isEmpty) {
              return 'Please enter your name';
            }
            return null;
          }),
    );
  }
}
