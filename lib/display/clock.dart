import 'package:flutter/material.dart';
import 'dart:async';

class Clock extends StatefulWidget {
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
    String code = "AM";
    if (hour >= 12) {
      hour = hour - 12;
      code = "PM";
    }

    return '${hour.toString()}:${time.minute.toString().padLeft(2, '0')} $code';
  }

  void startTimer() {
    _timer = Timer.periodic(Duration(seconds: 1), (timer) {
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