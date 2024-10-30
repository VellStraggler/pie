class Point {
  int x; // X axis coordinate.
  int y; // y axis coordinate.

  /// Default Constructor
  Point(this.x, this.y);

  int moveXAmount(int addToX) {
    x += addToX;
    return x;
  }

  int moveYAmount(int addToY) {
    y += addToY;
    return y;
  }

  void setPoint(int newX, int newY) {
    x = newX;
    y = newY;
  }
}
