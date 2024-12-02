import 'slice.dart';
import '../display/point.dart';
import 'task.dart';

const double pieDiameter = 500;
const double pieRadius = pieDiameter / 2;

class Pie {
  List<Slice> slices; // A list of slices in the pie chart
  Point center; // Center point of the pie chart
  double width; // Pie chart radius

  /// Default Constructor
  /// Constructor initializes with a single slice covering the whole circle
  Pie()
      : center = Point(), // Default center point at (0,0)
        width = pieDiameter, // A circular boundary with radius 500
        // Initialize with one full-circle slice
        slices = [] {
    addSlice();
  }

  void addSlice() {
    // create this task with default text of "New Task"
    // save it to the slice list in a slice
    Task task = Task.parameterized("Example Task", 0, 0.5);
    addSpecificSlice(0, .5, task);
  }

  /// Method to add a slice to the pie chart
  void addSpecificSlice(double start, double end, Task task) {
    // Create a new slice, with a corner and task (can be null or provided)
    Slice newSlice = Slice.parameterized(task: task);

    // Adds the new slice to the list
    slices.add(newSlice);
    _updatePieChart();
  }

  /// Remove a slice from the pie chart
  void removeSlice(Slice sliceToRemove) {
    slices.remove(sliceToRemove);
    _updatePieChart();
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
