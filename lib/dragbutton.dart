//<<<<<<< HEAD
//class MyClass {
  // This will be found on the corners of every task (except the center one)
  // It is meant to show up when in edit mode or zoomed in to level 3
  // It is used to drag a task's starting or ending point

//    String name;
//    int age;
//=======
//linden jensen
//>>>>>>> e09481706d681936c83085987d32d3986f100f62

class DragButton {
  Point point;           
  Polygon outerCircle;    
  Polygon innerCircle;    
  int time;              
  bool shown;       
    
  // constructor
  DragButton(this.point, this.outerCircle, this.innerCircle, this.time, this.shown);

  void dragTo(Point newPoint) {
    this.point = newPoint;
  }
}