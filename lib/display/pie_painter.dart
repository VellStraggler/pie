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
    // time = DateTime(2025, 1, 30, 6, 0, 0, 0, 0); // for debugging
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
    double formattedTime = hour + ((minute * 60 + second) / 3600);
    double timeInRadians = formattedTime * pi / 6;
    painter.color = buttonColor;
    double midnightTimeInRadians = (3 * pi / 2);
    canvas.drawArc(timeArea, midnightTimeInRadians + timeInRadians,
        (2 * pi) - (timeInRadians), true, painter);
    painter.color = almostBlack;
    canvas.drawArc(
        timeArea, midnightTimeInRadians, timeInRadians, true, painter);
    // End tick of the time
    painter.color = themeColor1;
    canvas.drawArc(timeArea, midnightTimeInRadians + timeInRadians - (.01),
        (.02), true, painter);

    // Create offset for pie and slices
    Offset centerOffset =
        Offset(pie.radius() + getOffset(), pie.radius() + getOffset());

    // Draw the pie chart.
    painter.color = themeColor1;
    canvas.drawCircle(centerOffset, pie.radius() - borderWidth, painter);

    // Draw the slices

    // Define the radius and centerpoint for all slices
    Rect rectArea = Rect.fromCenter(
        center: centerOffset, width: pie.width, height: pie.width);
    // Look for the slice that contains the current time
    Slice? currentSliceByTime;
    int i = 0;
    for (Slice slice in pie.slices) {
      slice.setShownText(false);
      double start = slice.getStartTimeToRadians() - Slice.timeToRadians(3);
      if (start < 0) {
        start += (2 * pi);
      }
      // This offset of 3 has never made sense, and it only applies to the start time
      double duration = slice.getDurationToRadians();

      // check if the current time inhabits this slice's task
      if (slice.getStartTime() < formattedTime &&
          slice.getEndTime() > formattedTime) {
        currentSliceByTime = slice;
        // skip drawing this slice. We'll draw it later
      }

      // painter.color = slice.color;
      var color1 = Slice.colorFromTime(slice.getStartTime(), isAfternoon);
      var color2 = Slice.colorFromTime(slice.getEndTime(), isAfternoon);
      var avgColor = Slice.averageColor(color1, color2);
      if (i == pie.getSelectedSliceIndex()) {
        slice.setShownText(true);
        avgColor = darkenColor(avgColor);
      }
      // Save this color
      slice.color = avgColor;
      painter.color = avgColor;

      // Draw the given slice
      canvas.drawArc(
          rectArea, start, duration, true, painter); //Angles are in radians.

      // Draw outline of slices
      canvas.drawArc(rectArea, start, duration, true, outliner);

      // change text to be white if background is dark enough
      bool blackText = hasBlackText(slice);

      final double textAngle = start + duration / 2;
      final double textX =
          centerOffset.dx + pie.radius() * 0.6 * cos(textAngle);
      final double textY =
          centerOffset.dy + pie.radius() * 0.6 * sin(textAngle);
      // FOR DEBUGGING:
      // if (pie.selectedSliceIndex != -1) {
      //   if (slice.equals(pie.getSelectedSlice())) {
      //     print(textAngle);
      //   }
      // }
      _drawSliceText(canvas, slice.task.getTaskName(), textX, textY, textAngle,
          slice.getDuration(), blackText);
      i++;
    }

    // grey out the time that has passed
    painter.color = const Color.fromRGBO(35, 35, 144, 0.7);
    canvas.drawArc(
        rectArea, midnightTimeInRadians, timeInRadians, true, painter);
    // redraw the text of the slice that the current time inhabits
    if (currentSliceByTime != null) {
      double start =
          currentSliceByTime.getStartTimeToRadians() - Slice.timeToRadians(3);
      if (start < 0) {
        start += (2 * pi);
      }
      final double textAngle =
          start + currentSliceByTime.getDurationToRadians() / 2;
      final double textX =
          centerOffset.dx + pie.radius() * 0.6 * cos(textAngle);
      final double textY =
          centerOffset.dy + pie.radius() * 0.6 * sin(textAngle);
      _drawSliceText(
          canvas,
          currentSliceByTime.task.getTaskName(),
          textX,
          textY,
          textAngle,
          currentSliceByTime.getDuration(),
          hasBlackText(currentSliceByTime));
    }

    // Draw Tick marks
    final tickPaint = Paint()
      ..color = Colors.white
      ..strokeWidth = 3.0;

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
    // only around the Drag Buttons
    if (pie.selectedSliceIndex != -1) {
      int circleSize = borderWidth;
      painter.color = const Color.fromRGBO(158, 158, 158, .8);
      Slice ss = pie.getSelectedSlice();
      double start = ss.getStartTime();
      double end = ss.getEndTime();
      for (int i = 0; i < 48; i++) {
        double time = i / 4;
        if ((time > start - 1 && time < start + 1) ||
            (time > end - 1 && time < end + 1)) {
          Point position = DragButton.getPointFromTime(time);
          // draw guidebutton at position
          canvas.drawCircle(
              Offset(position.x + getOffset(), position.y + getOffset()),
              circleSize / 2,
              painter);
        }
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

  bool hasBlackText(Slice slice) {
    if (slice.color.blue + slice.color.green + slice.color.red < (127 * 3)) {
      return false;
    }
    return true;
  }

  void _drawSliceText(Canvas canvas, String text, double x, double y,
      double angle, double duration, bool blackText) {
    // Reference the pie's diameter to know the maximum font size this text can be.
    double maxWidth = pie.radius() - 40;
    if (duration > 3) {
      maxWidth += (pow(duration - 3, 1.5) * 5);
    }

    // max fontSize of 36
    // should be changed to accounts for length of text
    double fontSize = min(duration / .25 * 12, 36);
    double estTextWidth = fontSize * text.length * 0.6;

    if (estTextWidth > maxWidth) {
      fontSize = maxWidth / (text.length * 0.6);
    }

    // angle ranges from -pi/2 to 3pi/2
    // at a certain duration, we don't need to angle the text
    if (duration < 2 && duration > 1.5) {
      if (angle < 0 || (angle > (pi / 2) && angle < pi)) {
        angle += ((duration - 1.5));
        if (angle > (pi / 2) && angle < pi) {
          angle = max(angle, 0);
        } else {
          angle = min(angle, 0);
        }
      } else {
        angle -= ((duration - 1.5));
        angle = max(angle, 0);
      }
    }
    if (duration >= 2) {
      angle = 0;
    }

    if (blackText) {
      _drawText(canvas, text, x, y, angle, fontSize, Colors.black);
    } else {
      _drawText(canvas, text, x, y, angle, fontSize, Colors.white);
    }
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

  Color darkenColor(Color color) {
    const int darken = 50;
    return Color.fromRGBO(max(color.red - darken, 0),
        max(0, color.green - darken), max(0, color.blue - darken), 1.0);
  }

  Color lightenColor(Color color) {
    const int lighten = -50;
    return Color.fromRGBO(
        min(color.red - lighten, 255),
        min(255, color.green - lighten),
        min(255, color.blue - lighten),
        color.opacity);
  }
}
