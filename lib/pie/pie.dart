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
  /// Constructor initializes with a single slice covering the whole circle.
  Pie()
      : center = Point(), // Default center point at (0,0)
        width = pieDiameter, // A circular boundary with radius 500
        // Initialize with one full-circle slice
        slices = [Slice()];

  /// Parameterized Constructor
  Pie.parameterized(this.slices)
      : center = Point(),
        width = pieDiameter;

  /// Method to add a slice to the pie chart.
  void addSlice(Task task) {
    // Create a new slice, with a corner and task (can be null or provided)
    Slice newSlice = Slice.parameterized(task: task);

    // Adds the new slice to the list.
    slices.add(newSlice);
  }

  /// Remove a slice from the pie chart.
  void removeSlice(Slice sliceToRemove) {
    slices.remove(sliceToRemove);
  }

// Data Conversion
  ///Convert Pie object to JSON.
  Map<String, dynamic> toJson() {
    return {'slices': slices.map((slice) => slice.toJson()).toList()};
  }

  /// Convert JSON to a Pie object.
  factory Pie.fromJson(Map<String, dynamic> json) {
    return Pie.parameterized(json['slices'] as List<Slice>);
  }

  @override
  String toString() {
    if (slices.isEmpty) {
      return 'No slices';
    }
    return slices.map((slice) => slice.toString()).join(', ');
  }
}
