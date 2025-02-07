import 'package:flutter/material.dart';
import 'package:pie_agenda/display/drag_button.dart';
import 'package:pie_agenda/display/rotated_text.dart';
import 'package:pie_agenda/methods.dart';
import 'package:pie_agenda/pie/pie.dart';
import 'package:pie_agenda/pie/pie_time.dart';
import 'package:pie_agenda/pie/slice.dart';
import 'dart:math';
import 'package:pie_agenda/display/point.dart';
import 'package:pie_agenda/screens/my_home_page.dart';

const double line = 1 / 6;
const int borderWidth = 12;
const int dragButtonOffset = buttonRadius ~/ 2;
const double textOffsetMult = 0.6;
const double centerDiam = 24;
const Color shadow = Color.fromRGBO(35, 35, 144, 0.7);

// For hover movement animation
const int hoverDist = 24;
int currentTime = 0;
int lastFrameTime = 0;
int animProgression = 0;
int lastSelectedSlice = -1;
const int hoverAnimationSlowMult = 4;

/// Creates the pie displayed on screen.
class PiePainter extends CustomPainter {
  final Pie pie;
  // Create offset for pie and slices
  Offset centerOffset;
  // Define the radius and centerpoint for all slices
  Rect rectArea;
  Rect tinyRectArea;

  PiePainter({super.repaint, required this.pie})
      : centerOffset = const Offset(0, 0),
        rectArea =
            Rect.fromCenter(center: const Offset(0, 0), width: 0, height: 0),
        tinyRectArea =
            Rect.fromCenter(center: const Offset(0, 0), width: 0, height: 0) {
    updateWithNewDimensions();
  }

  void updateWithNewDimensions() {
    // Create offset for pie and slices
    centerOffset =
        Offset(pie.radius() + getOffset(), pie.radius() + getOffset());
    // Define the radius and centerpoint for all slices
    rectArea = Rect.fromCenter(
        center: centerOffset, width: pie.width, height: pie.width);
    tinyRectArea = Rect.fromCenter(
        center: centerOffset, width: centerDiam + 6, height: centerDiam + 6);
  }

  int getOffset() {
    return buttonRadius.toInt();
  }

  // This is called EVERY time the setState trigger goes off.
  @override
  void paint(Canvas canvas, Size size) {
    // use the lastSelectedSlice for animations
    if (pie.getSelectedSliceIndex() != -1) {
      lastSelectedSlice = pie.getSelectedSliceIndex();
    }

    // Create the paint object (the previous is assumedly destroyed)
    Paint painter = Paint()
      ..color = almostBlack
      ..strokeWidth = 3.0;

    Paint outliner = Paint()
      ..style = PaintingStyle.stroke //no fill
      ..color = almostBlack
      ..strokeWidth = 3.0;

    // only paints the shadow around the object.
    // should be called before every draw call for objects with shadows
    // set to outer to save drawing time (this is explicitly changed when drawing
    // the actual time shadow)
    Paint shadowPainter = Paint()
      ..color = shadow
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 5)
      ..strokeWidth = 3.0;

    Paint shadowOutliner = Paint()
      ..color = shadow
      ..maskFilter = const MaskFilter.blur(BlurStyle.outer, 5)
      ..strokeWidth = 3.0;

    // Draw time
    Rect timeArea = Rect.fromCenter(
        center: Offset(pie.radius() + getOffset(), pie.radius() + getOffset()),
        width: pie.width + 25,
        height: pie.width + 25);
    DateTime time = DateTime.now();
    // time = DateTime.parse("2025-02-04T15:14:15");
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
    pie.currentTime.time = timeFormatted;
    double timeInRadians = timeFormatted * pi / 6;
    painter.color = themeColor2;
    double midnightTimeInRadians = (3 * pi / 2);
    canvas.drawArc(timeArea, midnightTimeInRadians + timeInRadians,
        (2 * pi) - (timeInRadians), true, painter);
    painter.color = almostBlack;
    canvas.drawArc(
        timeArea, midnightTimeInRadians, timeInRadians, true, painter);

    // Draw the pie chart.
    painter.color = offWhite;
    canvas.drawCircle(centerOffset, pie.radius() - borderWidth, painter);

    // Draw the slices

