import 'package:flutter/material.dart';

/// Manage the Pie's state.

class PieProvider with ChangeNotifier {
  bool _editModeOn = false;
  bool get editModeOn => _editModeOn;

  void toggleEditMode() {
    _editModeOn = !_editModeOn;
    notifyListeners();
  }
}
