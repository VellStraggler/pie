// ignore_for_file: prefer_const_constructors

import 'package:flutter/material.dart';
import 'package:pie_agenda/pie.dart';
import 'package:pie_agenda/slice.dart';
import 'dart:math';

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

    Paint outliner = Paint();
    outliner.style = PaintingStyle.stroke;
    outliner.color = Colors.blue;
    outliner.strokeWidth = 3.0;

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
          rectArea, start, end, true, painter); //Angles are in radians.

      canvas.drawArc(rectArea, start, end, true, outliner);

      final double textAngle = start + end / 2;
      final double textX = centerOffset.dx + pieRadius * 0.6 * cos(textAngle);
      final double textY = centerOffset.dy + pieRadius * 0.6 * sin(textAngle);

      _drawText(canvas, slice.task.getTaskName(), textX, textY, textAngle);
    }
  }

  void _drawText(Canvas canvas, String text, double x, double y, double angle) {
    TextStyle textStyle = TextStyle(color: Colors.black, fontSize: 14);
    TextSpan textSpan = TextSpan(text: text, style: textStyle);
    TextPainter textPainter =
        TextPainter(text: textSpan, textDirection: TextDirection.ltr);
    textPainter.layout();
    canvas.save();
    canvas.translate(x, y);
    if (((pi / 2) < angle) && (angle < (3 * pi / 2))) {
      canvas.rotate(angle + pi);
    } else {
      canvas.rotate(angle);
    }
    canvas.translate(-x, -y);
    textPainter.paint(canvas,
        Offset(x, y) - Offset(textPainter.width / 2, textPainter.height / 2));
    canvas.restore();
    //textPainter.layout();
    //textPainter.paint(canvas, Offset(x,y) - Offset(textPainter.width / 2, textPainter.height / 2));
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    // Return true if the painting should be updated, otherwise false
    return true;
  }
}
