import 'package:flutter/material.dart';
import 'package:pie_agenda/pie/slice.dart';
import 'package:pie_agenda/pie/task.dart';
import 'package:pie_agenda/display/dragbutton.dart';
import 'package:pie_agenda/pie/pie.dart';
import 'package:pie_agenda/display/piepainter.dart';
import 'app_bar.dart';
import 'floating_buttons.dart';

Pie pie = Pie();
PiePainter painter = PiePainter(pie: pie);
bool _editModeOn = false;

/// Home Page Widget
class MyHomePage extends StatefulWidget {
  final String title;
  const MyHomePage({super.key, required this.title});

  @override
  State<MyHomePage> createState() => MyHomePageState();
}

/// App Home Page
class MyHomePageState extends State<MyHomePage> {
  @override
  void initState() {
    super.initState();
  }

  /// Creates labeled text fields for user input
  Widget _buildTextField(TextEditingController controller, String label) {
    return TextField(
      controller: controller,
      decoration: InputDecoration(labelText: label),
      keyboardType: TextInputType.number,
    );
  }

  @override

  /// Builds the display for the Home Page.
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: MyAppBar(title: widget.title),
      body: GestureDetector(
        onTapDown: (details) {
          print("Screen tapped at ${details.localPosition} within widget.");
        },
        child: Center(
          child: Positioned(
            left: 0,
            top: 0,
            child: Stack(
              alignment: Alignment.center,
              children: _buildPie(_editModeOn),
            ),
          ),
        ),
      ),
      floatingActionButton: FloatingButtons(
        editModeOn: _editModeOn,
        toggleEditMode: _toggleEditMode,
        showAddSliceDialog: _showAddSliceDialog,
        removeSelectedSlice: _removeSelectedSlice,
      ),
    );
  }

  /// Let the user edit the pie.
  void _toggleEditMode() {
    setState(() {
      _editModeOn = !_editModeOn; // Toggle the edit mode
    });
  }

  /// Opens dialog to add a new slice to the pie
  void _showAddSliceDialog() {
    final startTimeController = TextEditingController();
    final endTimeController = TextEditingController();
    final taskController = TextEditingController();

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return _buildAddSliceDialog(
          startTimeController,
          endTimeController,
          taskController,
        );
      },
    );
  }

  // WIP
  void _removeSelectedSlice() {
    // get the last slice that was selected
    // remove it from the slices
  }

  /// Dialog structure for adding a new slice
  Widget _buildAddSliceDialog(
      TextEditingController startController,
      TextEditingController durationController,
      TextEditingController taskController) {
    return AlertDialog(
      title: const Text('Add New Slice'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          _buildTextField(startController, 'Start Time'),
          _buildTextField(durationController, 'Duration'),
          _buildTextField(taskController, 'Task Description'),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Cancel'),
        ),
        TextButton(
          onPressed: () {
            _addUserSlice(
              startController.text,
              durationController.text,
              taskController.text,
            );
            Navigator.of(context).pop();
          },
          child: const Text('Add Slice'),
        ),
      ],
    );
  }

  /// Validates input and adds a new slice if valid
  void _addUserSlice(String startText, String endText, String taskText) {
    final startTime = double.tryParse(startText) ?? 0;
    final endTime = double.tryParse(endText) ?? 0;

    if (startTime >= 0 && endTime >= 0 && taskText.isNotEmpty) {
      setState(() {
        Task task = Task.parameterized(taskText, startTime, endTime);
        pie.addSpecificSlice(startTime, endTime, task);
        painter = PiePainter(pie: pie); // Update painter with new data
      });
    } else {
      print("Invalid input for start or end time, or empty task");
    }
  }
}

/// Build the PiePainter and the DragButtons being used in the program.
List<Widget> _buildPie(bool editModeOn) {
  List<Widget> pieAndDragButtons = [];
  // First item is the pie painter, the rest are dragbuttons
  // (and eventually guidebuttons too)

  pieAndDragButtons.add(
    CustomPaint(
        size: const Size(
            pieDiameter + buttonDiameter, pieDiameter + buttonDiameter),
        painter: painter),
  );
  if (editModeOn) {
    // There are n + 1 dragbuttons for n slices
    pieAndDragButtons.add(pie.slices[0].dragButtonBefore); // Here's the +1
    for (Slice slice in pie.slices) {
      pieAndDragButtons.add(slice.dragButtonAfter);
    }
  }
  return pieAndDragButtons;
}
