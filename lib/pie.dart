import 'dart:math';
import 'slice.dart';
import 'polygon.dart';
import 'task.dart';
import 'point.dart';

class Pie {

  // This contains all the parts of a pie chart agenda. We will start with using just one

    List<Slice> slices; // List of slices that make up the pie chart
    Point center; // Center point of the pie chart
    Polygon circle; // Circle boundary of the pie chart (can represent the pie's shape)

    Pie({
    required this.slices,
    required this.center,
    required this.circle,
  });

}