// Emory Smith
import 'dragbutton.dart';
import 'task.dart';
import 'point.dart';

class Slice {
  // This is the visuals of a single task. It shows up as a slice on the pie chart
  DragButton dragButtonBefore;
  DragButton dragButtonAfter;
  Task task;
  Point corner;
  bool showText = true;
  Point start;
  Point end;

  //polygon instantiation is a PLACEHOLDER
  Slice(
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

// Return Times to Radians
  double getStartTimeToRadians() {
    return timeToRadians(task.getStartTime() - 3);
  }

  double getEndTimeToRadians() {
    return timeToRadians(task.getEndTime());
  }

  double getEndTime() {
    return task.getEndTime();
  }

// Detects change
  void _onDragButtonChanged() {
    _updateSlice();
  }

  //updates the polygon to the new shape
  void _updateSlice() {
    start = dragButtonBefore.position();
    end = dragButtonAfter.position();
  }

  //called when getting rid of slice
  void dispose() {
    dragButtonBefore.removeListener(_onDragButtonChanged);
    dragButtonAfter.removeListener(_onDragButtonChanged);
  }

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
