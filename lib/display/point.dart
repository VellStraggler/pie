class Point {
  double x; // X axis coordinate.
  double y; // y axis coordinate.

  /// Default Constructor
  Point()
      : x = 0,
        y = 0;

  /// Parameterized Constructor
  Point.parameterized({required this.x, required this.y}) {}

  /// Set the Point values
  void setPoint(double newX, double newY) {
    x = newX;
    y = newY;
  }

  /// Return Point Values
  double getX() {
    return x;
  }

  double getY() {
    return y;
  }

  /// Set X axis
  void setX(double x) {
    this.x = x;
  }

  /// Set Y axis
  void setY(double y) {
    this.y = y;
  }
}
