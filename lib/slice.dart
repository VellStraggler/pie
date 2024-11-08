// Emory Smith
import 'dragbutton.dart';
import 'task.dart';
import 'point.dart';

class Slice {
  // This is the visuals of a single task. It shows up as a slice on the pie chart
  DragButton dragButtonBefore;
  DragButton dragButtonAfter; //
  Task task; // Default Task
  Point corner; // Position Point
  bool showText = true; //Shown flag
  Point start; // Start Time
  Point end; // End time

  /// Default Constructor
  Slice()
      : corner = Point(),
        task = Task(),
        dragButtonBefore = DragButton(time: 0, shown: true), // default at 360
        dragButtonAfter = DragButton(time: 0, shown: true), // default at 360
        start = Point(),
        end = Point() {
    showText = true;
    start = dragButtonBefore.position();
    end = dragButtonAfter.position();
  }

  //polygon instantiation is a PLACEHOLDER
  /// Parameterized Constructor
  Slice.parameterized(
      {required this.corner,
      required this.task,
      required this.dragButtonBefore,
      required this.dragButtonAfter})
      : start = dragButtonBefore.point,
        end = dragButtonAfter.point {
    _updateSlice();
    dragButtonBefore.addListener(_onDragButtonChanged);
    dragButtonAfter.addListener(_onDragButtonChanged);
  }

// Getters and Setters
  /// Converts the start Time to Radians
  double getStartTimeToRadians() {
    return timeToRadians(getStartTime() - 3);
  }

  /// Converts the tasks's endTime to Radians
  double getEndTimeToRadians() {
    return timeToRadians(getEndTime());
  }

  /// Gets the task's startTime.
  double getStartTime() {
    return task.getStartTime();
  }

  /// Gets the task's endTime.
  double getEndTime() {
    return task.getEndTime();
  }

// Methods
  // Detects change
  void _onDragButtonChanged() {
    _updateSlice();
  }

  //updates the polygon to the new shape
  void _updateSlice() {
    start = dragButtonBefore.position();
    end = dragButtonAfter.position();
  }

  /// Called when getting rid of slice
  void dispose() {
    dragButtonBefore.removeListener(_onDragButtonChanged);
    dragButtonAfter.removeListener(_onDragButtonChanged);
  }

  /// Converts a given time to Radians.
  double timeToRadians(double time) {
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
}
