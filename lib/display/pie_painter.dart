import 'package:flutter/material.dart';
import 'package:pie_agenda/display/drag_button.dart';
import 'package:pie_agenda/display/rotated_text.dart';
import 'package:pie_agenda/pie/pie.dart';
import 'package:pie_agenda/pie/slice.dart';
import 'dart:math';
import 'package:pie_agenda/display/point.dart';
import 'package:pie_agenda/screens/my_home_page.dart';

const double line = 1 / 6;
const int borderWidth = 12;
const int dragButtonOffset = buttonRadius ~/ 2;
const double textOffsetMult = 0.6;
const Color shadow = Color.fromRGBO(35, 35, 144, 0.7);

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
    double timeFormatted = hour + ((minute * 60 + second) / 3600);
    double timeInRadians = timeFormatted * pi / 6;
    painter.color = buttonColor;
    double midnightTimeInRadians = (3 * pi / 2);
    canvas.drawArc(timeArea, midnightTimeInRadians + timeInRadians,
        (2 * pi) - (timeInRadians), true, painter);
    painter.color = almostBlack;
    canvas.drawArc(
        timeArea, midnightTimeInRadians, timeInRadians, true, painter);

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
    // Keep a list of the rotated text for printing later
    List<RotatedText> rTextList = [];
    int i = 0;
    for (Slice slice in pie.slices) {
      slice.setShownText(false);
      double start = slice.getStartTimeToRadians() - Slice.timeToRadians(3);
      if (start < 0) {
        start += (2 * pi);
      }
      // This offset of 3 has never made sense, and it only applies to the start time
      double duration = slice.getDurationToRadians();
      // painter.color = slice.color;
      var color1 = Slice.colorFromTime(slice.getStartTime(), isAfternoon);
      var color2 = Slice.colorFromTime(slice.getEndTime(), isAfternoon);
      var avgColor = averageColor(color1, color2);
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

      RotatedText rText = RotatedText(slice, centerOffset);
      rTextList.add(rText);
      // final double textAngle = start + duration / 2;
      // final double textX =
      //     centerOffset.dx + pie.radius() * textOffsetMult * cos(textAngle);
      // final double textY =
      //     centerOffset.dy + pie.radius() * textOffsetMult * sin(textAngle);
      // FOR DEBUGGING:
      // if (pie.selectedSliceIndex != -1) {
      //   if (slice.equals(pie.getSelectedSlice())) {
      //     print(textAngle);
      //   }
      // }
      // _drawSliceText(canvas, slice.task.getTaskName(), textX, textY, textAngle,
      //     slice.getDuration(), hasBlackText(slice));
      i++;
    }

    // grey out the time that has passed
    painter.color = shadow;
    canvas.drawArc(
        rectArea, midnightTimeInRadians, timeInRadians, true, painter);
    // // redraw the text of the slice that the current time inhabits
    // if (currentSliceByTime != null) {
    //   double start =
    //       currentSliceByTime.getStartTimeToRadians() - Slice.timeToRadians(3);
    //   if (start < 0) {
    //     start += (2 * pi);
    //   }
    //   final double textAngle =
    //       start + currentSliceByTime.getDurationToRadians() / 2;
    //   final double textX =
    //       centerOffset.dx + pie.radius() * textOffsetMult * cos(textAngle);
    //   final double textY =
    //       centerOffset.dy + pie.radius() * textOffsetMult * sin(textAngle);
    //   _drawSliceText(
    //       canvas,
    //       currentSliceByTime.task.getTaskName(),
    //       textX,
    //       textY,
    //       textAngle,
    //       currentSliceByTime.getDuration(),
    //       hasBlackText(currentSliceByTime));
    // }

    // Draw Tick marks
    final tickPaint = Paint()
      ..color = Colors.white
      ..strokeWidth = 3.0;

    const int numTickMarks = 12;
    const int tickLength = borderWidth;

    for (int i = 0; i < numTickMarks; i++) {
      final double angle = (2 * pi / numTickMarks) * i;
      final start = Offset(
        centerOffset.dx + (pie.radius() - (tickLength / 2)) * cos(angle),
        centerOffset.dy + (pie.radius() - (tickLength / 2)) * sin(angle),
      );
      final end = Offset(
        centerOffset.dx + (pie.radius() + (tickLength / 2)) * cos(angle),
        centerOffset.dy + (pie.radius() + (tickLength / 2)) * sin(angle),
      );
      canvas.drawLine(start, end, tickPaint);
    }

    // Draw Clock Hands as triangles
    double centerDiam = 24;
    final double hourAngle = (timeFormatted - 3) * (2 * pi / numTickMarks);
    final double minuteAngle =
        ((timeFormatted % 1) * 12 - 3) * (2 * pi / numTickMarks);
    // final double secondAngle = (time.second / 5 - 3) * (2 * pi / numTickMarks);
    // Won't include second hand, as this agenda focuses more on 15-minute segments
    final List<double> hands = [minuteAngle, hourAngle];
    for (int i = 0; i < hands.length; i++) {
      double angle = hands[i];
      double length =
          min(pie.radius(), (pie.radius() - tickLength) * pow(.66, i));
      final start = Offset(
        centerOffset.dx + (length - tickLength) * cos(angle),
        centerOffset.dy + (length - tickLength) * sin(angle),
      );
      final end = Offset(
        centerOffset.dx + (length + tickLength) * cos(angle),
        centerOffset.dy + (length + tickLength) * sin(angle),
      );
      tickPaint.strokeWidth = 8;
      canvas.drawLine(start, end, tickPaint);
      tickPaint.strokeWidth = 2;
      canvas.drawLine(centerOffset, end, tickPaint);
    }
    canvas.drawCircle(centerOffset, centerDiam / 2, tickPaint);

    // Draw all text over the time
    for (RotatedText rText in rTextList) {
      Color color = Colors.white;
      if (hasBlackText(rText.slice)) {
        color = Colors.black;
      }
      // don't know why its .3 off
      if (rText.slice.getEndTime() - .3 <
          timeInRadians + midnightTimeInRadians) {
        print(
            "${rText.slice.getEndTime()} < ${timeInRadians + midnightTimeInRadians}");
        color = averageColor(color, shadow);
      }
      _drawSliceText(canvas, rText.slice.task.getTaskName(), rText.textX,
          rText.textY, rText.textAngle, rText.slice.getDuration(), color);
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
      double angle, double duration, Color color) {
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

    _drawText(canvas, text, x, y, angle, fontSize, color);
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

  static Color darkenColor(Color color) {
    const int darken = 50;
    return Color.fromRGBO(max(color.red - darken, 0),
        max(0, color.green - darken), max(0, color.blue - darken), 1.0);
  }

  static Color lightenColor(Color color) {
    const int lighten = -50;
    return Color.fromRGBO(
        min(color.red - lighten, 255),
        min(255, color.green - lighten),
        min(255, color.blue - lighten),
        color.opacity);
  }

  static Color averageColor(Color a, Color b) {
    return Color.fromRGBO((a.red + b.red) ~/ 2, (a.green + b.green) ~/ 2,
        (a.blue + b.blue) ~/ 2, .9);
  }
}
