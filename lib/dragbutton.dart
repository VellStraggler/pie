
//linden jensen
>>>>>>> e09481706d681936c83085987d32d3986f100f62

class DragButton {
  Point point;           
  Polygon outerCircle;    
  Polygon innerCircle;    
  int time;              
  bool shown;
}
    
  // constructor
  DragButton(this.point, this.outerCircle, this.innerCircle, this.time, this.shown);

  void dragTo(Point newPoint) {
    this.point = newPoint;
  }
}