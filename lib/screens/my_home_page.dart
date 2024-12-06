import 'dart:async';

import 'package:flutter/material.dart';
import 'package:pie_agenda/pie/slice.dart';
import 'package:pie_agenda/pie/task.dart';
import 'package:pie_agenda/display/dragbutton.dart';
import 'package:pie_agenda/pie/pie.dart';
import 'package:pie_agenda/display/piepainter.dart';
import 'package:pie_agenda/display/clock.dart';
import 'package:pie_agenda/pie/tickmark.dart';

Pie pie = Pie();
PiePainter painter = PiePainter(pie: pie);
bool _editModeOn = false;

const Color mainBackground = Color.fromRGBO(15, 65, 152, 1);
const Color menuBackground = Color.fromRGBO(255, 0, 255, 1);
const Color topBackground = Color.fromRGBO(28, 111, 213, 1);

/// Home Page Widget
class MyHomePage extends StatefulWidget {
  final String title;
  const MyHomePage({super.key, required this.title});

  @override
  State<MyHomePage> createState() => MyHomePageState();
}

/// App Home Page
class MyHomePageState extends State<MyHomePage> {
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    startTimer();
  }

  /// Creates labeled text fields for user input
  Widget _buildTextField(TextEditingController controller, String label) {
    return TextField(
      controller: controller,
      decoration: InputDecoration(labelText: label),
      keyboardType: TextInputType.number,
    );
  }

  /// Builds the display for the Home Page.
  @override
  Widget build(BuildContext context) {
    return Scaffold(
backgroundColor: mainBackground,
        appBar: AppBar(
            backgroundColor: topBackground,
            title: Text(widget.title),
            bottom: const PreferredSize(
                preferredSize: Size.fromHeight(30.0),
                child: Align(
                    alignment: Alignment.centerLeft,
                    child: Padding(
                        padding: EdgeInsets.only(left: 16.0, bottom: 8.0),
                        child: Clock())))),
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
        floatingActionButton: _buildFloatingActionButtons());
  }

  Widget _buildFloatingActionButtons() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.end,
      children: <Widget>[
        Text(
          _editModeOn ? "Edit Mode is ON " : "Edit Mode is OFF ",
          style: const TextStyle(fontSize: 24),
        ),
        FloatingActionButton(
          onPressed: _toggleEditMode,
          tooltip: 'Toggle Edit Mode',
          child: const Icon(Icons.edit),
        ),
        const SizedBox(width: 10),
        FloatingActionButton(
          onPressed: _showAddSliceDialog,
          tooltip: 'Add Slice',
          child: const Icon(Icons.add),
        ),
        if (_editModeOn) const SizedBox(width: 10),
        if (_editModeOn)
          FloatingActionButton(
            onPressed: _removeSelectedSlice,
            tooltip: 'Delete Slice',
            child: const Icon(Icons.delete_forever),
          ),
        const SizedBox(width: 10),
        FloatingActionButton(
          onPressed: _listSlices,
          tooltip: 'List Slices',
          child: const Icon(Icons.list),
        )
      ],
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
      backgroundColor: menuBackground,
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

  /// Validates input and adds a new slice if valid.
  void _addUserSlice(String startText, String endText, String taskText) {
    final startTime = double.tryParse(startText) ?? 0;
    final duration = double.tryParse(endText) ?? 0;

    if (startTime >= 0 && duration >= 0 && taskText.isNotEmpty) {
      setState(() {
        Task task = Task.parameterized(taskText, startTime, duration);
        pie.addSlice(task);
        painter = PiePainter(pie: pie); // Update painter with new data
      });
    } else {
      print("Invalid input for start, end time, or empty task");
    }
  }

  void _listSlices() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Slices'),
          content: SingleChildScrollView(
            child: ListBody(
              children: pie.slices.map((slice) {
                return ListTile(
                  title: Text(slice.getTaskName()),
                  subtitle: Text(
                      'Start: ${_formatTime(slice.getStartTime())}, End: ${_formatTime(slice.getEndTime())}'),
                );
              }).toList(),
            ),
          ),
          actions: [
            TextButton(
              child: const Text('Close'),
              onPressed: () => Navigator.of(context).pop(),
            ),
          ],
        );
      },
    );
  }

  void startTimer() {
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      //DateTime time = DateTime.now();
      setState(() {
        //_hour = time.hour;
        //_minute = time.minute;
        //_current_time = _formatTime(_hour, _minute);
        painter = PiePainter(pie: pie);
      });
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }
}

/// Converts a slice's time to a time format.
String _formatTime(double time) {
  int hours = time.floor();
  int minutes = ((time - hours) * 60).round();
  // Handle cases where minutes might be 60 due to rounding
  if (minutes == 60) {
    hours += 1;
    minutes = 0;
  }
  // Ensure hours wrap around if exceeding 24
  hours = hours % 24;
  String timeOfDay = "$hours:$minutes";
  return timeOfDay;
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
