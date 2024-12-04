import 'package:flutter/material.dart';
import 'dart:math';

class CustomLinePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.black
      ..strokeWidth = 2.0;
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2;

    final tickLength = 10.0;

    final positions = [
      Offset(center.dx, center.dy - radius),
      Offset(center.dx + radius, center.dy),
      Offset(center.dx, center.dy + radius),
      Offset(center.dx - radius, center.dy),
    ];

    for (var pos in positions) {
      final angle = (pos - center).direction;
      final start = Offset(
        center.dx + (radius - tickLength) * cos(angle),
        center.dy + (radius - tickLength) * sin(angle),
      );
      final end = Offset(
        center.dx + radius * cos(angle),
        center.dy + radius * sin(angle)
      );
      canvas.drawLine(start, end, paint);
    }
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => false;
}