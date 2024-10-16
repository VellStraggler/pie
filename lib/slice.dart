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
  bool showText = false;

  //Polygon slicePolygon;

  Slice(this.corner, this.task, this.dragButtonBefore, this.dragButtonAfter) {
    _updatePolygon();
    dragButtonBefore.addListener(_onDragButtonChanged);
    dragButtonAfter.addListener(_onDragButtonChanged);
  }

  //detects change
  void _onDragButtonChanged() {
    _updatePolygon();
  }

  //updates the polygon to the new shape
  void _updatePolygon() {
    Point start = dragButtonBefore.position();
    Point end = dragButtonAfter.position();

    //slicePolygon = Polygon(this.corner, start, end)
  }

  //called when getting rid of slice
  void dispose() {
    dragButtonBefore.removeListener(_onDragButtonChanged);
    dragButtonAfter.removeListener(_onDragButtonChanged);
  }
}
