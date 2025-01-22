import 'package:pie_agenda/pie/diameter.dart';
import 'slice.dart';
import '../display/point.dart';
import 'task.dart';

class Pie {
  List<Slice> slices; // A list of slices in the pie chart
  Point center; // Center point of the pie chart
  double width; // Pie chart radius
  int selectedSliceIndex; // The current selected slice's index.
  bool pM;

  /// Initializes with a single slice covering the whole circle.
  Pie({this.pM = false})
      : center = Point(), // Default center point at (0,0)
        width = Diameter.instance
            .getPieDiameter(), // A circular boundary with radius 500

        // Initialize with one full-circle slice
        slices = [],
        selectedSliceIndex = -1;

  /// Returns the current slice index
  int getSelectedSliceIndex() {
    return selectedSliceIndex;
  }

  /// Sets the selected slice.
  void setSelectedSliceIndex(int i) {
    selectedSliceIndex = i;
  }

  /// Parameterized Constructor
  Pie.parameterized(this.slices, {this.pM = false})
      : center = Point(),
        width = Diameter.instance.getPieDiameter(),
        selectedSliceIndex = -1;

// Getters/Setters
  List<Slice> getSlices() {
    return slices;
  }

  /// Method to add a slice to the pie chart.
  void addSlice(Task task) {
    // Create a new slice, with a corner and task (can be null or provided)
    Slice newSlice = Slice.parameterized(task: task);

    // Adds the new slice to the list.
    slices.add(newSlice);
  }

  /// Returns the Pie's radius.
  double radius() {
    return width / 2;
  }

  /// Remove the selected slice from the pie chart.
  void removeSlice() {
    // Uses the selectedSliceIndex.
    slices.remove(slices[selectedSliceIndex]);
    selectedSliceIndex = -1;
  }

// Save Data Conversion
  ///Convert Pie object to JSON.
  Map<String, dynamic> toJson(String time) {
    var json = <String, dynamic>{};
    json[time] = slices.map((slice) => slice.toJson()).toList();
    return json;
  }

  /// Convert JSON to a Pie object.
  factory Pie.fromJson(Map<String, dynamic> json, String time) {
    //assert(json is Map<String, dynamic>);
    var jsonSlices = json[time] as List;
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
