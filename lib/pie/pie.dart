import 'package:pie_agenda/pie/diameter.dart';

import 'slice.dart';
import '../display/point.dart';
import 'task.dart';

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
        width = Diameter.instance.pie, // A circular boundary with radius 500
        // Initialize with one full-circle slice
        slices = [],
        selectedSliceIndex = -1,
        guidebuttons = false {
    slices.add(Slice());
  }

  int getSelectedSliceIndex() {
    return selectedSliceIndex;
  }

  void setSelectedSliceIndex(int i) {
    selectedSliceIndex = i;
  }

  /// Parameterized Constructor
  Pie.parameterized(this.slices)
      : center = Point(),
        width = pieDiameter,
        selectedSliceIndex = -1,
        guidebuttons = false;

  /// Method to add a slice to the pie chart.
  void addSlice(Task task) {
    // Create a new slice, with a corner and task (can be null or provided)
    Slice newSlice = Slice.parameterized(task: task);

    // Adds the new slice to the list.
    slices.add(newSlice);
  }

  double radius() {
    return width / 2;
  }

  /// Remove the selected slice from the pie chart
  /// using the selectedSliceIndex.
  void removeSlice() {
    slices.remove(slices[selectedSliceIndex]);
    selectedSliceIndex = -1;
  }

// Data Conversion
  ///Convert Pie object to JSON.
  Map<String, dynamic> toJson() {
    return {'slices': slices.map((slice) => slice.toJson()).toList()};
  }

  /// Convert JSON to a Pie object.
  factory Pie.fromJson(Map<String, dynamic> json) {
    //assert(json is Map<String, dynamic>);
    var jsonSlices = json['slices'] as List;
    List<Slice> sliceList =
        jsonSlices.map((slice) => Slice.fromJson(slice)).toList();
    return Pie.parameterized(sliceList);
  }

  @override
  String toString() {
    if (slices.isEmpty) {
      return 'No slices';
    }
    return slices.map((slice) => slice.toString()).join(', ');
  }
}
