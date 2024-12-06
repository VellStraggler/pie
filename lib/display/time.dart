import 'package:pie_agenda/display/point.dart';
import 'package:flutter/material.dart';

class Time {
  int time; // Time in hours or another unit
  Point point; // Position of the time text
  bool shown; // Whether the time will be displayed

  Time(this.time, this.point) : shown = true;

  /// Render the time text near its position
  void render(Canvas canvas) {
    if (shown) {
      // Create the text to display
      final textPainter = TextPainter(
        text: TextSpan(
          text: '$time', // Display the time value
          style: const TextStyle(color: Colors.black, fontSize: 12),
        ),
        textDirection: TextDirection.ltr,
      );

      textPainter.layout();

      // Offset the time slightly next to the point position
      Offset textOffset = Offset(
        point.x + 15, // Adjust the horizontal position
        point.y - textPainter.height / 2,
      );

      textPainter.paint(canvas, textOffset);
    }
  }
}
