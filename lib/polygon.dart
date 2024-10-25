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

  Polygon(this.name, this.width) : center = Point(500, 500);

  void displayInfo() {
    print('Name: $name, Age: $width');
  }

  Widget drawRectangle() {
    return Container(
      width: 50,
      height: 100,
      color: Colors.amber,
      child: Center(
          child: Text(name, style: const TextStyle(color: Colors.white))),
    );
  }

  // Length should be half the width of the pie circle
  Widget drawSlice(double length) {
    return Positioned(
      left: 0,
      top: 0,
      child: ClipPath(
        clipper: PolygonClipper(
            PolygonPathSpecs(sides: 3, rotate: 210.0, borderRadiusAngle: 45.0)),
        child: Container(
          width: width * 2,
          height: width * 2,
          decoration: BoxDecoration(color: Colors.blue, shape: BoxShape.circle),
        ),
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