    // Keep a list of the rotated text for printing later
    List<RotatedText> rTextList = [];
    for (int i = 0; i < pie.slices.length; i++) {
      Slice slice = pie.slices[i];
      // We'll draw the selected slice later if it's hovering rn
      slice.setShownText(false);
      var color1 = Slice.colorFromTime(slice.getStartTime(), isAfternoon);
      var color2 = Slice.colorFromTime(slice.getEndTime(), isAfternoon);
      var avgColor = Methods.averageColor(color1, color2);
      if (i == lastSelectedSlice) {
        slice.setShownText(true);
        if (i == pie.getSelectedSliceIndex()) {
          avgColor = Methods.darkenColor(avgColor);
        }
      }
      // Save this color
      slice.color = avgColor;
      painter.color = avgColor;
      if (i == lastSelectedSlice) {
        // normally would check if this is !0, but this ensures
        // there isn't a single frame where this slice is skipped entirely
        if (animProgression > hoverAnimationSlowMult * 3) {
          continue;
        }
      }

      // Prepare outline for slice
      _setOutlineColor(slice, outliner, timeFormatted);

      // Draw the given slice
      // This offset of 3 is due to 0 radians equalling 3 o'clock
      double start = slice.getStartTimeToRadians() - Slice.timeToRadians(3);
      if (start < 0) {
        start += (2 * pi);
      }
      double duration = slice.getDurationToRadians();
      // UPDATE: slice must be drawn AFTER most everything else
      if (i == lastSelectedSlice && pie.isHovering) {
        continue;
      }

      canvas.drawArc(rectArea, start, duration, true, shadowOutliner);
      canvas.drawArc(rectArea, start, duration, true, painter);

      // Draw an outline that goes around the small circle of the clock hands
      painter.color = themeColor2;
      canvas.drawArc(tinyRectArea, start, duration, true, painter);
      // Draw outline of slices
      canvas.drawArc(rectArea, start, duration, true, outliner);

      RotatedText rText = RotatedText(slice, centerOffset);
      rTextList.add(rText);
    }

