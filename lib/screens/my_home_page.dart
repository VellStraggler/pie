import 'package:flutter/material.dart';
import 'package:pie_agenda/pie/slice.dart';
import 'package:pie_agenda/pie/task.dart';
import 'package:pie_agenda/display/dragbutton.dart';
import 'package:pie_agenda/pie/pie.dart';
import 'package:pie_agenda/display/piepainter.dart';
import 'app_bar.dart';
import 'floating_buttons.dart';
import 'dart:async';

Pie pie = Pie();
PiePainter painter = PiePainter(pie: pie);

/// Home Page Widget
class MyHomePage extends StatefulWidget {
  final String title;
  const MyHomePage({super.key, required this.title});

  @override
  State<MyHomePage> createState() => MyHomePageState();
}

/// App Home Page
class MyHomePageState extends State<MyHomePage> {
  bool _editModeOn = false;
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
              children: _buildPie(),
            ),
          ),
        ),
      ),
      floatingActionButton: FloatingButtons(
        editModeOn: _editModeOn,
        toggleEditMode: _toggleEditMode,
        showAddSliceDialog: _showAddSliceDialog,
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

  // Timer
  //String _formatTime(int hour, int min) {
  //  String code = "AM";
  //  if (hour >= 12) {
  //    hour = hour - 12;
  //    code = "PM";
  //  }

  //  return '${hour.toString()}:${min.toString().padLeft(2, '0')} $code';
  //}

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

/// Build the Pie being used in the program.
List<Widget> _buildPie() {
  List<Widget> dragButtons = [];

  dragButtons.add(
    CustomPaint(
        size: const Size(
            pieDiameter + buttonDiameter, pieDiameter + buttonDiameter),
        painter: painter),
  );

  for (Slice slice in pie.slices) {
    dragButtons.add(slice.dragButtonBefore);
    //dragButtons.add(slice.dragButtonAfter);
  }
  return dragButtons;
}
