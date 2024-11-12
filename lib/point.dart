class Point {
  double x; // X axis coordinate.
  double y; // y axis coordinate.

  /// Default Constructor
  Point() : x = 0, y = 0;

  Point.parameterized(
    {required this.x,
    required this.y}
  );
  double moveXAmount(int addToX) {
    x += addToX;
    return x;
  }

  double moveYAmount(int addToY) {
    y += addToY;
    return y;
  }

  void setPoint(double newX, double newY) {
    x = newX;
    y = newY;
  }
}
