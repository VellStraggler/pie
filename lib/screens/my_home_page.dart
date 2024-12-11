import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:pie_agenda/display/point.dart';
import 'package:pie_agenda/pie/diameter.dart';
import 'package:pie_agenda/pie/slice.dart';
import 'package:pie_agenda/pie/task.dart';
import 'package:pie_agenda/display/drag_button.dart';
import 'package:pie_agenda/pie/pie.dart';
import 'package:pie_agenda/display/pie_painter.dart';
import 'package:pie_agenda/display/clock.dart';
import 'package:pie_agenda/pie/pie_manager.dart';

/// These will be re-instantiated as soon as we get the width of the screen
Pie aMPie = Pie();
Pie pMPie = Pie();
Pie pie = aMPie; //pointer
bool isAfternoon = false;
PiePainter painter = PiePainter(pie: pie);
Slice selectedSlice = Slice();
const filePath = 'assets/data/pie.json';
final PieManager manager = PieManager();
bool _isLoading = true; // Progress indicator while the data is being loaded.
const Color themeColor2 = Color.fromRGBO(39, 102, 169, 1); //(219,220,255)
const Color menuBackground = Color.fromRGBO(35, 50, 218, 1); //(212,255,234)
const Color themeColor1 = Color.fromRGBO(249, 248, 255, 1); //(238,203,255)
const Color almostBlack = Color.fromRGBO(19, 26, 155, 1);
const Color buttonColor = Color.fromRGBO(132, 173, 255, 1);

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
  final GlobalKey _gestureKey = GlobalKey();
  double? widgetHeight;
  double? widgetWidth;

  void _getWidgetSize() {
    final RenderBox renderBox =
        _gestureKey.currentContext!.findRenderObject() as RenderBox;
    setState(() {
      widgetHeight = renderBox.size.height;
      widgetWidth = renderBox.size.width;
    });
  }

  @override
  void initState() {
    super.initState();
    // Get the dimensions of the app ASAP here
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _getWidgetSize();
      // Find the smallest of the two dimensions
      double smallestDimension = min(widgetHeight!, widgetWidth!);
      // Use the dimensions here
      // Relies on AMPie being the default
      Diameter.instance.setPieDiameter(smallestDimension * .9);
      aMPie = Pie();
      pie = aMPie;
      painter = PiePainter(pie: pie);
      loadPie();
    });
    startTimer();
  }

  /// Loads aMPie and pMPie from JSON file.
  Future<void> loadPie() async {
    try {
      aMPie = await manager.loadPie("AM");
      pMPie = await manager.loadPie("PM");
      pie = isAfternoon ? pMPie : aMPie;
      painter = PiePainter(pie: pie); // Update painter with new pie
      _isLoading = false;
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
    }
  }

  /// Saves aMPie and pMPie to JSON file.
  Future<void> savePie() async {
    try {
      await manager.savePie("AM", aMPie);
      await manager.savePie("PM", pMPie);
    } catch (e) {
      print('Didn\'t save tasks:$e');
    }
  }

  /// Builds the display for the Home Page.
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: themeColor1,
        appBar: AppBar(
            backgroundColor: themeColor2,
            foregroundColor: themeColor1,
            // title:Text(widget.title)
            title: const PreferredSize(
                preferredSize: Size.fromHeight(32.0),
                child: Align(
                    alignment: Alignment.center,
                    child: Padding(
                        padding: EdgeInsets.only(bottom: 4.0),
                        child: Clock())))),
        body: GestureDetector(
          key: _gestureKey,
          onTapDown: (details) {
            _getWidgetSize();
            // We need to get the rotation from the center that a tapped point is at
            // convert it to a double time

            double tapTime = DragButton.getTimeFromPoint(Point.parameterized(
                x: details.localPosition.dx -
                    (widgetWidth! / 2) +
                    (pie.width / 2),
                y: details.localPosition.dy -
                    (widgetHeight! / 2) +
                    (pie.width / 2)));
            // Need to start from the corner of the pie, not the corner of the whole window
            // search through the slices for one whose endpoints are before and after this time
            int i = 0;
            bool found = false;
            for (Slice slice in pie.slices) {
              if (slice.getStartTime() - .2 < tapTime) {
                if (slice.getEndTime() + .2 > tapTime) {
                  //.2 accounts for dragbutton :O
                  selectedSlice = slice;
                  pie.setSelectedSliceIndex(i);
                  found = true;
                  break;
                }
              }
              i++;
            }
            if (!found) {
              pie.setSelectedSliceIndex(-1);
              // if one was not selected, deselect what we do have
            }
            savePie();
            updateScreen();
          },
          child: Center(
            child: Stack(
              alignment: Alignment.center,
              children: _buildPie(),
            ),
          ),
        ),
        floatingActionButton: _buildFloatingActionButtons());
  }

  /// Creates the buttons for editing the chart.
  Widget _buildFloatingActionButtons() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.end,
      children: <Widget>[
        FloatingActionButton(
          onPressed: _showAddSliceDialog,
          backgroundColor: buttonColor,
          tooltip: 'Add Slice',
          child: const Icon(Icons.add),
        ),
        if (isEditing()) const SizedBox(width: 10),
        if (isEditing())
          FloatingActionButton(
            onPressed: _removeSelectedSlice,
            backgroundColor: buttonColor,
            tooltip: 'Delete Slice',
            child: const Icon(Icons.delete_forever),
          ),
        const SizedBox(width: 10),
        FloatingActionButton(
          onPressed: _listSlices,
          backgroundColor: buttonColor,
          tooltip: 'List Slices',
          child: const Icon(Icons.list),
        ),
        const SizedBox(width: 10),
        //if (isAfternoon)
        FloatingActionButton(
          backgroundColor: isAfternoon ? almostBlack : buttonColor,
          foregroundColor: isAfternoon ? themeColor1 : almostBlack,
          onPressed: _switchTime,
          tooltip: isAfternoon ? 'Switch to AM' : 'Switch to PM',
          child: Text(isAfternoon ? "PM" : "AM"),
        ),
      ],
    );
  }

  /// Changes time between AM and PM.
  void _switchTime() {
    isAfternoon = !isAfternoon;
    if (isAfternoon) {
      pie = pMPie;
    } else {
      pie = aMPie;
    }
  }

  /// Creates labeled text fields for user input
  Widget _buildTextField(TextEditingController controller, String label,
      [String hintText = ""]) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: TextFormField(
        controller: controller,
        decoration: InputDecoration(labelText: label, hintText: hintText),
        keyboardType: TextInputType.number,
        validator: (value) {
          if (label != 'Task Description' &&
              (double.tryParse(value ?? '') == null)) {
            return 'Please enter a valid number';
          }
          if (label == 'Task Description' &&
              (value == null || value.trim().isEmpty)) {
            return 'Task description cannot be empty';
          }
          return null;
        },
      ),
    );
  }

  /// Creates form to add a new slice to the pie.
  void _showAddSliceDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        final startTimeController = TextEditingController();
        final durationController = TextEditingController();
        final taskController = TextEditingController();
        return AlertDialog(
          backgroundColor: themeColor1,
          title: const Text('Add New Slice'),
          content: Form(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                _buildTextField(
                    startTimeController, 'Start Time (HH:MM)', 'E.g., 6:30'),
                _buildTextField(
                    durationController, 'Duration (HH:MM)', 'E.g., 6:30'),
                _buildTextField(taskController, 'Task Description'),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () {
                final startTime = parseTime(startTimeController.text);
                double durationA = parseTime(durationController.text);
                final taskText = taskController.text.trim();
                if (startTime + durationA == 12) {
                  durationA -= .01;
                }
                final duration = durationA;
                if (startTime >= 0 &&
                    duration >= 0 &&
                    taskText.isNotEmpty &&
                    startTime + duration <= 12) {
                  setState(() {
                    final task =
                        Task.parameterized(taskText, startTime, duration);
                    pie.addSlice(task);
                    pie.selectedSliceIndex = pie.slices.length - 1;
                    painter = PiePainter(pie: pie);
                  });
                  savePie();
                  Navigator.of(context).pop();
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                        content: Text('Invalid input. Please try again.')),
                  );
                }
              },
              child: const Text('Add Slice'),
            ),
          ],
        );
      },
    );
  }

  /// Removes the last slice selected from the pie.
  void _removeSelectedSlice() {
    pie.removeSlice();
    savePie();
  }

  /// List the Tasks for the current Pie.
  void _listSlices() {
    print(aMPie.toJson('AM'));
    print(pMPie.toJson('PM'));
    pie.setSelectedSliceIndex(-1);
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: themeColor1,
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

  double parseTime(String timeString) {
    try {
      final parts = timeString.split(':');
      if (parts.length != 2) return -1;

      final hours = int.parse(parts[0]);
      final minutes = int.parse(parts[1]);

      if (hours < 0 || minutes < 0 || minutes >= 60) return -1;

      return hours + (minutes / 60.0); // Convert to fractional hours
    } catch (e) {
      return -1; // Return -1 for invalid input
    }
  }

  void updateScreen() {
    setState(() {
      painter = PiePainter(pie: pie);
    });
  }

  void startTimer() {
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      updateScreen();
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
List<Widget> _buildPie() {
  // First item is the pie painter, the rest are dragbuttons
  // (and eventually guidebuttons too)
  List<Widget> pieAndDragButtons = [];

  pieAndDragButtons.add(
    CustomPaint(
        size: Size(pie.width + buttonDiameter, pie.width + buttonDiameter),
        painter: painter),
  );
  if (isEditing()) {
    for (Slice slice in pie.slices) {
      pieAndDragButtons.add(slice.dragButtonBefore);
      pieAndDragButtons.add(slice.dragButtonAfter);
    }
  }
  // print(pie.selectedSliceIndex);
  return pieAndDragButtons;
}

bool isEditing() {
  return pie.selectedSliceIndex > -1;
}

Color darkenColor(Color color) {
  const int darken = 50;
  return Color.fromRGBO(
      color.red - darken, color.green - darken, color.blue - darken, 1.0);
}
