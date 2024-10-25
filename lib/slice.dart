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
    _updatePolygon();
    dragButtonBefore.addListener(_onDragButtonChanged);
    dragButtonAfter.addListener(_onDragButtonChanged);
  }

  double getStartTimeToRadians() {
    return timeToRadians(task.getStartTime() - 3);
  }

  double getEndTimeToRadians() {
    return timeToRadians(task.getEndTime());
  }

  double getEndTime() {
    return task.getEndTime();
  }

  //detects change
  void _onDragButtonChanged() {
    _updatePolygon();
  }

  //updates the polygon to the new shape
  void _updatePolygon() {
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
}
