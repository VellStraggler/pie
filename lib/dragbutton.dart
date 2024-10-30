import 'point.dart';
import 'dart:async';

//linden jensen

class DragButton {
  Point point;
  int time;
  bool shown;
  final _dragController = StreamController<void>();

  /// Default Constructor
  DragButton()
      : point = Point(),
        time = 0,
        shown = true;

  /// Parameterized constructor
  DragButton.parameterized(this.point, this.time, this.shown);

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
