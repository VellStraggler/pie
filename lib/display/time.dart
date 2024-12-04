import 'package:pie_agenda/display/point.dart';

class Time {
  double time; // Time in hours or another unit
  Point point; // Position of the time text
  bool shown; // Whether the time will be displayed

  Time(this.time, this.point) : shown = true;

  void displayInfo() {
    print('Time: $time, point: $point');
  }
}
