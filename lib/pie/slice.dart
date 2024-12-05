import 'dart:math';

import 'package:flutter/material.dart';

import '../display/dragbutton.dart';
import 'task.dart';

class Slice {
  // This is the visuals of a single task. It shows up as a slice on the pie chart
  DragButton dragButtonBefore;
  DragButton dragButtonAfter;
  Task task; // Default Task
  bool showText = true; // Shown flag
  Color color;

  /// Default Constructor
  Slice()
      : task = Task(),
        dragButtonBefore = DragButton(time: 0, shown: true),
        dragButtonAfter = DragButton(time: 1, shown: true),
        color = _generateHashedColor(0, 1, Task().getTaskName()) {
    showText = true;
  }

  /// Parameterized Constructor
  Slice.parameterized({
    required this.task,
  })  : color = _generateHashedColor(
            task.getStartTime(), task.getEndTime(), task.getTaskName()),
        dragButtonAfter = DragButton(time: task.getEndTime(), shown: true),
        dragButtonBefore = DragButton(time: task.getStartTime(), shown: true);

// Getters and Setters
  /// Converts the start Time to Radians
  double getStartTimeToRadians() {
    return _timeToRadians(getStartTime() - 3);
  }

  /// Converts the tasks's endTime to Radians
  double getDurationToRadians() {
    return _timeToRadians(getDuration());
  }

  /// Gets the task's startTime.
  double getStartTime() {
    return task.getStartTime();
  }

  double getEndTime() {
    return task.getEndTime();
  }

  /// Gets the task's endTime.
  double getDuration() {
    return task.getDuration();
  }

  String getTaskName() {
    return task.getTaskName();
  }

  /// Converts a given time to Radians.
  double _timeToRadians(double time) {
    int hour = time.toInt();
    int minute = ((time % 1) * 60).toInt();
    double ans = (hour % 12 + minute / 60) * (2 * 3.14159265 / 12);
    return ans;
  }

  /// Create color for slice.
  static Color _generateRandomColor() {
    Random random = Random();
    List<int> rgb = [
      127 + random.nextInt(128), // Ensures a brighter color
      127 + random.nextInt(128),
      127 + random.nextInt(128)
    ];

    int numDrop = random.nextInt(3);
    rgb[numDrop] -= 75; //this demuddles the color to be more saturated

    return Color.fromARGB(255, rgb[0], rgb[1], rgb[2]);
  }

  /// Convert task data to Json.
  Map<String, dynamic> toJson() {
    return {'task': task.toJson()};
  }

  @override
  String toString() {
    return task.toString();
  }

  static Color _generateHashedColor(double a, double b, String c) {
    // a and b are both from 0 to 12
    a *= (128 / 12);
    b *= (128 / 12);
    double d = min((128 / 8) * c.length, 128);
    List<int> rgb = [
      127 + a.toInt(), // Ensures a brighter color
      127 + b.toInt(),
      127 + d.toInt()
    ];

    // drop the smallest number of the 3
    // int numDrop = 0;
    // if (b <= a) {
    //   if (b <= d) {
    //     numDrop = 1;
    //   } else {
    //     numDrop = 2;
    //   }
    // }
    // rgb[numDrop] -= 75; //this demuddles the color to be more saturated

    return Color.fromARGB(255, rgb[0], rgb[1], rgb[2]);
  }
}
