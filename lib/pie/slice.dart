import 'dart:math';

import 'package:flutter/material.dart';
import 'package:pie_agenda/display/point.dart';
import '../display/dragbutton.dart';
import 'task.dart';

class Slice {
  // This is the visuals of a single task. It shows up as a slice on the pie chart
  DragButton dragButtonBefore;
  DragButton dragButtonAfter;
  Task task; // Default Task
  bool showText = true; // Shown flag
  final VoidCallback? onTap;
  Color color;

  /// Default Constructor
  Slice({this.onTap, required List<Point> guidePoints})
      : task = Task(),
        dragButtonBefore =
            DragButton(time: 0, shown: true, guidePoints: guidePoints, onDragStateChanged: (isDragging) {}),
        dragButtonAfter =
            DragButton(time: 1, shown: true, guidePoints: guidePoints, onDragStateChanged: (isDragging) {}),
        color = _generateRandomColor() {
    showText = true;
  }

  /// Parameterized Constructor
  Slice.parameterized({
    required this.task,
    this.onTap,
    required List<Point> guidePoints,
  })  : dragButtonBefore = DragButton(time: task.getStartTime(), shown: true, guidePoints: guidePoints, onDragStateChanged: (isDragging) {}),
        dragButtonAfter = DragButton(time: task.getEndTime(), shown: true, guidePoints: guidePoints, onDragStateChanged: (isDragging) {}),
        color = _generateRandomColor(),
        showText = true;
// Getters and Setters
  /// Converts the start Time to Radians
  double getStartTimeToRadians() {
    return _timeToRadians(getStartTime() - 3);
  }

  /// Converts the tasks's endTime to Radians
  double getEndTimeToRadians() {
    return _timeToRadians(getEndTime());
  }

  /// Gets the task's startTime.
  double getStartTime() {
    return task.getStartTime();
  }

  /// Gets the task's endTime.
  double getEndTime() {
    return task.getEndTime();
  }

  String getTaskName() {
    return task.getTaskName();
  }

// Methods
  // Handle Taps
  void handleTap() {
    if (onTap != null) {
      onTap!();
    }
  }

  /// Converts a given time to Radians.
  double _timeToRadians(double time) {
    int hour = time.toInt();
    int minute = ((time % 1) * 60).toInt();
    double ans = (hour % 12 + minute / 60) * (2 * 3.14159265 / 12);
    return ans;
  }

  // for Tafara
  // We need a final, randomized color variable
  // We need it to not clash with the text color
  // You can do this by randomizing RGB values or randomizing a list of colors like Colors.blue
  // update the painter class to reflect this change
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
}
