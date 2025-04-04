import 'package:flutter/material.dart';

class GoBackButton extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => GoBackButtonState();
}

class GoBackButtonState extends State<GoBackButton> {
  @override
  Widget build(context) {
    return Align(
        alignment: Alignment.centerLeft,
        child: Container(
            alignment: Alignment.topRight,
            height: 50,
            width: 50,
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
              IconButton(
                onPressed: () {
                  Navigator.of(context).pop();
                },
                icon: const Icon(
                  Icons.arrow_back,
                  color: Colors.white,
                  size: 30,
                ),
                color: Color(0xFF4136F1),
                iconSize: 50,
              ),
            ]))));
  }
}
