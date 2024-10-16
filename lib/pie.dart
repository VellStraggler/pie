import 'slice.dart';
import 'point.dart';
import 'dragbutton.dart';

class Pie {
  List<Slice> slices;  // A list of slices in the pie chart

  // Constructor initializes with a single slice covering the whole circle
  Pie() {
    // Initialize with one full-circle slice
    slices = [
      Slice(
        corner: Point(0, 0),  // Assuming a placeholder corner point
        task: null,  // No task for the default slice
        dragButtonBefore: DragButton(0),   // Starting at 0 degrees
        dragButtonAfter: DragButton(360),  // Ending at 360 degrees
      )
    ];
  }

  // Method to add a slice to the pie chart
  void addSlice(double start, double end) {
    // Create drag buttons based on the provided start and end positions
    DragButton dragButtonBefore = DragButton(start);
    DragButton dragButtonAfter = DragButton(end);

    // Create a new slice, with a corner and task (can be null or provided)
    Slice newSlice = Slice(
      corner: Point(0, 0),  // Placeholder corner
      task: null,           // You can assign a task if needed
      dragButtonBefore: dragButtonBefore,
      dragButtonAfter: dragButtonAfter,
    );

    // Add the new slice to the list
    slices.add(newSlice);
    _updatePieChart();
  }

  // Method to remove a slice from the pie chart
  void removeSlice(Slice sliceToRemove) {
    slices.remove(sliceToRemove);
    _updatePieChart();
  }

  // Method to display the current pie chart
  void display() {
    print("Displaying the pie chart with ${slices.length} slices.");
    for (Slice slice in slices) {
      print("Slice from ${slice.dragButtonBefore.position} to ${slice.dragButtonAfter.position} degrees.");
    }
  }

  // Method to update and redraw the pie chart after changes
  void _updatePieChart() {
    print("Pie chart updated. Total slices: ${slices.length}");
  }
}
