import 'package:flutter/material.dart';

class SurnameInputField extends StatefulWidget {
  final TextEditingController controller;

  const SurnameInputField({
    super.key,
    required this.controller,
  });

  @override
  State<StatefulWidget> createState() => SurnameInputFieldState();
}

class SurnameInputFieldState extends State<SurnameInputField> {
  @override
  Widget build(context) {
    return Container(
      width: 172,
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
            hintText: 'Surname',
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
