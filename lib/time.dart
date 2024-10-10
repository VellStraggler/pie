// Tafara Marava is working on this
class Time {
  // This is a visual of each half hour of the pie chart. Some will be invisible some of the time
    int time;
    Point point;
    bool shown; 

    MyClass(this.time, this.point, this.shown);

    
    void displayInfo() {
      print('Time: $time, point: $point');
    }
}
