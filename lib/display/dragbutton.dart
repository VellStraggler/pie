import 'dart:math';
import 'package:flutter/material.dart';
import 'package:pie_agenda/display/point.dart';
import 'package:pie_agenda/display/time.dart';

// Define or import pieRadius
const double pieRadius = 100.0; // Adjust this value as needed

const double buttonRadius = 12;
const double buttonDiameter = buttonRadius * 2;

class DragButton extends StatefulWidget {
  final Point point;
  final double time;
  final bool shown;
  final Time timeDisplay;

  DragButton({super.key, required this.time, required this.shown})
      : point = setPointOnTime(time),
        timeDisplay = Time(time.toInt(), setPointOnTime(time));

  @override
  // ignore: library_private_types_in_public_api
  _DragButtonState createState() => _DragButtonState();

  void removeListener(void Function() onDragButtonChanged) {}

  void addListener(void Function() onDragButtonChanged) {}

  Point position() {
    return point;
  }

  /// Determine where on the edge of the circle the button should be positioned
  static Point setPointOnTime(double time) {
    double theta = (-pi * time / 6.0) + (pi / 2.0);
    return Point(cos(theta) * pieRadius, sin(theta) * pieRadius);
  }
}

class _DragButtonState extends State<DragButton> {
  @override
  Widget build(BuildContext context) {
    return Positioned(
      left: widget.point.x - buttonRadius,
      top: widget.point.y - buttonRadius,
      child: GestureDetector(
        onPanUpdate: (details) {
          setState(() {
            widget.point.x += details.delta.dx;
            widget.point.y += details.delta.dy;
          });
        },
        child: CustomPaint(
          painter: _DragButtonPainter(widget.shown),
          child: Container(
            width: buttonDiameter,
            height: buttonDiameter,
          ),
        ),
      ),
    );
  }
}

class _DragButtonPainter extends CustomPainter {
  final bool shown;

  _DragButtonPainter(this.shown);

  @override
  void paint(Canvas canvas, Size size) {
    if (shown) {
      Paint paint = Paint()
        ..color = Colors.blue
        ..style = PaintingStyle.fill;
      canvas.drawCircle(Offset(size.width / 2, size.height / 2), buttonRadius, paint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return false;
  }
}
