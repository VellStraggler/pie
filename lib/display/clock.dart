// ignore_for_file: library_private_types_in_public_api

import 'package:flutter/material.dart';
import 'dart:async';

class Clock extends StatefulWidget {
  const Clock({super.key});

  @override
  _TimeClock createState() => _TimeClock();
}

class _TimeClock extends State<Clock> {
  Timer? _timer;
  String _time = "";

  @override
  void initState() {
    super.initState();
    startTimer();
  }

  String _formatTime(DateTime time) {
    int hour = time.hour;
    int minute = time.minute;
    String code = "AM";
    if (hour >= 12) {
      hour = hour - 12;
      code = "PM";
    }

    return '${hour.toString()}:${minute.toString().padLeft(2, '0')} $code';
  }

  void startTimer() {
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      setState(() {
        _time = _formatTime(DateTime.now());
      });
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Text(
      _time,
      style: TextStyle(fontSize: 24),
    );
  }
}
