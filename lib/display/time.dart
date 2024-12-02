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

      // Offset the time slightly above the point position
      Offset textOffset = Offset(
        point.x - textPainter.width / 2,
        point.y - 20, // Adjust the vertical position
      );

      textPainter.paint(canvas, textOffset);
    }
  }
}


// class Time {
//   // This is a visual of each half hour of the pie chart. Some will be invisible some of the time
//   //
//   int time;
//   Point point;
//   bool shown;

//   Time(this.time, this.point) : shown = true;

//   void displayInfo() {
//     print('Time: $time, point: $point');
//   }
// }


