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

  DragButton({super.key, point, required this.time, required this.shown, Function(Point)? onDragUpdate})
    : onDragUpdate = onDragUpdate ?? ((point) {}),
      point = Point();

  @override
  // ignore: library_private_types_in_public_api
  _DragButtonState createState() => _DragButtonState();

  void removeListener(void Function() onDragButtonChanged) {}

  void addListener(void Function() onDragButtonChanged) {}

  Point position() {
    return point;
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
            x:(currentPosition.x + details.delta.dx),
            y:(currentPosition.y + details.delta.dy));
          });
          _notifyListeners();
        },
        child: widget.shown
            ? Container(
                width: 24.0,
                height: 24.0,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.red,
                ),
              )
            : Container(),
      ),
    );
  }
}