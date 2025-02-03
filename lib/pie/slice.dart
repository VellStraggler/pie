import 'dart:math';
import 'package:flutter/material.dart';
import 'task.dart';

final eveningColors = [
  [255, 202, 76],
  [237, 63, 66],
  [117, 52, 117],
  [27, 31, 87],
  [0, 0, 0]
];
final morningColors = [
  [0, 0, 0],
  [33, 33, 105],
  [72, 160, 232],
  [255, 252, 76],
  [255, 202, 76]
];

class Slice {
  // This is the visuals of a single task. It shows up as a slice on the pie chart
  Task task; // Default Task
  bool showText = true; // Shown flag
  Color color;

  /// Default Constructor
  Slice()
      : task = Task(),
        color = Colors.white {
    showText = false;
  }

  /// Parameterized Constructor
  Slice.parameterized({
    required this.task,
  }) : color = Colors.white;

// Getters and Setters
  bool getShownText() {
    return showText;
  }

  bool equals(Slice other) {
    return getStartTime() == other.getStartTime() &&
        getDuration() == other.getDuration() &&
        task == other.task;
  }

  /// Set showText variable.
  void setShownText(bool showText) {
    this.showText = showText;
  }

  /// Converts the start Time to Radians
  double getStartTimeToRadians() {
    // return timeToRadians(getStartTime() - 3);
    return timeToRadians(getStartTime());
  }

  /// Converts the tasks's endTime to Radians
  double getDurationToRadians() {
    return timeToRadians(getDuration());
  }

  /// Converts a given time to Radians.
  static double timeToRadians(double time) {
    int hour = time.toInt().floor();
    int minute = ((time % 1) * 60).toInt();
    double ans = (hour % 12 + (minute / 60)) * (pi / 6);
    return ans;
  }

  /// Gets the task's startTime.
  double getStartTime() {
    return task.getStartTime();
  }

  void setStartTime(double newTime) {
    return task.setStartTime(newTime);
  }

  double getEndTime() {
    return task.getEndTime();
  }

  void setEndTime(double newTime) {
    return task.setEndTime(newTime);
  }

  /// Gets the task's endTime.
  double getDuration() {
    return task.getDuration();
  }

  String getTaskName() {
    return task.getTaskName();
  }

  /// There are 4 colors assigned to each 3-hour segment on a clock
  static Color colorFromTime(double time, bool isAfternoon) {
    var colorSet = morningColors;
    if (isAfternoon) colorSet = eveningColors;
    // get nearest 3-hour segments from 0,3,6,9,12
    int prevSegment = (time) ~/ 3;
    if (prevSegment < 0) {
      prevSegment = 0;
    }
    // We can get the distance to the next one using the distance to the previous one
    double distanceToPrev = sqrt(pow(time / 3 - prevSegment, 2));
    int nextSegment = min(prevSegment + 1, 4);
    double distanceToNext = 1 - distanceToPrev;
    var c1 = [0, 0, 0];
    // distance units are 1 per 3 hours, so this reflects as a percentage weight
    // use the distances for weighted color averaging
    for (int i = 0; i < 3; i++) {
      // Switched distToNext with distToPrev, but it works so I'm leaving it!
      c1[i] = ((colorSet[prevSegment][i] * distanceToNext) +
              (colorSet[nextSegment][i] * distanceToPrev))
          .toInt();
    }
    // Add the values together
    return Color.fromRGBO(c1[0], c1[1], c1[2], .9);
  }

// Save Data
  /// Convert task data to Json.
  Map<String, dynamic> toJson() {
    return task.toJson();
  }

  factory Slice.fromJson(Map<String, dynamic> json) {
    Task newTask = Task.fromJson(json);
    return Slice.parameterized(task: newTask);
  }

  @override
  String toString() {
    return task.toString();
  }
}
