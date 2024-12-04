import 'package:flutter/material.dart';
import 'package:pie_agenda/pie/slice.dart';
import 'package:pie_agenda/pie/task.dart';
import 'package:pie_agenda/display/dragbutton.dart';
import 'package:pie_agenda/pie/pie.dart';
import 'package:pie_agenda/display/piepainter.dart';
import 'app_bar.dart';
import 'floating_buttons.dart';
import 'package:pie_agenda/display/point.dart';
import 'dart:math';
import 'dart:async';
import 'package:pie_agenda/display/clock.dart';

Pie pie = Pie();
PiePainter painter = PiePainter(pie: pie);

const Color mainBackground = Color.fromRGBO(15, 65, 152, 1);
const Color menuBackground = Color.fromRGBO(255, 0, 255, 1);
const Color topBackground = Color.fromRGBO(28, 111, 213, 1);

/// Home Page Widget
class MyHomePage extends StatefulWidget {
  final String title;
  const MyHomePage({super.key, required this.title});

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

/// App Home Page
class _MyHomePageState extends State<MyHomePage> {
  bool _editModeOn = false;
  bool _isAnyDragging = false; // Track if any DragButton is being dragged
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
              child: Clock(),
            ),
          ),
        ),
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
        if (_editModeOn) SizedBox(width: 10),
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

  void _toggleEditMode() {
    setState(() {
      _editModeOn = !_editModeOn; // Toggle the edit mode
    });
  }

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

  void _removeSelectedSlice() {
    // Placeholder for functionality
  }

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
                      'Start: ${_formatTime(slice.task.getStartTime())}, End: ${_formatTime(slice.task.getEndTime())}'),
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
      setState(() {
        painter = PiePainter(pie: pie);
      });
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  String _formatTime(double time) {
    int hours = time.floor();
    int minutes = ((time - hours) * 60).round();
    if (minutes == 60) {
      hours += 1;
      minutes = 0;
    }
    hours = hours % 24;
    return "$hours:$minutes";
  }

  List<Widget> _buildPie() {
    List<Widget> pieAndDragButtons = [];

    // Add the pie painter
    pieAndDragButtons.add(
      CustomPaint(
        size: const Size(
          pieDiameter + buttonDiameter,
          pieDiameter + buttonDiameter,
        ),
        painter: painter,
      ),
    );

    if (_editModeOn) {
      // Generate guide points
      List<Point> guidePoints = _generateGuidePoints(12);

      // Add drag buttons for each slice
      for (Slice slice in pie.slices) {
        pieAndDragButtons.add(
          DragButton(
            time: slice.task.getStartTime(),
            shown: true,
            guidePoints: guidePoints,
            onDragStateChanged: (isDragging) {
              setState(() {
                _isAnyDragging = isDragging;
              });
            },
          ),
        );
      }

      // Add guide buttons
      if (_isAnyDragging) {
        for (Point point in guidePoints) {
          pieAndDragButtons.add(
            Positioned(
              left: point.x - buttonRadius,
              top: point.y - buttonRadius,
              child: Container(
                width: buttonDiameter,
                height: buttonDiameter,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.grey.withOpacity(0.5),
                ),
              ),
            ),
          );
        }
      }
    }

    return pieAndDragButtons;
  }

  List<Point> _generateGuidePoints(int count) {
    List<Point> guidePoints = [];
    double centerX = pieRadius + buttonRadius; // Center X-coordinate
    double centerY = pieRadius + buttonRadius; // Center Y-coordinate

    for (int i = 0; i < count; i++) {
      double angle = 2 * pi * (i / count);
      double x = centerX + pieRadius * cos(angle);
      double y = centerY + pieRadius * sin(angle);
      guidePoints.add(Point.parameterized(x: x, y: y));
    }
    return guidePoints;
  }
}