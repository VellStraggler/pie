// ignore_for_file: prefer_const_constructors_in_immutables, prefer_const_constructors

import 'dart:math';

import 'package:flutter/material.dart';
import 'package:pie_agenda/pie/pie.dart';
import 'dart:async';
import 'package:pie_agenda/display/point.dart';
import 'package:pie_agenda/pie/slice.dart';

const double buttonRadius = 12;
const double buttonDiameter = buttonRadius * 2;
bool firstCall = true;

class DragButton extends StatefulWidget {
  final Point point;
  final double time;
  final bool shown;
  final List<Point> guidePoints;
  final ValueChanged<bool> onDragStateChanged;
  late final Function(Point) onDragEnd; // callback for drag end
  late final Slice slice;

  DragButton({
    Key? key,
    required this.time,
    required this.shown,
    required this.onDragStateChanged,
    required this.guidePoints,
  })  : point = setPointOnTime(time),
        super(key: key);

  @override
  _DragButtonState createState() => _DragButtonState();

  static Point setPointOnTime(double time) {
    double theta = (-pi * time / 6.0) + (pi / 2.0);
    double x = (pieRadius * cos(theta)) + pieRadius;
    double y = -(pieRadius * sin(theta)) + pieRadius;
    return Point.parameterized(x: x, y: y);
  }

  static Point setInitPointOnTime(double time) {
    double theta = (-pi * time / 6.0) + (pi / 2.0);
    double x = (pieRadius * cos(theta)) +
        pieRadius +
        buttonRadius; // Add buttonRadius for alignment
    double y = -(pieRadius * sin(theta)) +
        pieRadius +
        buttonRadius; // Add buttonRadius for alignment
    firstCall = false;
    return Point.parameterized(x: x, y: y);
  }

  //static Point setPointOnTime(double time) {
  //double theta = (-pi * time / 6.0) + (pi / 2.0);
  //double x = (pieRadius * cos(theta)) + pieRadius + buttonRadius; // Add buttonRadius for alignment
  //double y = -(pieRadius * sin(theta)) + pieRadius + buttonRadius; // Add buttonRadius for alignment
  //return Point.parameterized(x: x, y: y);
//}

  static double getTimeFromPoint(Point point) {
    double centerX = pieRadius;
    double centerY = pieRadius;
    double deltaX = point.x - centerX;
    double deltaY = point.y - centerY;
    double theta = atan2(-deltaY, deltaX);
    theta = (pi / 2) - theta;
    if (theta < 0) theta += 2 * pi;
    double time = (theta * 6.0) / pi;
    if (time >= 12.0) time -= 12.0;
    return time;
  }
}

class _DragButtonState extends State<DragButton> {
  late Point currentPosition;
  bool isDragging = false;

  @override
  void initState() {
    super.initState();
    if (firstCall) {
      firstCall = false;
      currentPosition = DragButton.setInitPointOnTime(widget.time);
    }
    currentPosition = Point.parameterized(x: widget.point.x, y: widget.point.y);
  }

  void _updateDragState(bool dragging) {
    if (widget.onDragStateChanged != null) {
      widget.onDragStateChanged(dragging);
    }
    setState(() {
      isDragging = dragging;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Positioned(
      left: currentPosition.x - buttonRadius,
      top: currentPosition.y - buttonRadius,
      child: GestureDetector(
        onPanStart: (details) {
          _updateDragState(true);
        },
        onPanUpdate: (details) {
          setState(() {
            currentPosition = Point.parameterized(
              x: currentPosition.x + details.delta.dx,
              y: currentPosition.y + details.delta.dy,
            );
          });
          widget.onDragEnd(currentPosition);
          _notifyListeners();
        },
        onPanEnd: (details) {
          setState(() {
            currentPosition = _getRoundedSnapPoint(currentPosition);
          });
          // _updateDragState(false);
          widget.onDragEnd(currentPosition);
          _notifyListeners();
        },
        child: widget.shown
            ? Container(
                width: buttonDiameter,
                height: buttonDiameter,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.black,
                ),
              )
            : const SizedBox.shrink(),
      ),
    );
  }

  Point _getNearestSnapPoint(Point currentPosition, DragUpdateDetails details) {
    Point current = Point.parameterized(
        x: currentPosition.x + details.delta.dx,
        y: currentPosition.y + details.delta.dy);
    Point newPoint =
        DragButton.setPointOnTime(DragButton.getTimeFromPoint(current));
    return newPoint;
  }

  //Point _getRoundedSnapPoint(Point current) {
  //  double time = DragButton.getTimeFromPoint(current);
  //  time = (time * 4).round() / 4;
  //  return DragButton.setPointOnTime(time);
  //}

  Point _getRoundedSnapPoint(Point current) {
    double time = DragButton.getTimeFromPoint(current);
    time = (time * 4).round() / 4;
    Point snapPoint = DragButton.setPointOnTime(time);
    return Point.parameterized(
        x: snapPoint.x + buttonRadius, y: snapPoint.y + buttonRadius);
  }
}
