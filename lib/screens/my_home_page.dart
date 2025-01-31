import 'dart:async';
import 'dart:io';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:vibration/vibration.dart';
import 'package:pie_agenda/display/point.dart';
import 'package:pie_agenda/pie/diameter.dart';
import 'package:pie_agenda/pie/slice.dart';
import 'package:pie_agenda/pie/task.dart';
import 'package:pie_agenda/display/drag_button.dart';
import 'package:pie_agenda/pie/pie.dart';
import 'package:pie_agenda/display/pie_painter.dart';
import 'package:pie_agenda/display/clock.dart';
import 'package:pie_agenda/pie/pie_manager.dart';
import 'package:audioplayers/audioplayers.dart';

/// These will be re-instantiated as soon as we get the width of the screen
Pie aMPie = Pie();
Pie pMPie = Pie(pM: true);

/// A pointer to the current pie chart being viewed (AM or PM)
Pie pie = aMPie;
bool isAfternoon = false;
PiePainter painter = PiePainter(pie: pie);
const double pieToWindowRatio = .8;
final player = AudioPlayer();

// this is a global var so we can update at any point from anywhere
List<Widget> pieAndDragButtons = [];

// manager holds file storage path
final PieManager manager = PieManager();

const double padding = .05;
int unknownOffset = 53; //borderWidth * 2;
// With height 852 and width 411, offset is 53
// With height 682 and width 1265.6, offset is 26
// Width changes nothing, but device type does???
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

  /// This initializes the following:
  /// - the platform-specific pixel offset
  /// - recording the app pixel dimensions
  /// - the pie's pixel diameter
  /// - which pie to start on
  /// - the timer
  @override
  void initState() {
    super.initState();
    if (Platform.isWindows) {
      unknownOffset = 26; //otherwise, treats it as Android
    }
    player.setSource(AssetSource('data/tap.wav'));

    // Get the dimensions of the app ASAP here
    WidgetsBinding.instance.addPostFrameCallback((_) {
      updateSize();
      // Base the opening pie with whether it's in the afternoon
      if (DateTime.now().hour >= 12) {
        pMPie = Pie();
        pie = pMPie;
        isAfternoon = true;
      } else {
        aMPie = Pie();
        pie = aMPie;
      }
      painter = PiePainter(pie: pie);

      loadPie();
    });
    startTimer();
  }

  void updateSize() {
    _getWidgetSize();
    // Find the smallest of the two dimensions
    double smallestDimension = min(widgetHeight!, widgetWidth!);
    // Use the dimensions here
    if (smallestDimension * pieToWindowRatio != pie.width) {
      Diameter.instance.setPieDiameter(smallestDimension * pieToWindowRatio);
      pie.width = Diameter.instance.pieDiameter;
      // update all slice dragButtons as this wasn't automatic
      for (Slice slice in pie.slices) {
        slice.dragButtonBefore =
            DragButton(time: slice.getStartTime(), shown: true);
        slice.dragButtonAfter =
            DragButton(time: slice.getEndTime(), shown: true);
      }
    }
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

  /// Builds the display for the Home Page, which is all stored in
  /// the GestureDetector widget
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
        key: _gestureKey,
        onTapDown: (details) {
          // Update the widget size
          _getWidgetSize();
          // print("height: ${widgetHeight!}, width: ${widgetWidth!}");

          Point tappedPoint = _getTappedPoint(details);
          // print(tappedPoint.toString());

          double tappedDistToCenter = _getTappedDistToCenter(details);
          // print("dist: $tappedDistToCenter");

          double tapTime = DragButton.getTimeFromPoint(tappedPoint);
          // print(tapTime.toString());

          // if you tap outside the pie chart, it deselects the selected slice
          // UNLESS you tapped close enough to a dragbutton
          if (_tappedOutsideRadius(tappedDistToCenter)) {
            if (_tappedInsideLargerRadius(tappedDistToCenter)) {
              // make sure you aren't trying to interact with a dragButton
              if (!_tappedDragButton(tapTime)) {
                pie.setSelectedSliceIndex(-1);
              }
            }
            // else you've pressed in the dragbutton ring. Don't deselect or change your slice
          } else {
            int i = 0;
            bool found = false;
            // search through the slices for one whose endpoints are before and after this time
            for (Slice slice in pie.slices) {
              if (slice.getStartTime() < tapTime) {
                if (slice.getEndTime() > tapTime) {
                  pie.setSelectedSliceIndex(i);
                  found = true;
                  vibrateWithAudio(1);
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

  /// Outside the radius includes the ring that DragButtons appear on
  bool _tappedOutsideRadius(tappedDistToCenter) {
    return (tappedDistToCenter >
        pie.radius() - (buttonRadius + (padding * 100)));
  }

  /// This includes the ring that DragButtons appear on
  bool _tappedInsideLargerRadius(tappedDistToCenter) {
    return (tappedDistToCenter >
        pie.radius() + (buttonRadius + (padding * 100)));
  }

  /// Checks for a dragbutton at the given location.
  /// Includes some padding, shape is non-circular
  bool _tappedDragButton(tapTime) {
    Slice selectedSlice = pie.getSelectedSlice();
    return ((selectedSlice.getStartTime() - padding < tapTime &&
            selectedSlice.getStartTime() + padding > tapTime) ||
        (selectedSlice.getEndTime() - padding < tapTime &&
            selectedSlice.getEndTime() + padding > tapTime));
  }

  /// Takes the literal tapped position and subtracts the area
  /// around the pie chart to get a position that's usable for
  /// pie-related calculations
  Point _getTappedPoint(TapDownDetails details) {
    return Point.parameterized(
        x: details.localPosition.dx - (widgetWidth! / 2) + (pie.width / 2),
        y: details.localPosition.dy -
            (widgetHeight! / 2 + unknownOffset) +
            (pie.width / 2));
  }

  /// Calculate the distance tapped from the center.
  /// Assumes the pie is centered.
  /// sqrt((x1-x2)^2 + (y1-y2)^2)
  double _getTappedDistToCenter(TapDownDetails details) {
    return sqrt(pow(details.localPosition.dx - (widgetWidth! / 2), 2) +
        pow(details.localPosition.dy - ((widgetHeight! / 2 + unknownOffset)),
            2));
  }

  /// Produces vibrations and a click sound when called. Does not work on Windows.
  void vibrateWithAudio(int level) {
    switch (level) {
      case (1):
        Vibration.vibrate(duration: 50);
        break;
      case (2):
        Vibration.vibrate(duration: 100);
        break;
      case (3):
        Vibration.vibrate(duration: 150);
        break;
      default:
        Vibration.vibrate(duration: 50);
    }
    // playPopSound();
    print("sound and haptics happened here! Level: $level");
  }

  Future<void> playPopSound() async {
    await player.play(AssetSource('data/tap.wav'));
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
    vibrateWithAudio(2);
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
    vibrateWithAudio(1);
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
                    vibrateWithAudio(3);
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
    vibrateWithAudio(3);
    pie.removeSlice();
    savePie();
  }

  /// List the Tasks for the current Pie.
  void _listSlices() {
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
    // removes everything except digits
    timeString = timeString.replaceAll(RegExp(r'[^0-9]'), '');
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
    final hours = (digs ~/ 100) % 12;
    final minutes = digs % 100 / 60;
    return hours + minutes;
  }

  void updateScreen() {
    // update screen by literally remaking the painter
    // probably part of why app is so glitchy
    setState(() {
      updateSize();
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
  pieAndDragButtons = [
    CustomPaint(
        size: Size(pie.width + buttonDiameter, pie.width + buttonDiameter),
        painter: painter)
  ];

  if (isEditing()) {
    // reinstantiate the current dragbuttons
    Slice currentSlice = pie.getSelectedSlice();
    pieAndDragButtons.add(currentSlice.dragButtonBefore);
    pieAndDragButtons.add(currentSlice.dragButtonAfter);
  }
  return pieAndDragButtons;
}

bool isEditing() {
  /// checks if there is a current selected slice
  return pie.selectedSliceIndex > -1;
}
