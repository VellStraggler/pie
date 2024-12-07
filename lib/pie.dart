import 'slice.dart';
import 'point.dart';
import 'dragbutton.dart';
import 'task.dart';

class Pie {
  List<Slice> slices; // A list of slices in the pie chart
  Point center; // Center point of the pie chart
  double width; // Polygon representing the boundary of the pie chart

  // Constructor initializes with a single slice covering the whole circle
  /// Default Constructor
  Pie()
      : center = Point(), // Default center point at (0,0)
        width = 500, // A circular boundary with radius 500
        // Initialize with one full-circle slice
        slices = [Slice()];

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

  /// Method to add a slice to the pie chart
  void addSpecificSlice(double start, double end, Task task) {
    // Create drag buttons based on the provided start and end positions
    DragButton dragButtonBefore = DragButton(time: start, shown: true);
    DragButton dragButtonAfter = DragButton(time: end, shown: true);

    // Create a new slice, with a corner and task (can be null or provided)
    Slice newSlice = Slice.parameterized(
      corner: Point(), // Placeholder corner
      task: task, // You can assign a task if needed
      dragButtonBefore: dragButtonBefore,
      dragButtonAfter: dragButtonAfter,
    );

    // Adds the new slice to the list
    slices.add(newSlice);
    _updatePieChart();
  }

  /// Remove a slice from the pie chart
  void removeSlice(Slice sliceToRemove) {
    sliceToRemove.dispose();
    slices.remove(sliceToRemove);
    _updatePieChart();
  }

  /// Displays the current pie chart.
  void display() {
    print("Displaying the pie chart with ${slices.length} slices.");
    for (Slice slice in slices) {
      print(
          "Slice from ${slice.dragButtonBefore.point.x} to ${slice.dragButtonAfter.point.x} degrees.");
    }
  }

  /// Updates and redraws the pie chart after changes
  void _updatePieChart() {
    print("Pie chart updated. Total slices: ${slices.length}");
  }

  @override
  String toString() {
    return slices[0].toString();
  }
}