    // draw shadow to grey out the time that has passed
    canvas.drawArc(
        rectArea, midnightTimeInRadians, timeInRadians, true, shadowPainter);

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
      tickPaint.strokeWidth = 2;
      canvas.drawLine(centerOffset, end, shadowOutliner);
      canvas.drawLine(centerOffset, end, tickPaint);
      tickPaint.strokeWidth = 8;
      canvas.drawLine(start, end, shadowOutliner);
      canvas.drawLine(start, end, tickPaint);
    }

    // Draw all text over the time
    for (RotatedText rText in rTextList) {
      Color color =
          Methods.getTextColorFromSliceAndTime(rText.slice, timeInRadians);
      _drawSliceText(canvas, rText.slice.task.getTaskName(), rText.textX,
          rText.textY, rText.textAngle, rText.slice.getDuration(), color);
    }
    // Write Time outside of pie
    int timeOffset = 28;
    double fontSize = 18;
    // include all but 12 o' clock
    for (int time = 1; time < 12; time++) {
      Point position = Methods.getPointFromTimeAndRadius(
          time.toDouble(), (pie.radius() + timeOffset).toInt());
      _drawText(canvas, time.toString(), position.x - (fontSize / 3),
          position.y - (fontSize / 3), 0, fontSize, Colors.grey);
    }
    Point twelve = Methods.getPointFromTimeAndRadius(
        0.0, (pie.radius() + timeOffset).toInt());
    String twelveText = "noon";
    if (pie.pM) {
      twelveText = "midnight";
    }
    _drawText(canvas, twelveText, twelve.x - (fontSize / 3),
        twelve.y - (fontSize / 3), 0, fontSize, Colors.grey);

    if (currentTime == 0) {
      currentTime = DateTime.now().millisecondsSinceEpoch;
    }
    lastFrameTime = currentTime;
    currentTime = DateTime.now().millisecondsSinceEpoch;
    int msPassed = currentTime - lastFrameTime;
    if (pie.isHovering) {
      // add the number of milliseconds that have passed in this frame
      animProgression += msPassed;
      // limited to hoverDist
      animProgression =
          min(hoverDist * hoverAnimationSlowMult, animProgression);
    } else {
      animProgression -= msPassed;
      if (animProgression <= 0) {
        animProgression = 0;
        if (pie.getSelectedSliceIndex() == -1) {
          lastSelectedSlice = -1;
        }
      }
    }
    // Draw Hovering Slice
    if (lastSelectedSlice != -1) {
      Slice slice = pie.slices[lastSelectedSlice];
      double start = slice.getStartTimeToRadians() - Slice.timeToRadians(3);
      if (start < 0) {
        start += (2 * pi);
      }
      double duration = slice.getDurationToRadians();
      double offsetAngle = start + (duration / 2);
      Offset sliceOffset = Offset(
        centerOffset.dx +
            (animProgression / hoverAnimationSlowMult) * cos(offsetAngle),
        centerOffset.dy +
            (animProgression / hoverAnimationSlowMult) * sin(offsetAngle),
      );
      Rect hoverRectArea = Rect.fromCenter(
          center: sliceOffset, width: pie.width, height: pie.width);
      // Draw shadow
      canvas.drawArc(rectArea, start, duration, true, shadowPainter);
      // Draw raised arc
      painter.color = slice.color;
      painter.maskFilter = null;
      canvas.drawArc(hoverRectArea, start, duration, true, painter);
      // Draw outline of slices
      _setOutlineColor(slice, outliner, timeFormatted);
      canvas.drawArc(hoverRectArea, start, duration, true, outliner);

      // draw the text
      RotatedText rText = RotatedText(slice, sliceOffset);
      Color color = Colors.white;
      if (Methods.hasBlackText(slice)) {
        color = Colors.black;
      }
      _drawSliceText(canvas, slice.task.getTaskName(), rText.textX, rText.textY,
          rText.textAngle, slice.getDuration(), color);
    }
    if (animProgression == 0) {
      // Draw Guide buttons
      // only around the Drag Buttons
      if (lastSelectedSlice != -1) {
        int circleSize = borderWidth;
        painter.color = const Color.fromRGBO(158, 158, 158, .8);
        Slice ss = pie.getSelectedSlice();
        double start = ss.getStartTime();
        double end = ss.getEndTime();
        for (int i = 0; i < 48; i++) {
          double time = i / 4;
          if ((time > start - 1 && time < start + 1) ||
              (time > end - 1 && time < end + 1)) {
            Point position = Methods.getPointFromTime(time);
            // draw guidebutton at position
            canvas.drawCircle(
                Offset(position.x + getOffset(), position.y + getOffset()),
                circleSize / 2,
                painter);
          }
        }
      }

      /// Draw DragButtons
      // get the points where dragbuttons are drawn
      if (isEditing()) {
        shadowPainter.color = Colors.white;
        for (DragButton drag in [pie.drag1, pie.drag2]) {
          int addedY = 30;
          if (drag.time >= 9 || drag.time <= 3) {
            addedY = -30;
          }
          Point point = drag.point;
          Offset dragOffset =
              Offset(point.x + getOffset(), point.y + getOffset());
          Offset dragTextOffset = Offset(dragOffset.dx, dragOffset.dy + addedY);

          // Draw the time of the Dragbutton
          String dragTime = PieTime(drag.time).toString();
          canvas.drawRect(
              Rect.fromCenter(
                  center: dragTextOffset,
                  width: buttonDiameter + 20,
                  height: buttonRadius + 5),
              shadowPainter);
          _drawText(canvas, dragTime, dragTextOffset.dx, dragTextOffset.dy, 0,
              24, Colors.black);

          // Draw the Dragbutton
          painter.color = Colors.black;
          canvas.drawCircle(dragOffset, buttonRadius, painter);
          painter.color = Colors.white;
          canvas.drawCircle(dragOffset, buttonRadius * .75, painter);
        }
        shadowPainter.color = shadow;
      }
    }
    // Draw the circular cap on the center of the clock
    painter.color = Colors.white;
    canvas.drawCircle(centerOffset, centerDiam / 2, shadowOutliner);
    canvas.drawCircle(centerOffset, centerDiam / 2, painter);
  }

  void _setOutlineColor(Slice slice, Paint outliner, double currentTime) {
    if (slice.getEndTime() < currentTime) {
      outliner.color = almostBlack;
    } else {
      outliner.color = themeColor2;
    }
  }

  void _drawSliceText(Canvas canvas, String text, double x, double y,
      double angle, double duration, Color color) {
    // Reference the pie's diameter to know the maximum font size this text can be.
    double maxWidth = pie.radius() - 40;
    if (duration > 3) {
      maxWidth += (pow(duration - 3, 1.3) * 5);
    }

    // should be changed to accounts for length of text
    double fontSize = min(duration / .25 * 9, 90);
    // double fontSize = duration / .25 * 9;
    double estTextWidth = fontSize * text.length * 0.6;

    if (estTextWidth > maxWidth) {
      fontSize = maxWidth / (text.length * 0.6);
    }

    // Angle ranges from -pi/2 to 3pi/2
    // at a certain duration, we don't need to angle the text
    angle = angle % (2 * pi);
    if (duration >= 2.5) {
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
    Offset textOffset = Offset(textPainter.width / 2, textPainter.height / 2);
    if (x < pie.radius() + widgetWidth!) {
      textOffset = Offset(textPainter.width / 2, textPainter.height / 2);
    }
    textPainter.paint(canvas, Offset(x, y) - textOffset);
    canvas.restore();
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    // Return true if the painting should be updated, otherwise false
    return true;
  }
}
