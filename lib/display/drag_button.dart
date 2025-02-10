// ignore_for_file: prefer_const_constructors_in_immutables, prefer_const_constructors
import 'package:flutter/material.dart';
import 'package:pie_agenda/methods.dart';
import 'package:pie_agenda/display/point.dart';

const double buttonRadius = 20;
const double buttonDiameter = buttonRadius * 2;

class DragButton {
  Point point;
  double time;
  bool shown;
  bool isStartButton;

  DragButton(
      {required this.time, required this.shown, required this.isStartButton})
      : point = Methods.getPointFromTime(time);

  @override
  String toString({DiagnosticLevel minLevel = DiagnosticLevel.info}) {
    return time.toString();
  }

  /// also updates point
  void setTime(double time) {
    this.time = time;
    point = Methods.getPointFromTime(time);
  }

  ///also updates time
  void setPoint(Point newPoint) {
    point = newPoint;
    time = Methods.getTimeFromPoint(point);
  }
}
