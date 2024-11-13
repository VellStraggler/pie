// ignore_for_file: prefer_const_constructors_in_immutables, prefer_const_constructors

import 'dart:math';

import 'package:flutter/material.dart';
import 'package:pie_agenda/pie.dart';
import 'dart:async';
import 'package:pie_agenda/point.dart';

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
          setState(() {
            currentPosition = Point.parameterized(
                // x: (details.localPosition.dx).toInt(),
                // y: (details.localPosition.dy).toInt());
                x: (currentPosition.x + details.delta.dx),
                y: (currentPosition.y + details.delta.dy));
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
}
