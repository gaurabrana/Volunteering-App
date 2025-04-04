import 'package:flutter/material.dart';

class EventWebsiteInputField extends StatefulWidget {
  final TextEditingController controller;

  // final Function(BuildContext, FocusNode) focusNextField;
  // final FocusNode focusNode;

  // const NameInputField({super.key, required this.controller, this.focusNextField = _defaultFocusNextField, required this.focusNode});
  const EventWebsiteInputField({
    super.key,
    required this.controller,
  });

  // static void _defaultFocusNextField(BuildContext context, FocusNode focusNode) {}

  @override
  State<StatefulWidget> createState() => EventWebsiteInputFieldState();
}

class EventWebsiteInputFieldState extends State<EventWebsiteInputField> {
  @override
  Widget build(context) {
    return TextFormField(
      controller: widget.controller,
      textInputAction: TextInputAction.next,
      keyboardType: TextInputType.url,
      decoration: InputDecoration(
        hintText: "Enter the volunteering cause's website",
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
      validator: (String? value) {
        if (value!.isEmpty) {
          return 'Please enter the title of the event';
        }
        return null;
      },
    );
  }
}
