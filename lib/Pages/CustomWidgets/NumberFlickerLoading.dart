import 'dart:async';

import 'package:flutter/material.dart';

class NumberFlickerLoading extends StatefulWidget {
  final Duration flickerDuration;
  final bool stopFlicking;

  NumberFlickerLoading({
    required this.flickerDuration,
    required this.stopFlicking,
    Key? key,
  }) : super(key: key);

  @override
  _NumberFlickerLoadingState createState() => _NumberFlickerLoadingState();
}

class _NumberFlickerLoadingState extends State<NumberFlickerLoading> {
  int _currentNumber = 1;
  bool _increasing = true;
  late Timer _timer;

  @override
  void initState() {
    super.initState();
    _startFlickerAnimation();
  }

  @override
  void dispose() {
    _timer.cancel();
    super.dispose();
  }

  void _startFlickerAnimation() {
    _timer = Timer.periodic(widget.flickerDuration, (timer) {
      if (widget.stopFlicking) {
        timer.cancel();
      } else {
        setState(() {
          if (_increasing) {
            _currentNumber++;
            if (_currentNumber == 100) {
              _increasing = false;
            }
          } else {
            _currentNumber--;
            if (_currentNumber == 1) {
              _increasing = true;
            }
          }
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Text(
      '$_currentNumber',
      style: TextStyle(
        fontSize: 24,
        fontWeight: FontWeight.bold,
      ),
    );
  }
}
