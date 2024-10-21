import 'slice.dart';
import 'point.dart';
import 'polygon.dart';
import 'dragbutton.dart';
import 'task.dart';

class Pie {
  List<Slice> slices;  // A list of slices in the pie chart

  // Constructor initializes with a single slice covering the whole circle
  Pie() :
    // Initialize with one full-circle slice
    slices = [
      Slice(corner: Point(0, 0),  // Assuming a placeholder corner point
        task: Task("blank", 48, 0, 48),  // No task for the default slice
        dragButtonBefore: DragButton(
          Point(0, 0),  // Position point
          Polygon("circle", 10),    // Outer circle
          Polygon("circle", 14),    // Inner circle
          0,            // Time (initial time)
          true          // Shown flag
        ),   
        dragButtonAfter: DragButton(
          Point(360, 0), // Position at 360 degrees
          Polygon("circle", 400),     // Outer circle
          Polygon("circle", 396),     // Inner circle
          360,           // End time
          true           // Shown flag
        )
      )
    ];
  

  // Method to add a slice to the pie chart
  void addSlice(int start, int end, Task task) {
    // Create drag buttons based on the provided start and end positions
    DragButton dragButtonBefore = DragButton(
      Point(start, 0), 
      Polygon("circle", 10), 
      Polygon("circle", 12), 
      start.toInt(), 
      true
    );
    DragButton dragButtonAfter = DragButton(
      Point(end, 0), 
      Polygon("circle", 10), 
      Polygon("circle", 12), 
      end.toInt(), 
      true
    );

    // Create a new slice, with a corner and task (can be null or provided)
    Slice newSlice = Slice(
      corner: Point(0, 0),  // Placeholder corner
      task: task,           // You can assign a task if needed
      dragButtonBefore: dragButtonBefore,
      dragButtonAfter: dragButtonAfter,
    );

    // Add the new slice to the list
    slices.add(newSlice);
    _updatePieChart();
  }

  // Method to remove a slice from the pie chart
  void removeSlice(Slice sliceToRemove) {
    sliceToRemove.dispose();
    slices.remove(sliceToRemove);
    _updatePieChart();
  }

  // Method to display the current pie chart
  void display() {
    print("Displaying the pie chart with ${slices.length} slices.");
    for (Slice slice in slices) {
      print("Slice from ${slice.dragButtonBefore.position().x} to ${slice.dragButtonAfter.position().x} degrees.");
    }
  }

  // Method to update and redraw the pie chart after changes
  void _updatePieChart() {
    print("Pie chart updated. Total slices: ${slices.length}");
  }
}

