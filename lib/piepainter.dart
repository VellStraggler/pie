// ignore_for_file: prefer_const_constructors

import 'package:flutter/material.dart';
import 'package:pie_agenda/pie.dart';
import 'package:pie_agenda/slice.dart';

class PiePainter extends CustomPainter {
  final Pie pie;

  PiePainter({super.repaint, required this.pie});

  // This is called EVERY time the setState trigger goes off.
  @override
  void paint(Canvas canvas, Size size) {
    // Create the paint object (the previous is assumedly destroyed)
    Paint painter = Paint();
    painter.color = Colors.blue;
    painter.strokeWidth = 3.0;

    // draw the pie chart
    Offset centerOffset = Offset(size.width / 2, size.width / 2);
    double pieRadius = size.width / 2;
    canvas.drawCircle(centerOffset, pieRadius, painter);

    // draw the slices
    painter.color = Colors.yellow;
    Rect rectArea = Rect.fromCenter(
        center: centerOffset,
        width: pieRadius * 2 - 10,
        height: pieRadius * 2 - 10);
    print('$pie.toString()');
    for (Slice slice in pie.slices) {
      double start = slice.getStartTimeToRadians();
      double end = slice.getEndTimeToRadians();
      print('$start $end');
      canvas.drawArc(
          rectArea, start, end, true, painter); //Angles are in radians
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    // Return true if the painting should be updated, otherwise false
    return true;
  }
}
