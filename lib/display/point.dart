class Point {
  double x; // X axis coordinate.
  double y; // y axis coordinate.

  /// Default Constructor
  Point()
      : x = 0,
        y = 0;

  /// Parameterized Constructor
  Point.parameterized({required this.x, required this.y});

  /// Set the Point values
  void setPoint(double newX, double newY) {
    x = newX;
    y = newY;
  }

  /// Move X axis
  double moveXAmount(double addToX) {
    x += addToX;
    return x;
  }

  /// Move Y axis
  double moveYAmount(double addToY) {
    y += addToY;
    return y;
  }
}
