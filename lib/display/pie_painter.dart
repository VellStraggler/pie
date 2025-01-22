import 'package:flutter/material.dart';
import 'package:pie_agenda/display/drag_button.dart';
import 'package:pie_agenda/pie/pie.dart';
import 'package:pie_agenda/pie/slice.dart';
import 'dart:math';
import 'package:pie_agenda/display/point.dart';
import 'package:pie_agenda/screens/my_home_page.dart';

const double line = 1 / 6;
const int borderWidth = 12;
const int dragButtonOffset = buttonRadius ~/ 2;

/// Creates the pie displayed on screen.
class PiePainter extends CustomPainter {
  final Pie pie;

  PiePainter({super.repaint, required this.pie});

  int getOffset() {
    return buttonRadius.toInt();
  }

  // This is called EVERY time the setState trigger goes off.
  @override
  void paint(Canvas canvas, Size size) {
    // Create the paint object (the previous is assumedly destroyed)
    Paint painter = Paint()
      ..color = almostBlack
      ..strokeWidth = 3.0;

    Paint outliner = Paint()
      ..style = PaintingStyle.stroke //no fill
      ..color = almostBlack
      ..strokeWidth = 3.0;

    // Draw time
    Rect timeArea = Rect.fromCenter(
        center: Offset(pie.radius() + getOffset(), pie.radius() + getOffset()),
        width: pie.width + 25,
        height: pie.width + 25);
    DateTime time = DateTime.now();
    int hour = time.hour;
    int minute = time.minute;
    int second = time.second;
    if (isAfternoon) {
      if (hour >= 12) {
        hour = hour - 12;
      } else {
        hour = 0;
        minute = 0;
        second = 0;
      }
    } else {
      //AM
      if (hour >= 12) {
        hour = 11;
        minute = 59;
        second = 59;
      }
    }
    double radianTime = (hour + minute / 60 + second / 3600) * pi / 6;
    painter.color = buttonColor;
    double midnight = (3 * pi / 2);
    canvas.drawArc(timeArea, midnight + radianTime, (2 * pi) - (radianTime),
        true, painter);
    painter.color = almostBlack;
    canvas.drawArc(timeArea, midnight, radianTime, true, painter);
    // End tick of the time
    painter.color = themeColor1;
    canvas.drawArc(
        timeArea, midnight + radianTime - (.01), (.02), true, painter);

    // Create offset for pie and slices
    Offset centerOffset =
        Offset(pie.radius() + getOffset(), pie.radius() + getOffset());

    // Draw the pie chart.
    painter.color = themeColor1;
    canvas.drawCircle(centerOffset, pie.radius() - borderWidth, painter);

    // Draw the slices
    Rect rectArea = Rect.fromCenter(
        center: centerOffset, width: pie.width, height: pie.width);
    int i = 0;
    for (Slice slice in pie.slices) {
      slice.setShownText(false);
      double start = slice.getStartTimeToRadians() - Slice.timeToRadians(3);
      // This offset of 3 has never made sense, and it only applies to the start time
      double duration = slice.getDurationToRadians();
      painter.color = slice.color;
      if (i == pie.getSelectedSliceIndex()) {
        slice.setShownText(true);
        painter.color = darkenColor(slice.color);
      }

      canvas.drawArc(
          rectArea, start, duration, true, painter); //Angles are in radians.

      canvas.drawArc(rectArea, start, duration, true, outliner);

      final double textAngle = start + duration / 2;
      final double textX =
          centerOffset.dx + pie.radius() * 0.6 * cos(textAngle);
      final double textY =
          centerOffset.dy + pie.radius() * 0.6 * sin(textAngle);

      _drawSliceText(canvas, slice.task.getTaskName(), textX, textY, textAngle,
          slice.getDuration());
      i++;
    }

    // Draw Tick marks
    final tickPaint = Paint()
      ..color = Colors.white
      ..strokeWidth = 2.0;

    const int numTickMarks = 12;
    const int tickLength = borderWidth;

    for (int i = 0; i < numTickMarks; i++) {
      final double angle = (2 * pi / numTickMarks) * i;
      final start = Offset(
        centerOffset.dx + (pie.radius() - tickLength) * cos(angle),
        centerOffset.dy + (pie.radius() - tickLength) * sin(angle),
      );
      final end = Offset(
        centerOffset.dx + (pie.radius()) * cos(angle),
        centerOffset.dy + (pie.radius()) * sin(angle),
      );
      canvas.drawLine(start, end, tickPaint);
    }

    // Draw Guide buttons
    if (pie.selectedSliceIndex != -1) {
      int circleSize = borderWidth;
      painter.color = const Color.fromRGBO(158, 158, 158, .8);
      for (int i = 0; i < 48; i++) {
        Point position = DragButton.getPointFromTime(i / 4);
        // draw guidebutton at position
        canvas.drawCircle(
            Offset(position.x + getOffset(), position.y + getOffset()),
            circleSize / 2,
            painter);
      }
    }
    // Write Time outside of pie
    int timeOffset = 28;
    double fontSize = 18;
    // include all but 12 o' clock
    for (int time = 1; time < 12; time++) {
      Point position = DragButton.getPointFromTimeAndRadius(
          time.toDouble(), (pie.radius() + timeOffset).toInt());
      _drawText(canvas, time.toString(), position.x - (fontSize / 3),
          position.y - (fontSize / 3), 0, fontSize, Colors.grey);
    }
    Point twelve = DragButton.getPointFromTimeAndRadius(
        0.0, (pie.radius() + timeOffset).toInt());
    String twelveText = "noon";
    if (pie.pM) {
      twelveText = "midnight";
    }
    _drawText(canvas, twelveText, twelve.x - (fontSize / 3),
        twelve.y - (fontSize / 3), 0, fontSize, Colors.grey);
  }

  void _drawSliceText(Canvas canvas, String text, double x, double y,
      double angle, double duration) {
    // Reference the pie's diameter to know the maximum font size this text can be.
    double maxWidth = pie.radius() - 40;

    // max fontSize of 36
    // should be changed to accounts for length of text
    double fontSize = min(duration / .25 * 12, 36);
    double estTextWidth = fontSize * text.length * 0.6;

    if (estTextWidth > maxWidth) {
      fontSize = maxWidth / (text.length * 0.6);
    }
    _drawText(canvas, text, x, y, angle, fontSize, Colors.black);
  }

  void _drawText(Canvas canvas, String text, double x, double y, double angle,
      double fontSize, Color color) {
    TextStyle textStyle = TextStyle(
      color: color,
      fontSize: fontSize,
    );
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
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    // Return true if the painting should be updated, otherwise false
    return true;
  }
}
