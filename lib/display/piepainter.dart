// ignore_for_file: prefer_const_constructors

import 'package:flutter/material.dart';
import 'package:pie_agenda/display/dragbutton.dart';
import 'package:pie_agenda/pie/pie.dart';
import 'package:pie_agenda/pie/slice.dart';
import 'dart:math';
import 'package:pie_agenda/display/point.dart';

const double line = 1 / 6;

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

    // Draw time
    Rect timeArea = Rect.fromCenter(
        center: Offset(pieRadius + buttonRadius, pieRadius + buttonRadius),
        width: pieDiameter + 25,
        height: pieDiameter + 25);
    DateTime time = DateTime.now();
    double hour = time.hour.toDouble();
    if (hour >= 12) {
      hour = hour - 12;
    }
    double minute = time.minute.toDouble();
    double second = time.second.toDouble();
    double radianTime = (hour + minute / 60 + second / 3600) * pi / 6;
    painter.color = Colors.black;
    canvas.drawArc(timeArea, (3 * pi / 2) + radianTime, (2 * pi) - (radianTime),
        true, painter);
    painter.color = Colors.red;
    canvas.drawArc(timeArea, 3 * pi / 2, radianTime, true, painter);

    // Draw the pie chart.
    Offset centerOffset =
        Offset(pieRadius + buttonRadius, pieRadius + buttonRadius);
    painter.color = Colors.blue;
    canvas.drawCircle(centerOffset, pieRadius, painter);

    // Draw the slices
    Rect rectArea = Rect.fromCenter(
        center: centerOffset, width: pieDiameter, height: pieDiameter);
    int i = 0;
    for (Slice slice in pie.slices) {
      double start = slice.getStartTimeToRadians() - Slice.timeToRadians(3);
      // This offset of 3 has never made sense, and it only applies to the start time
      double duration = slice.getDurationToRadians();
      painter.color = slice.color;
      if (i == pie.getSelectedSliceIndex()) {
        int darken = 50;
        painter.color = Color.fromRGBO(slice.color.red - darken,
            slice.color.green - darken, slice.color.blue - darken, 1.0);
      }

      canvas.drawArc(
          rectArea, start, duration, true, painter); //Angles are in radians.

      canvas.drawArc(rectArea, start, duration, true, outliner);

      final double textAngle = start + duration / 2;
      final double textX = centerOffset.dx + pieRadius * 0.6 * cos(textAngle);
      final double textY = centerOffset.dy + pieRadius * 0.6 * sin(textAngle);

      _drawText(canvas, slice.task.getTaskName(), textX, textY, textAngle);
      i++;
    }

    // Draw Tick marks
    canvas.drawLine(Offset(pieDiameter, pieRadius),
        Offset(pieDiameter + 50, pieRadius), outliner);

    // Draw Guide buttons
    if (pie.selectedSliceIndex != -1) {
      for (int i = 0; i < 48; i++) {
        Point position = DragButton.getPointFromTime(i.toDouble() / 4);
        // draw guidebutton at position
        int circleSize = 12;
        painter.color = Color.fromRGBO(158, 158, 158, .8);
        canvas.drawCircle(
            Offset(position.x + circleSize, position.y + circleSize),
            circleSize.toDouble() / 2,
            painter);
      }
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
