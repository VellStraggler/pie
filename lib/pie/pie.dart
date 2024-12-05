import 'slice.dart';
import '../display/point.dart';
import 'task.dart';
import 'dart:math';
import 'package:pie_agenda/display/dragbutton.dart';

const double pieDiameter = 500;
const double pieRadius = pieDiameter / 2;

class Pie {
  List<Slice> slices; // A list of slices in the pie chart
  Point center; // Center point of the pie chart
  double width; // Pie chart radius
  int selectedSliceIndex;

  /// Default Constructor
  /// Constructor initializes with a single slice covering the whole circle.
  Pie()
      : center = Point(), // Default center point at (0,0)
        width = pieDiameter, // A circular boundary with radius 500
        // Initialize with one full-circle slice
        slices = [Slice()],
        selectedSliceIndex = -1;

  int getSelectedSliceIndex() {
    return selectedSliceIndex;
  }

  void addSlice() {
    // create this task with default text of "New Task"
    // save it to the slice list in a slice
    Task task = Task.parameterized("Example Task", 0, 0.5);
    //List<Point> guidePoints = _generateGuidePoints(12); // Assuming 12 slices in the pie chart
    addSpecificSlice(0, .5, task);
  }
  void setSelectedSliceIndex(int i) {
    selectedSliceIndex = i;
  }

  /// Method to add a slice to the pie chart.
  void addSlice(Task task) {
    // Create a new slice, with a corner and task (can be null or provided)

    List<Point> guidePoints = [];
    double centerX = pieRadius + buttonRadius; // Center X-coordinate
    double centerY = pieRadius + buttonRadius; // Center Y-coordinate

    for (int i = 0; i < 12; i++) {
      // Calculate the angle for each guide point
      double angle = 2 * pi * (i / 12);

      // Calculate the x and y positions for each point
      double x = centerX + pieRadius * cos(angle); // Adjusted for center
      double y = centerY + pieRadius * sin(angle); // Adjusted for center

      guidePoints.add(Point.parameterized(x: x, y: y));
    }

    Slice newSlice = Slice.parameterized(task: task, guidePoints: guidePoints);

    // Adds the new slice to the list.
    slices.add(newSlice);
  }

  /// Remove a slice from the pie chart.
  void removeSlice() {
    slices.remove(slices[selectedSliceIndex]);
    selectedSliceIndex = -1;
  }

  @override
  String toString() {
    return slices[0].toString();
  }
}
