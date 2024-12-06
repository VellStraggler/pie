// ignore_for_file: prefer_const_constructors

import 'package:flutter/material.dart';
import 'package:pie_agenda/display/dragbutton.dart';
import 'package:pie_agenda/pie/pie.dart';
import 'package:pie_agenda/pie/slice.dart';
import 'dart:math';

const double pieRadius = 100.0; // Adjust this value as needed

/// Creates the pie displayed on screen.
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

    // Draw the pie chart.
    Offset centerOffset =
        Offset(pieRadius + buttonRadius, pieRadius + buttonRadius);
    canvas.drawCircle(centerOffset, pieRadius, painter);

    // Draw the slices
    Rect rectArea = Rect.fromCircle(center: centerOffset, radius: pieRadius);
    for (Slice slice in pie.slices) {
      double start = slice.getStartTimeToRadians();
      double end = slice.getEndTimeToRadians();
      painter.color = slice.color;

      print('$start $end');
      canvas.drawArc(
          rectArea, start, end, true, painter); //Angles are in radians.

      canvas.drawArc(rectArea, start, end, true, outliner);

      final double textAngle = start + end / 2;
      final double textX = centerOffset.dx + pieRadius * 0.6 * cos(textAngle);
      final double textY = centerOffset.dy + pieRadius * 0.6 * sin(textAngle);

      _drawText(canvas, slice.task.getTaskName(), textX, textY, textAngle);

      // Render the time next to the drag buttons
      slice.dragButtonBefore.timeDisplay.render(canvas);
      slice.dragButtonAfter.timeDisplay.render(canvas);
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
    //textPainter.paint(canvas, Offset(x,y) - Offset(textPainter.width / 2, textPainter.height / 2));
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    // Return true if the painting should be updated, otherwise false
    return true;
  }
}
