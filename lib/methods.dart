import 'dart:math';
import 'dart:ui';
import 'package:pie_agenda/display/point.dart';
import 'package:pie_agenda/pie/diameter.dart';

class Methods {
  static int _radius() {
    return (Diameter.instance.getPieDiameter()) ~/ 2;
  }

  /// Determine where on the edge of the circle the button should be positioned
  static getPointFromTime(double time) {
    return getPointFromTimeAndRadius(time, _radius());
  }

  static getPointFromTimeAndRadius(double time, int radius) {
    double theta = (-pi * time / 6.0) + (pi / 2.0);
    double x = (radius * cos(theta)) + radius;
    double y = -(radius * sin(theta)) + radius;

    return Point.parameterized(x: x, y: y);
  }

  /// Find closest snap point.
  static Point getNearestSnapPoint(Point currentPosition, details) {
    Point current =
        Point.parameterized(x: (currentPosition.x), y: (currentPosition.y));
    Point newPoint = getPointFromTime(getTimeFromPoint(current));
    return newPoint;
  }

  /// Get closest 15-min segment snap point
  static Point getRoundedSnapPoint(Point current) {
    double time = getTimeFromPoint(current);
    time = (time * 4).round() / 4;
    return getPointFromTime(time);
  }

  static double getTimeFromPoint(Point point) {
    // Calculate the center of the circle
    int centerX = _radius();
    int centerY = _radius();
    // Calculate the vector from the center to the given point
    double deltaX = point.x - centerX;
    double deltaY = point.y - centerY;
    // Calculate the angle (theta) relative to the positive x-axis
    double theta =
        atan2(-deltaY, deltaX); // Negate deltaY because y-axis is inverted
    // Normalize theta to start from the top of the clock (12 o'clock)
    theta = (pi / 2) - theta;
    // Ensure theta is in the range [0, 2*pi)
    if (theta < 0) {
      theta += 2 * pi;
    } else if (theta >= 2 * pi) {
      theta -= 2 * pi;
    }
    // Map the angle to a time value
    double time = (theta * 6.0) / pi;
    // Clamp time to the range [0, 12) to handle floating-point precision issues
    if (time >= 12.0) {
      time -= 12.0;
    }
    return time;
  }

  static Color darkenColor(Color color) {
    const int darken = 50;
    return Color.fromRGBO(max(color.red - darken, 0),
        max(0, color.green - darken), max(0, color.blue - darken), 1.0);
  }

  static Color lightenColor(Color color, {int amount = 50}) {
    return Color.fromRGBO(
        min(255, color.red + amount),
        min(255, color.green + amount),
        min(255, color.blue + amount),
        color.opacity);
  }

  static Color averageColor(Color a, Color b) {
    return Color.fromRGBO((a.red + b.red) ~/ 2, (a.green + b.green) ~/ 2,
        (a.blue + b.blue) ~/ 2, .9);
  }
}
