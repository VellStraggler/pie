import 'slice.dart';
import 'point.dart';
import 'dragbutton.dart';
import 'task.dart';

class Pie {
  List<Slice> slices; // A list of slices in the pie chart
  Point center; // Center point of the pie chart
  double width; // Polygon representing the boundary of the pie chart

  // Constructor initializes with a single slice covering the whole circle
  Pie()
      : center = Point(0, 0), // Default center point at (0,0)
        width = 500, // A circular boundary with radius 500
        // Initialize with one full-circle slice
        slices = [
          Slice(
              corner: Point(0, 0), // Assuming a placeholder corner point
              task: Task("blank", 0.0, 11.5), // No task for the default slice
              dragButtonBefore: DragButton(
                  Point(0, 0), // Position point
                  0, // Time (initial time)
                  true // Shown flag
                  ),
              dragButtonAfter: DragButton(
                  Point(360, 0), // Position at 360 degrees
                  360, // End time
                  true // Shown flag
                  ))
        ];

  void addSlice() {
    // What Josh is doing:::
    // This is the default method for creating a new task
    // it will default to a duration of 30 minutes or 0.5
    // it will be added to the task right before the "blank" task, which should always be the last task in the list
    // just to be clear, adding at index of length - 1.
    // create this task with default text of "New Task"
    // save it to the slice list in a slice
    print("go josh");
  }
  // Method to add a slice to the pie chart
  void addSpecificSlice(int start, int end, Task task) {
    // also need an addSlice method that takes only a starting point
    // 

    // Create drag buttons based on the provided start and end positions
    DragButton dragButtonBefore = DragButton(Point(start, 0), start.toInt(), true);
    DragButton dragButtonAfter = DragButton(Point(end, 0), end.toInt(), true);


    // Create a new slice, with a corner and task (can be null or provided)
    Slice newSlice = Slice(
      corner: Point(0, 0), // Placeholder corner
      task: task, // You can assign a task if needed
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
      print(
          "Slice from ${slice.dragButtonBefore.position().x} to ${slice.dragButtonAfter.position().x} degrees.");
    }
  }

  // Method to update and redraw the pie chart after changes
  void _updatePieChart() {
    print("Pie chart updated. Total slices: ${slices.length}");
  }

  @override
  String toString() {
    return slices[0].toString();
  }
}
