// Josh Zobrist is working on this
import 'package:flutter/material.dart';

class Polygon {
  // THIS IS for making classes with GRAPHICS
  String name;
  int age;

  Polygon(this.name, this.age, {required String name, required int age});

  void displayInfo() {
    print('Name: $name, Age: $age');
  }

  Widget draw() {
    return Container(
      width: 50,
      height: 100,
      color: Colors.amber,
      child:
          Center(child: Text('$name', style: TextStyle(color: Colors.white))),
    );
  }
}

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
