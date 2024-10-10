import 'dart:math';

import 'slice.dart';

class Pie {

  // This contains all the parts of a pie chart agenda. We will start with using just one

    List<Slice> slices; // List of slices that make up the pie chart
    Point center; // Center point of the pie chart
    Polygon circle; // Circle boundary of the pie chart (can represent the pie's shape)



    

    void displayInfo() {
      print('Name: $name, Age: $age');
    }
}