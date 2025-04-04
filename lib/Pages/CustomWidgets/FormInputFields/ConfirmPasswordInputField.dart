import 'package:flutter/material.dart';

class ConfirmPasswordInputField extends StatefulWidget {
  final TextEditingController password1controller;
  final TextEditingController password2controller;
  final Function(BuildContext, FocusNode) focusNextField;
  final FocusNode focusNode;

  const ConfirmPasswordInputField(
      {super.key, required this.password1controller, required this.password2controller, required this.focusNode, required this.focusNextField});

  @override
  State<StatefulWidget> createState() => ConfirmPasswordInputFieldState();
}

class ConfirmPasswordInputFieldState extends State<ConfirmPasswordInputField> {
  bool _passwordVisible = false;

  @override
  Widget build(context) {
    return Container(
        padding: EdgeInsets.all(10),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              spreadRadius: 0.5,
              blurRadius: 10,
              offset: Offset(2, 3),
            ),
          ],
        ),
        child: TextFormField(
          controller: widget.password2controller,
          keyboardType: TextInputType.visiblePassword,
          obscureText: !_passwordVisible,
          focusNode: widget.focusNode,
          onFieldSubmitted: (_) {
            widget.focusNextField(context, widget.focusNode);
          },
          decoration: InputDecoration(
            hintText: 'Confirm password',
            hintStyle: const TextStyle(
              color: Colors.grey,
            ),
            prefixIcon: const Icon(
              Icons.lock,
              color: Colors.grey,
            ),
            filled: true,
            fillColor: Colors.white,
            border: const OutlineInputBorder(
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
            suffixIcon: IconButton(
              icon: Icon(_passwordVisible ? Icons.visibility : Icons.visibility_off),
              color: Colors.grey,
              onPressed: () {
                setState(
                  () {
                    _passwordVisible = !_passwordVisible;
                  },
                );
              },
            ),
          ),
          validator: (String? value) {
            if (value!.isEmpty) {
              return 'Please enter a password';
            } else if (value != widget.password1controller.text) {
              return 'Passwords must match';
            }
            return null;
          },
        ));
  }
}
