// ignore_for_file: library_private_types_in_public_api

import 'package:flutter/material.dart';
import 'dart:async';
import 'package:pie_agenda/screens/my_home_page.dart';

class Clock extends StatefulWidget {
  const Clock({super.key});

  @override
  _TimeClock createState() => _TimeClock();
}

class _TimeClock extends State<Clock> {
  Timer? _timer;
  String _time = "";
  List<String> months = [
    "January",
    "February",
    "March",
    "April",
    "May",
    "June",
    "July",
    "August",
    "September",
    "October",
    "November",
    "December",
  ];

  @override
  void initState() {
    super.initState();
    startTimer();
  }

  String _formatTime(DateTime time) {
    int hour = time.hour;
    int minute = time.minute;
    int intDay = time.day;
    int intMonth = time.month;

    String code = "AM";
    if (hour >= 12) {
      hour = hour - 12;
      code = "PM";
    }
    if (hour == 0) {
      hour = 12;
    }

    return '${months[intMonth - 1]} $intDay | ${hour.toString()}:${minute.toString().padLeft(2, '0')} $code';
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
      style: const TextStyle(fontSize: 32, color: themeColor1),
    );
  }
}
