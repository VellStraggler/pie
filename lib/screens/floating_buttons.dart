// floating_buttons.dart
import 'package:flutter/material.dart';

/// Buttons the user can press to edit, view, or add to the Pie.
class FloatingButtons extends StatelessWidget {
  final bool editModeOn;
  final VoidCallback toggleEditMode;
  final VoidCallback showAddSliceDialog;
  final VoidCallback removeSelectedSlice;

  const FloatingButtons({
    required this.editModeOn,
    required this.toggleEditMode,
    required this.showAddSliceDialog,
    required this.removeSelectedSlice,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.end,
      children: <Widget>[
        Text(
          editModeOn ? "Edit Mode is ON " : "Edit Mode is OFF ",
          style: const TextStyle(fontSize: 24),
        ),
        FloatingActionButton(
          onPressed: toggleEditMode,
          tooltip: 'Toggle Edit Mode',
          child: const Icon(Icons.edit),
        ),
        const SizedBox(width: 10),
        FloatingActionButton(
          onPressed: showAddSliceDialog,
          tooltip: 'Add Slice',
          child: const Icon(Icons.add),
        ),
        const SizedBox(width: 10),
        if (editModeOn)
          FloatingActionButton(
            onPressed: removeSelectedSlice,
            tooltip: 'Delete Slice',
            child: const Icon(Icons.delete_forever),
          )
      ],
    );
  }
}
