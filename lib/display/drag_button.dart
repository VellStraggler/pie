// ignore_for_file: prefer_const_constructors_in_immutables, prefer_const_constructors
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:pie_agenda/pie/diameter.dart';
import 'package:pie_agenda/pie/pie.dart';
import 'dart:async';
import 'package:pie_agenda/display/point.dart';
import 'package:pie_agenda/pie/slice.dart';

const double buttonRadius = 20;
const double buttonDiameter = buttonRadius * 2;

// ignore: must_be_immutable
class DragButton extends StatefulWidget {
  Point point;
  double time;
  bool shown;
  late final Function(Point) onDragEnd; // callback for drag end
  late final Slice slice;
  late final Pie pie;

  DragButton({super.key, required this.time, required this.shown})
      : point = getPointFromTime(time);

  @override
  // ignore: library_private_types_in_public_api
  _DragButtonState createState() => _DragButtonState();

  void removeListener(void Function() onDragButtonChanged) {}

  void addListener(void Function() onDragButtonChanged) {}

  Point position() {
    return point;
  }

  @override
  String toString({DiagnosticLevel minLevel = DiagnosticLevel.info}) {
    return time.toString();
  }

  /// also updates point
  void setTime(double time) {
    this.time = time;
    point = getPointFromTime(time);
  }

  ///also updates time
  void setPoint(Point newPoint) {
    point = newPoint;
    time = getTimeFromPoint(point);
  }

  /// Determine where on the edge of the circle the button should be positioned
  static getPointFromTime(double time) {
    return getPointFromTimeAndRadius(time, _radius());
  }

  static getPointFromTimeAndRadius(double time, int radius) {
    double theta = (-pi * time / 6.0) + (pi / 2.0);
    double x = (radius * cos(theta)) + radius;
    double y = -(radius * sin(theta)) + radius;

    return Point.parameterized(x: x, y: y);
  }

  static int _radius() {
    return (Diameter.instance.getPieDiameter()) ~/ 2;
  }

  static double getTimeFromPoint(Point point) {
    // Calculate the center of the circle
    int centerX = _radius();
    int centerY = _radius();
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
    } else if (theta >= 2 * pi) {
      theta -= 2 * pi;
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
    currentPosition = widget.point;
    return Positioned(
      left: currentPosition.x,
      top: currentPosition.y,
      child: GestureDetector(
        onPanUpdate: (details) {
          // Keep the Dragbutton stuck on the edge of the circle
          setState(() {
            currentPosition = getNearestSnapPoint(currentPosition, details);
          });
          widget.onDragEnd(currentPosition);
          _notifyListeners();
        },
        onPanEnd: (details) {
          // When the user lets go, snap the Dragbutton to the nearest 15-minute mark
          setState(() {
            currentPosition = getRoundedSnapPoint(currentPosition);
          });
          widget.onDragEnd(currentPosition);
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
                    width: buttonRadius * 1.5,
                    height: buttonRadius * 1.5,
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

  /// Find closest snap point.
  static Point getNearestSnapPoint(
      Point currentPosition, DragUpdateDetails details) {
    Point current = Point.parameterized(
        x: (currentPosition.x + details.delta.dx),
        y: (currentPosition.y + details.delta.dy));
    Point newPoint =
        DragButton.getPointFromTime(DragButton.getTimeFromPoint(current));
    return newPoint;
  }

  /// Get
  static Point getRoundedSnapPoint(Point current) {
    double time = DragButton.getTimeFromPoint(current);
    time = (time * 4).round() / 4;
    return DragButton.getPointFromTime(time);
  }
}
