import 'dart:math';
import 'package:flutter/material.dart';
import 'package:pie_agenda/display/point.dart';
import '../display/drag_button.dart';
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
    showText = false;
    dragButtonBefore.onDragEnd = updateToDragButtons;
    dragButtonAfter.onDragEnd = updateToDragButtons;
    // add pointers to this Slice in the dragbuttons
  }

  /// Parameterized Constructor
  Slice.parameterized({
    required this.task,
  })  : color = _generateHashedColor(
            task.getStartTime(), task.getEndTime(), task.getTaskName()),
        dragButtonAfter = DragButton(
          time: task.getEndTime(),
          shown: true,
        ),
        dragButtonBefore = DragButton(time: task.getStartTime(), shown: true) {
    dragButtonBefore.onDragEnd = updateToDragButtons;
    dragButtonAfter.onDragEnd = updateToDragButtons;
  }

// Getters and Setters
  bool getShownText() {
    return showText;
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
    if (dragButtonBefore.time != task.getStartTime()) {
      task.setStartTime(dragButtonBefore.time);
    }
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

  ///modifies startTime and duration
  void _dragStartTime(double time) {
    task.setStartTime(time);
    dragButtonBefore.setTime(time);
    double newDuration = task.getEndTime() - time;
    task.setDuration(newDuration);
  }

  void _dragEndTime(double time) {
    task.setEndTime(time);
    dragButtonAfter.setTime(time);
    double newDuration = time - task.getStartTime();
    task.setDuration(newDuration);
  }

  /// take the dragbutton locations as reference
  void updateToDragButtons(Point newPosition) {
    double newTime = DragButton.getTimeFromPoint(newPosition);
    // if its closer to endtime, it changes endtime
    if ((getEndTime() - newTime).abs() < (getStartTime() - newTime).abs()) {
      dragButtonAfter.setPoint(newPosition);
    } else {
      dragButtonBefore.setPoint(newPosition);
    }
    // edge case: times are equal
    if (dragButtonBefore.time > dragButtonAfter.time - .25 &&
        dragButtonBefore.time < dragButtonAfter.time + .25) {
      if (newTime == dragButtonAfter.time) {
        dragButtonAfter.time += .25;
      } else {
        dragButtonBefore.time -= .25;
      }
    }
    // edge case: 12 o'clock
    if (dragButtonAfter.time >= 12) {
      dragButtonAfter.time = 11.99;
    }
    if (dragButtonBefore.time > 11.75) {
      dragButtonBefore.time = 0.01;
    }

    _dragStartTime(dragButtonBefore.time);
    _dragEndTime(dragButtonAfter.time);
    task.setDuration(task.getEndTime() - task.getStartTime());
  }

// Methods
  static Color _generateHashedColor(double a, double b, String c) {
    // a and b are both from 0 to 12
    a *= (78 / 12);
    b *= (78 / 12);
    double d = min((78 / 8) * c.length, 78);
    List<int> rgb = [
      177 + a.toInt(), // Ensures a brighter color
      177 + b.toInt(),
      177 + d.toInt()
    ];

    // drop the smallest number of the 3
    int numDrop = 0;
    if (b <= a) {
      if (b <= d) {
        numDrop = 1;
      } else {
        numDrop = 2;
      }
    }
    rgb[numDrop] -= 125; // Saturates the color

    return Color.fromARGB(255, rgb[0], rgb[1], rgb[2]);
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
