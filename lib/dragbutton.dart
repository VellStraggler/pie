// ignore_for_file: prefer_const_constructors_in_immutables, prefer_const_constructors

import 'package:flutter/material.dart';
import 'dart:async';
import 'package:pie_agenda/point.dart';

// linden jensen

class DragButton extends StatefulWidget {
  final Point point;
  final double time;
  final bool shown;
  final Function(Point) onDragUpdate;

  DragButton({super.key, double time = 0, bool shown = true})
      : time = 0,
        point = setPointOnTime(time),
        shown = true,
        onDragUpdate = ((point) {});

  void setOnDragUpdate(Function(Point) onDragUpdate) {
    // this.onDragUpdate = onDragUpdate;
  }

  @override
  // ignore: library_private_types_in_public_api
  _DragButtonState createState() => _DragButtonState();

  void removeListener(void Function() onDragButtonChanged) {}

  void addListener(void Function() onDragButtonChanged) {}

  Point position() {
    return point;
  }

  static setPointOnTime(double time) {
    // Determine where on the edge of the circle the button should be positioned
    return Point.parameterized(x: (time * 100).toInt(), y: 0);
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
    widget.onDragUpdate(currentPosition); // Notify parent about position change
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
                x: (currentPosition.x + details.delta.dx).toInt(),
                y: (currentPosition.y + details.delta.dy).toInt());
          });
          _notifyListeners();
        },
        child: widget.shown
            ? Stack(
                alignment: Alignment.center,
                children: [
                  Container(
                    width: 24.0,
                    height: 24.0,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: Colors.black,
                    ),
                  ),
                  Container(
                    width: 12.0,
                    height: 12.0,
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
