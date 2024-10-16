import 'point.dart';
import 'polygon.dart';
import 'dart:async';

//linden jensen

class DragButton {
  Point point;
  Polygon outerCircle;
  Polygon innerCircle;
  int time;
  bool shown;
  final _dragController = StreamController<void>();

  // constructor
  DragButton(
      this.point, this.outerCircle, this.innerCircle, this.time, this.shown);

  Point position() {
    return point;
  }

  void dragTo(Point newPoint) {
    point = newPoint;
    _notifyListeners();
  }

  void addListener(void Function() listener) {
    _dragController.stream.listen((_) => listener());
  }

  void removeListener(void Function() listener) {
    _dragController.close();
  }

  void _notifyListeners() {
    _dragController.add(null);
  }
}
