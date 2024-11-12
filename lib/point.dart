class Point {
  int x; // X axis coordinate.
  int y; // y axis coordinate.

  /// Default Constructor
  Point()
      : x = 0,
        y = 0;

  /// Parameterized Constructor
  Point.parameterized({required this.x, required this.y});

  /// Set the Point values
  void setPoint(int newX, int newY) {
    x = newX;
    y = newY;
  }

  /// Move X axis
  int moveXAmount(int addToX) {
    x += addToX;
    return x;
  }

  /// Move Y axis
  int moveYAmount(int addToY) {
    y += addToY;
    return y;
  }
}
