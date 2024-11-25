import 'package:flutter/material.dart';

class CustomLinePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.black
      ..strokeWidth = 1.0;

    canvas.drawLine(
      Offset(10, 50), 
      Offset(100, 50), 
      paint
    );
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => false;
}