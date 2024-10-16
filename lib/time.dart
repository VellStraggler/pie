// Tafara Marava is working on this
import 'package:pie_agenda/point.dart';

class Time {
  // This is a visual of each half hour of the pie chart. Some will be invisible some of the time
    int time;
    Point point;
    bool shown; 

    Time(this.time, this.point)
      : shown =true;

    
    void displayInfo() {
      print('Time: $time, point: $point');
    }
}
