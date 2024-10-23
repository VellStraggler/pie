// Josh Zobrist and David Wells working on this
// ignore_for_file: prefer_const_constructors

import 'package:flutter/material.dart';
import 'package:flutter_polygon_clipper/flutter_polygon_clipper.dart';
import 'package:pie_agenda/point.dart';

class Polygon {
  // THIS IS for making classes with GRAPHICS
  String name;
  double width;
  Point center;

  Polygon(this.name, this.width) : center = Point(500,500);

  void displayInfo() {
    print('Name: $name, Age: $width');
  }

  Widget drawRectangle() {
    return Container(
      width: 50,
      height: 100,
      color: Colors.amber,
      child:
          Center(child: Text(name, style: const TextStyle(color: Colors.white))),
    );
  }
  // Length should be half the width of the pie circle
  Widget drawSlice(double length) {
    List<Offset> points = List.empty(growable: true);
    return ClipPath(
      clipper: PolygonClipper(PolygonPathSpecs(
        sides: 3,
        rotate: 100.0,
        borderRadiusAngle: 0.0)),
      child: Container(
        width:500,
        height: 500,
        color: Colors.blue,
      ),
    );
  }
  Widget drawCircle() {
    return Container(
      width: width,
      height: width,
      decoration: BoxDecoration(
        color: Colors.amber,
        shape: BoxShape.circle,
      ),
    );
  }
}

// void main() {
//   Polygon polygon1 = Polygon("Workout", 4, Shape: "Square", sides: 4);
//   polygon1.displayInfo();
// }
// import 'package:flutter/material.dart';

// class Polygon {
//   String name;
//   int sides;

//   Polygon(this.name, this.sides);

//   void displayInfo() {
//     print('Polygon Name: $name, Sides: $sides');
//   }

//   // This method will return a widget to draw the polygon (simplified as a colored square)
//   Widget draw() {
//     return Container(
//       width: 100.0,
//       height: 100.0,
//       color: Colors.blue,
//       child: Center(
//         child: Text(
//           '$name ($sides sides)',
//           style: TextStyle(color: Colors.white),
//         ),
//       ),
//     );
//   }
// }

// void main() {
//   runApp(MyApp());
// }

// class MyApp extends StatelessWidget {
//   @override
//   Widget build(BuildContext context) {
//     Polygon polygon = Polygon('Triangle', 3);
//     polygon.displayInfo(); // Just for console output

//     return MaterialApp(
//       home: Scaffold(
//         appBar: AppBar(title: Text('Polygon Example')),
//         body: Center(
//           child: polygon.draw(), // Draw the polygon on screen
//         ),
//       ),
//     );
//   }
// }
