import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:pie_agenda/display/point.dart';
import 'package:pie_agenda/pie/diameter.dart';
import 'package:pie_agenda/pie/slice.dart';
import 'package:pie_agenda/pie/task.dart';
import 'package:pie_agenda/display/drag_button.dart';
import 'package:pie_agenda/pie/pie.dart';
import 'package:pie_agenda/display/pie_painter.dart';
import 'package:pie_agenda/display/clock.dart';
import 'package:pie_agenda/pie/pie_manager.dart';
import 'package:logger/logger.dart';

final logger = Logger();

/// These will be re-instantiated as soon as we get the width of the screen
Pie aMPie = Pie();
Pie pMPie = Pie(pM: true);
Pie pie = aMPie;
//pie is a pointer to the current pie chart you're viewing (AM or PM)
bool isAfternoon = false;
PiePainter painter = PiePainter(pie: pie);
Slice selectedSlice = Slice();

// make this a global var so we can update at any point from anywhere
List<Widget> pieAndDragButtons = [];

// manager holds file storage path
final PieManager manager = PieManager();

const Color themeColor2 = Color.fromRGBO(39, 102, 169, 1); // cerulean
const Color menuBackground = Color.fromRGBO(35, 50, 218, 1); // blue
const Color themeColor1 = Color.fromRGBO(249, 248, 255, 1); // white
const Color almostBlack = Color.fromRGBO(19, 26, 155, 1); // dark blue
const Color buttonColor = Color.fromRGBO(132, 173, 255, 1); // light blue

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

  /// Used to reference the true width and height of the application,
  /// which is added after the application and its modules are
  /// instantiated
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
      Diameter.instance.setPieDiameter(smallestDimension * .8);
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
      updateScreen(); // Update painter with new pie
    } catch (e) {
      setState(() {
        updateScreen();
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
    return GestureDetector(
        key: _gestureKey,
        onTapDown: (details) {
          _getWidgetSize();
          // We need to get the rotation from the center that a tapped point is at
          // Goes up to the middle of the screen, and then back to the corner of the pie chart
          print("${widgetWidth!} ${widgetHeight!} ${pie.width}");
          int unknownOffset = borderWidth * 2;
          Point tappedPoint = Point.parameterized(
              x: details.localPosition.dx -
                  (widgetWidth! / 2) +
                  (pie.width / 2),
              y: details.localPosition.dy -
                  (widgetHeight! / 2 + unknownOffset) +
                  (pie.width / 2));
          // if you tap outside the pie chart, it deselects instead
          double distanceToCenter = sqrt(
              pow(details.localPosition.dx - (widgetWidth! / 2), 2) +
                  pow(
                      details.localPosition.dy -
                          ((widgetHeight! / 2 + unknownOffset)),
                      2));
          // print("${tappedPoint.toString()} ${distanceToCenter.toStringAsFixed(2)}");
          // sqrt((x1-x2)^2 + (y1-y2)^2)
          if (distanceToCenter > pie.radius() - buttonRadius) {
            if (distanceToCenter > pie.radius() + buttonRadius) {
              pie.setSelectedSliceIndex(-1);
            }
            // else you've pressed in the dragbutton ring. Don't deselect or change your slice
          } else {
            // convert it to a double time
            double tapTime = DragButton.getTimeFromPoint(tappedPoint);
            // print("tapped at ${tapTime.toString()}");
            int i = 0;
            bool found = false;
            // search through the slices for one whose endpoints are before and after this time
            for (Slice slice in pie.slices) {
              if (slice.getStartTime() < tapTime) {
                if (slice.getEndTime() > tapTime) {
                  //.2 accounts for dragbutton :O
                  selectedSlice = slice;
                  pie.setSelectedSliceIndex(i);
                  found = true;
                  _vibrateWithAudio(1);
                  break;
                }
              }
              i++;
            }
            if (!found) {
              pie.setSelectedSliceIndex(-1);
              // if one was not selected, deselect what we do have
            }
          }
          updateScreen();
        },
        onTapUp: (details) {
          // savePie only when user lets go
          savePie();
        },
        child: Scaffold(
            backgroundColor: themeColor1,
            appBar: AppBar(
                backgroundColor: themeColor2,
                foregroundColor: themeColor1,
                // title:Text(widget.title) // To be replaced by app logo in corner
                title: const PreferredSize(
                    preferredSize: Size.fromHeight(32.0),
                    child: Align(
                        alignment: Alignment.center,
                        child: Padding(
                            padding: EdgeInsets.only(bottom: 4.0),
                            child: Clock())))),
            body: Center(
                child: Stack(
              alignment: Alignment.center,
              children: _getPieAndDragButtons(),
            )),
            floatingActionButton: _buildFloatingActionButtons()));
  }

  void _vibrateWithAudio(int level) {
    /// Produces vibrations and a click sound when called. Does not work on Windows.
    switch (level) {
      case (1):
        HapticFeedback.lightImpact();
        break;
      case (2):
        HapticFeedback.mediumImpact();
        break;
      case (3):
        HapticFeedback.heavyImpact();
        break;
      default:
        HapticFeedback.selectionClick();
    }
    SystemSound.play(SystemSoundType.click);
    print("sound and haptics happened here! Level: $level");
  }

  /// Creates the bottom-right buttons for editing the chart.
  Widget _buildFloatingActionButtons() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.end,
      children: <Widget>[
        if (isEditing())
          FloatingActionButton(
            onPressed: _removeSelectedSlice,
            backgroundColor: buttonColor,
            tooltip: 'Delete Slice',
            child: const Icon(Icons.delete_forever),
          ),
        if (isEditing()) const SizedBox(width: 10),
        if (isEditing())
          FloatingActionButton(
            onPressed: _editSelectedSlice,
            backgroundColor: buttonColor,
            tooltip: 'Edit Slice',
            child: const Icon(Icons.edit),
          ), //this ^ replaces that v
        if (!isEditing())
          FloatingActionButton(
            onPressed: _showAddSliceDialog,
            backgroundColor: buttonColor,
            tooltip: 'Add Slice',
            child: const Icon(Icons.add),
          ),
        // 10 pixels between each button
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
    _vibrateWithAudio(3);
    isAfternoon = !isAfternoon;
    if (isAfternoon) {
      pie = pMPie;
    } else {
      pie = aMPie;
    }
  }

  /// Creates labeled text fields for user input
  /// assumes TextInputType by the hint (0:00 includes a ":" and therefore
  /// accepts numbers with ":" as an option)
  Widget _buildTextField(TextEditingController controller, String label,
      [String hintText = ""]) {
    TextInputType textInputType = TextInputType.text;
    if (hintText.contains(":")) {
      textInputType = TextInputType.number; //  (decimal: false, signed: true);
    }
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: TextFormField(
        controller: controller,
        decoration: InputDecoration(labelText: label, hintText: hintText),
        keyboardType: textInputType,
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

  void _editSelectedSlice() {}

  /// Creates form to add a new slice to the pie.
  void _showAddSliceDialog() {
    _vibrateWithAudio(1);
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
                _buildTextField(startTimeController, 'Start Time',
                    'E.g. 6:30 or 10 (hours) or 1130'),
                _buildTextField(durationController, 'Duration (HH:MM)',
                    'E.g. 6:30 or 10 (hours) or 1130'),
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
                // tasks must be at least 15 minutes in length, or 0.25 hours
                double durationA =
                    max(0.25, parseTime(durationController.text));
                var taskText = taskController.text.trim();
                if (startTime + durationA == 12) {
                  // 12:00 defaults to 0:00, so this avoids a full-day slice bug
                  durationA -= .01;
                }
                final duration = durationA;

                // Create a default slice if the user has entered nothing in
                if (taskText.isEmpty) {
                  taskText = "Default Task";
                }

                if (startTime >= 0 &&
                    duration >= 0 &&
                    taskText.isNotEmpty &&
                    startTime + duration <= 12) {
                  setState(() {
                    final task =
                        Task.parameterized(taskText, startTime, duration);
                    pie.addSlice(task);
                    pie.selectedSliceIndex = -1; //pie.slices.length - 1;
                    updateScreen();
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
    _vibrateWithAudio(2);
    pie.removeSlice();
    savePie();
  }

  /// List the Tasks for the current Pie.
  void _listSlices() {
    pie.setSelectedSliceIndex(-1);
    print(aMPie.toJson('AM'));
    print(pMPie.toJson('PM'));
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: themeColor1,
          title: const Text('Tasks Today'),
          // scrollable when there are enough tasks
          content: SingleChildScrollView(
            child: ListBody(
              children: pie.slices.map((slice) {
                return ListTile(
                  title: Text(slice.getTaskName()),
                  subtitle: Text(
                      '${_formatTime(slice.getStartTime())} to ${_formatTime(slice.getEndTime())}'),
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

  /// Takes string inputs and returns their apparent time.
  /// Nothing entered defaults to 0.
  double parseTime(String timeString) {
    // remove colon, we don't need it
    timeString.replaceAll(RegExp(r'[^0-9]'), '');
    double digs = 0;
    if (timeString.isEmpty) {
      return 0;
    }
    try {
      digs = double.parse(timeString);
    } catch (e) {
      return -1; //Error
    }
    if (digs < 12) {
      return digs;
      //hour only
    }
    if (digs == 12) {
      return 0;
    }
    if (digs < 100) {
      return digs / 60;
      // minutes only
    }
    final hours = digs ~/ 100;
    final minutes = digs % 100 / 60;
    return hours + minutes;
  }

  void updateScreen() {
    // update screen by literally remaking the painter
    // probably part of why app is so glitchy
    setState(() {
      painter = PiePainter(pie: pie);
      _buildPie();
    });
  }

  void startTimer() {
    // 100 is too quick. Deletes the delete button before the delete button
    // deletes what it's deleting
    _timer = Timer.periodic(const Duration(milliseconds: 200), (timer) {
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

List<Widget> _getPieAndDragButtons() {
  _buildPie();
  return pieAndDragButtons;
}

/// Build the PiePainter and the DragButtons being used in the program.
List<Widget> _buildPie() {
  // First item is the pie painter, the rest are dragbuttons
  // (and eventually guidebuttons too)
  pieAndDragButtons = [];

  pieAndDragButtons.add(
    CustomPaint(
        size: Size(pie.width + buttonDiameter, pie.width + buttonDiameter),
        painter: painter),
  );
  if (isEditing()) {
    for (Slice slice in pie.slices) {
      if (slice.equals(selectedSlice)) {
        slice.dragButtonBefore.createState();
        pieAndDragButtons.add(slice.dragButtonBefore);
        pieAndDragButtons.add(slice.dragButtonAfter);
      }
    }
  }
  // print(pie.selectedSliceIndex);
  return pieAndDragButtons;
}

bool isEditing() {
  /// checks if there is a current selected slice
  return pie.selectedSliceIndex > -1;
}

Color darkenColor(Color color) {
  const int darken = 50;
  return Color.fromRGBO(
      color.red - darken, color.green - darken, color.blue - darken, 1.0);
}
