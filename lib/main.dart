// ignore_for_file: avoid_print, prefer_final_fields

import 'package:flutter/material.dart';
import 'package:pie_agenda/dragbutton.dart';
import 'package:pie_agenda/pie.dart';
import 'package:pie_agenda/piepainter.dart';
import 'package:pie_agenda/slice.dart';
import 'package:pie_agenda/task.dart';
//import 'package:pie_agenda/clock.dart';
import 'dart:async';

int zoomLevel = 1; // zoom range from 1 to 3
Pie pie = Pie();
PiePainter painter = PiePainter(pie: pie);

void main() {
  runApp(const MyApp());
}

void zoom(bool up) {
  if (up && zoomLevel < 3) {
    zoomLevel += 1;
  } else if (!up && zoomLevel > 1) {
    zoomLevel -= 1;
  }
  //maintain range of 1 to 3
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Pie Agenda',
      theme: ThemeData(
        // press "r" in console to reload while running
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: const MyHomePage(title: 'Pie Agenda Home Page'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  final String title;
  const MyHomePage({super.key, required this.title});

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  bool _editModeOn = false;
  Timer? _timer;
  int _hour = DateTime.now().hour;
  int _minute = DateTime.now().minute;
  String _current_time = "";

  // List to hold multiple drag buttons
  List<DragButton> dragButtons = [];

  @override
  void initState() {
    super.initState();
    _initializeDragButtons();
    startTimer();
  }

  void _initializeDragButtons() {
    setState(() {
      // create the dragbutton here
      // DragButton newButton = DragButton(time: 0, shown: true);
      // newButton.onDragUpdate = (updatedPoint);

      //modify the point and onDragUpdate here
    });
  }

  void _toggleEditMode() {
    setState(() {
      _editModeOn = !_editModeOn; // Toggle the edit mode
    });
  }

    // Opens dialog to add a new slice to the pie
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

  // Dialog structure for adding a new slice
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

  // Creates labeled text fields for user input
  Widget _buildTextField(TextEditingController controller, String label) {
    return TextField(
      controller: controller,
      decoration: InputDecoration(labelText: label),
      keyboardType: TextInputType.number,
    );
  }

  // Validates input and adds a new slice if valid
  void _addUserSlice(String startText, String durationText, String taskText) {
    final startTime = double.tryParse(startText) ?? 0;
    final durationTime = double.tryParse(durationText) ?? 0;

    if (startTime >= 0 && durationTime >= 0 && taskText.isNotEmpty) {
      setState(() {
        Task task = Task.parameterized(taskText, startTime, startTime + durationTime);
        pie.addSpecificSlice(startTime, durationTime, task);
        painter = PiePainter(pie: pie); // Update painter with new data
      });
    } else {
      print("Invalid input for start or end time, or empty task");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(30.0), 
          child: Align(
            alignment: Alignment.centerLeft,
            child: Padding(
              padding: const EdgeInsets.only(left: 16.0,bottom:8.0),
              child: Text(_current_time, style: const TextStyle(fontSize: 24),)
              )
            )
          )
        ),
      body: GestureDetector(
        onTapDown: (details) {
          print("Screen tapped at ${details.localPosition} within widget.");
        },
        child: Center(
          child: Stack(
            alignment: Alignment.center,
            children: _buildPie(),
          ),
        ),
      ),
      floatingActionButton: _buildFloatingActionButtons(),
    );
  }

  List<Widget> _buildPie() {
    List<Widget> dragButtons = [];
    dragButtons.add(CustomPaint(
                  size: const Size(pieDiameter + buttonDiameter, pieDiameter + buttonDiameter),
                  painter: painter
                ),);
    dragButtons.add(pie.slices[0].dragButtonBefore);
    for (Slice slice in pie.slices) {
      dragButtons.add(slice.dragButtonAfter);
    }
    return dragButtons;
  }
  // Helper function to build the floating action buttons
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
      ],
    );
  }

  // Timer stuff
String _formatTime(int hour, int min) {
    String code = "AM";
    if (hour >= 12) {
      hour = hour - 12;
      code = "PM";
    }

    return '${hour.toString()}:${min.toString().padLeft(2, '0')} $code';
  }

void startTimer() {
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      DateTime time = DateTime.now();
      setState(() {
        _hour = time.hour;
        _minute = time.minute;
        _current_time = _formatTime(_hour, _minute);
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
