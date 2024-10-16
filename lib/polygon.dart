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
