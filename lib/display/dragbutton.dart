// ignore_for_file: prefer_const_constructors_in_immutables, prefer_const_constructors

import 'dart:math';

import 'package:flutter/material.dart';
import 'package:pie_agenda/pie/pie.dart';
import 'dart:async';
import 'package:pie_agenda/display/point.dart';

const double buttonRadius = 12;
const double buttonDiameter = buttonRadius * 2;

class DragButton extends StatefulWidget {
  final Point point;
  final double time;
  final bool shown;

  DragButton({super.key, required this.time, required this.shown})
      : point = setPointOnTime(time);

  @override
  // ignore: library_private_types_in_public_api
  _DragButtonState createState() => _DragButtonState();

  void removeListener(void Function() onDragButtonChanged) {}

  void addListener(void Function() onDragButtonChanged) {}

  Point position() {
    return point;
  }

  /// Determine where on the edge of the circle the button should be positioned
  static setPointOnTime(double time) {
    double theta = (-pi * time / 6.0) + (pi / 2.0);
    double x = (pieRadius * cos(theta)) + pieRadius;
    double y = -(pieRadius * sin(theta)) + pieRadius;

    return Point.parameterized(x: x, y: y);
  }

  static double getTimeFromPoint(Point point) {
    // Calculate the center of the circle
    double centerX = pieRadius;
    double centerY = pieRadius;
    // Calculate the vector from the center to the given point
    double deltaX = point.x - centerX;
    double deltaY = point.y - centerY;
    // Calculate the angle (theta) relative to the positive x-axis
    double theta =
        atan2(-deltaY, deltaX); // Negate deltaY because y-axis is inverted
    // Normalize theta to start from the top of the clock (12 o'clock)
    theta = (pi / 2) - theta;
    // Ensure theta is in the range [0, 2*pi)
    if (theta < 0) {
      theta += 2 * pi;
    }
    // Map the angle to a time value
    double time = (theta * 6.0) / pi;
    // Clamp time to the range [0, 12) to handle floating-point precision issues
    if (time >= 12.0) {
      time -= 12.0;
    }
    return time;
  }
}

class _DragButtonState extends State<DragButton> {
  late Point currentPosition;
  final _dragController = StreamController<void>();

  @override
  void initState() {
    super.initState();
    Point newPoint = Point();
    newPoint.x = widget.point.x;
    newPoint.y = widget.point.y;
    currentPosition = newPoint;
  }

  void _notifyListeners() {
    _dragController.add(null);
  }

  @override
  void dispose() {
    _dragController.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Positioned(
      left: currentPosition.x.toDouble(),
      top: currentPosition.y.toDouble(),
      child: GestureDetector(
        onPanUpdate: (details) {
          // Keep the Dragbutton stuck on the edge of the circle
          setState(() {
            currentPosition = getNearestSnapPoint(currentPosition, details);
          });
          _notifyListeners();
        },
        onPanEnd: (details) {
          // When the user lets go, snap the Dragbutton to the nearest 15-minute mark
          setState(() {
            currentPosition = getRoundedSnapPoint(currentPosition);
          });
          _notifyListeners();
        },
        child: widget.shown
            ? Stack(
                alignment: Alignment.center,
                children: [
                  Container(
                    width: buttonRadius * 2,
                    height: buttonRadius * 2,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: Colors.black,
                    ),
                  ),
                  Container(
                    width: buttonRadius,
                    height: buttonRadius,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: Colors.white,
                    ),
                  ),
                ],
              )
            : Stack(),
      ),
    );
  }

  static Point getNearestSnapPoint(
      Point currentPosition, DragUpdateDetails details) {
    Point current = Point.parameterized(
        x: (currentPosition.x + details.delta.dx),
        y: (currentPosition.y + details.delta.dy));
    Point newPoint =
        DragButton.setPointOnTime(DragButton.getTimeFromPoint(current));
    return newPoint;
  }

  static Point getRoundedSnapPoint(Point current) {
    double time = DragButton.getTimeFromPoint(current);
    time = (time * 4).round() / 4;
    return DragButton.setPointOnTime(time);
  }
}
