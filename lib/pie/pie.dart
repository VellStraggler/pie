import 'slice.dart';
import '../display/point.dart';
import 'task.dart';

const double pieDiameter = 500;
const double pieRadius = pieDiameter / 2;

class Pie {
  List<Slice> slices; // A list of slices in the pie chart
  Point center; // Center point of the pie chart
  double width; // Pie chart radius
  int selectedSliceIndex;
  bool guidebuttons;

  /// Default Constructor
  /// Constructor initializes with a single slice covering the whole circle.
  Pie()
      : center = Point(), // Default center point at (0,0)
        width = pieDiameter, // A circular boundary with radius 500
        // Initialize with one full-circle slice
        slices = [Slice()],
        selectedSliceIndex = -1,
        guidebuttons = false;

  int getSelectedSliceIndex() {
    return selectedSliceIndex;
  }

  void setSelectedSliceIndex(int i) {
    selectedSliceIndex = i;
  }

  /// Method to add a slice to the pie chart.
  void addSlice(Task task) {
    // Create a new slice, with a corner and task (can be null or provided)
    Slice newSlice = Slice.parameterized(task: task);

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
