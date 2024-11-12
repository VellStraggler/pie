// ignore_for_file: prefer_const_constructors

import 'package:flutter/material.dart';
import 'package:pie_agenda/dragbutton.dart';
import 'package:pie_agenda/pie.dart';
import 'package:pie_agenda/slice.dart';
import 'dart:math';

const double line = 1/6;

class PiePainter extends CustomPainter {
  final Pie pie;

  PiePainter({super.repaint, required this.pie});

  // This is called EVERY time the setState trigger goes off.
  @override
  void paint(Canvas canvas, Size size) {
    // Create the paint object (the previous is assumedly destroyed)
    Paint painter = Paint()
      ..color = Colors.blue
      ..strokeWidth = 3.0;

    Paint outliner = Paint()
      ..style = PaintingStyle.stroke //no fill
      ..color = Colors.black
      ..strokeWidth = 3.0;

    // draw the pie chart
    Offset centerOffset = Offset(pieRadius + buttonRadius, pieRadius + buttonRadius);
    canvas.drawCircle(centerOffset, pieRadius, painter);

    // draw the slicess
    Rect rectArea = Rect.fromCenter(
        center: centerOffset,
        width: pieDiameter - 10,
        height: pieDiameter - 10);
    for (Slice slice in pie.slices) {
      double start = slice.getStartTimeToRadians();
      double end = slice.getEndTimeToRadians();
      painter.color = slice.color;

      print('$start $end');
      canvas.drawArc(
          rectArea, start, end, true, painter); //Angles are in radians.

      canvas.drawArc(
          rectArea, start, end, true, outliner);

      final double textAngle = start + end / 2;
      final double textX = centerOffset.dx + pieRadius * 0.6 * cos(textAngle);
      final double textY = centerOffset.dy + pieRadius * 0.6 * sin(textAngle);

      _drawText(canvas, slice.task.getTaskName(), textX, textY, textAngle);
    }
  }

  void _drawText(Canvas canvas, String text, double x, double y, double angle) {
    TextStyle textStyle = TextStyle(color: Colors.black, fontSize: 14);
    TextSpan textSpan = TextSpan(text: text, style: textStyle);
    TextPainter textPainter = TextPainter(text: textSpan, textDirection: TextDirection.ltr);
    textPainter.layout();
    canvas.save();
    canvas.translate(x,y);
    if (((pi/2) < angle) && (angle < (3*pi/2))) {
      canvas.rotate(angle + pi);
    }
    else {
      canvas.rotate(angle);
    }
    canvas.translate(-x,-y);
    textPainter.paint(canvas, Offset(x,y) - Offset(textPainter.width / 2, textPainter.height / 2));
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
