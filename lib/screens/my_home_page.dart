import 'dart:async';
import 'dart:io';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:pie_agenda/methods.dart';
import 'package:pie_agenda/pie/pie_time.dart';
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
bool tappedFloatingButton = false;
int dragButtonIndex = -1;
double? widgetHeight;
double? widgetWidth;
List<String> msgs = ["", ""];

// this is a global var so we can update at any point from anywhere
List<Widget> pieAndDragButtons = [];

// manager holds file storage path
final PieManager manager = PieManager();

const double padding = .05;
int unknownOffset = 53; //borderWidth * 2;
// With height 852 and width 411, offset is 53
// With height 682 and width 1265.6, offset is 26
// Width changes nothing, but device type does???
const Color almostBlack = Color.fromRGBO(19, 26, 155, 1); // dark blue
const Color themeColor2 = Color.fromRGBO(54, 124, 255, 1); // cerulean
const Color otherColor = Color.fromRGBO(104, 174, 255, 1); // blue
const Color offWhite = Color.fromRGBO(185, 215, 255, 1);
const Color buttonColor = offWhite;
const Color themeColor1 = Color.fromRGBO(249, 248, 255, 1); // white

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
  int lastTapTimeMS = DateTime.now().millisecondsSinceEpoch;
  final GlobalKey _gestureKey = GlobalKey();

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
      pie.updateDragButtons();
      painter.updateWithNewDimensions();
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
        onScaleStart: (details) {
          if (tappedFloatingButton) {
            return;
          }
          // Update the widget size
          _getWidgetSize();

          // check for this being a DOUBLE TAP
          int tapTimeMS = DateTime.now().millisecondsSinceEpoch;
          if (tapTimeMS < lastTapTimeMS + 300) {
            if (isEditing()) {
              pie.isHovering = !pie.isHovering;
            }
          } else {
            lastTapTimeMS = tapTimeMS;
          }

          Point tappedPoint = _getTappedPoint(details);

          double tappedDistToCenter = _getTappedDistToCenter(details);

          double tapTime = Methods.getTimeFromPoint(tappedPoint);

          // if you tap outside the pie chart, it deselects the selected slice
          // UNLESS you tapped close enough to a dragbutton

          var holdingDragButton = false;
          dragButtonIndex = getDragbuttonIndex(tappedPoint);
          if (dragButtonIndex != -1 && !pie.isHovering) {
            holdingDragButton = true;
          }
          if (_tappedOutsideRadius(tappedDistToCenter)) {
            if (_tappedInsideLargerRadius(tappedDistToCenter)) {
              // make sure you aren't trying to interact with a dragButton
              if (!holdingDragButton) {
                pie.resetSelectedSlice();
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
              pie.resetSelectedSlice();
              // if one was not selected, deselect what we do have
            }
          }
          updateScreen();
        },
        onScaleUpdate: (details) {
          if (pie.isHovering) {
            _updateSelectedSlice(details);
          } else {
            _updateDragButtons(details);
          }
        },
        onScaleEnd: (details) {
          _finalizeDragButtons(details);
          updateScreen();
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
                        child: Padding(
                            padding: EdgeInsets.only(bottom: 4.0),
                            child: Clock())))),
            body: Stack(children: [
              Padding(
                  padding: const EdgeInsets.only(
                      top: 20.0, left: 20.0, right: 20.0, bottom: 20.0),
                  child: Align(
                      alignment: Alignment.topCenter,
                      child: Column(children: [
                        Text(
                          msgs[0],
                          style: const TextStyle(
                              fontSize: 24, color: Colors.black),
                          textAlign: TextAlign.center,
                        ),
                        Text(
                          msgs[1],
                          style: const TextStyle(
                              fontSize: 36, color: Colors.black),
                          textAlign: TextAlign.center,
                        )
                      ]))),
              Center(
                  child: CustomPaint(
                      size: Size(pie.width + buttonDiameter,
                          pie.width + buttonDiameter),
                      painter: painter)),
            ]),
            floatingActionButton: _buildFloatingActionButtons()));
  }

  /// Outside the radius includes the ring that DragButtons appear on
  bool _tappedOutsideRadius(tappedDistToCenter) {
    return (tappedDistToCenter >
        pie.radius() - (buttonRadius + (padding * 100)));
  }

  List<String> _getSliceInfoText() {
    if (!isAfternoon && pie.currentTime.time >= 11.98) {
      return ["The morning as concluded...", ""];
    }
    int sliceNowIndex = -1;
    StringBuffer msgBuff = StringBuffer();
    for (int i = 0; i < pie.slices.length; i++) {
      Slice slice = pie.slices[i];
      if (slice.getEndTime() > pie.currentTime.time) {
        if (slice.getStartTime() < pie.currentTime.time) {
          sliceNowIndex = i;
        }
      }
    }
    if (sliceNowIndex == -1 && pie.getSelectedSliceIndex() == -1) {
      msgBuff.write("Nothing to do right now...\n ");
    } else if (pie.getSelectedSliceIndex() == -1 ||
        pie.getSelectedSliceIndex() == sliceNowIndex) {
      Slice sliceNow = pie.slices[sliceNowIndex];
      PieTime timeLeft = PieTime(sliceNow.getEndTime() - pie.currentTime.time);
      msgBuff.write("Time left in ${sliceNow.task.taskName}:\n");
      if (timeLeft.hr() != 0) {
        msgBuff.write("${timeLeft.hr()}:");
      }
      msgBuff.write("${timeLeft.minString()}:");
      msgBuff.write(timeLeft.secString());
    } else {
      Slice slice = pie.getSelectedSlice();
      PieTime startTime = PieTime(slice.getStartTime());
      PieTime endTime = PieTime(slice.getEndTime());
      msgBuff.write("Selected Task: ${slice.task.taskName}");
      msgBuff.write("\n${startTime.toString()} to ${endTime.toString()}");
    }
    return msgBuff.toString().split("\n");
  }

  /// Similar to _updateDragButtons, only this changes both
  void _updateSelectedSlice(details) {
    Point newPoint = _getTappedPoint(details);
    double timeFromPoint = Methods.getTimeFromPoint(newPoint);
    double halfDuration = (pie.drag2.time - pie.drag1.time) / 2;
    double newStartTime = timeFromPoint - halfDuration;

    newPoint =
        Methods.getNearestSnapPoint(Methods.getPointFromTime(newStartTime));
    pie.changeSelectedSliceStart(newPoint, withEnd: true);
  }

  void _updateDragButtons(details) {
    Point newPoint = _getTappedPoint(details);
    newPoint = Methods.getNearestSnapPoint(
        Point.parameterized(x: newPoint.x, y: newPoint.y));
    if (dragButtonIndex == 1) {
      pie.changeSelectedSliceStart(newPoint);
    } else if (dragButtonIndex == 2) {
      pie.changeSelectedSliceEnd(newPoint);
    }
  }

  void _finalizeDragButtons(details) {
    if (isEditing()) {
      pie.changeSelectedSliceStart(
          Methods.getRoundedSnapPoint(pie.drag1.point));
      pie.changeSelectedSliceEnd(Methods.getRoundedSnapPoint(pie.drag2.point));
      pie.getSelectedSlice().task.roundTimes();
    }
    dragButtonIndex = -1;
    // savePie only when user lets goww
    updateScreen();
    savePie();
  }

  int getDragbuttonIndex(Point tappedPoint) {
    if (pie.getSelectedSliceIndex() == -1) {
      return -1;
    } else {
      // if the distance from the center of the given dragbutton to the
      // tapped point is less than the radius of the dragbutton, return
      // this dragButton
      double distToDrag1 = distance(tappedPoint, pie.drag1.point);
      double distToDrag2 = distance(tappedPoint, pie.drag2.point);
      if (distToDrag1 <= buttonDiameter) {
        if (distToDrag2 < distToDrag1) {
          return 2;
        }
        return 1;
      } else if (distToDrag2 <= buttonDiameter) {
        return 2;
      }
      return -1;
    }
  }

  double distance(Point a, Point b) {
    return sqrt(pow((a.x - b.x), 2) + pow((a.y - b.y), 2));
  }

  /// This includes the ring that DragButtons appear on
  bool _tappedInsideLargerRadius(tappedDistToCenter) {
    return (tappedDistToCenter >
        pie.radius() + (buttonRadius + (padding * 100)));
  }

  /// Takes the literal tapped position and subtracts the area
  /// around the pie chart to get a position that's usable for
  /// pie-related calculations
  Point _getTappedPoint(details) {
    return Point.parameterized(
        x: details.localFocalPoint.dx - (widgetWidth! / 2) + (pie.width / 2),
        y: details.localFocalPoint.dy -
            (widgetHeight! / 2 + unknownOffset) +
            (pie.width / 2));
  }

  /// Calculate the distance tapped from the center.
  /// Assumes the pie is centered.
  /// sqrt((x1-x2)^2 + (y1-y2)^2)
  double _getTappedDistToCenter(details) {
    return sqrt(pow(details.localFocalPoint.dx - (widgetWidth! / 2), 2) +
        pow(details.localFocalPoint.dy - ((widgetHeight! / 2 + unknownOffset)),
            2));
  }

  /// Produces vibrations and a click sound when called. Does not work on Windows.
  void vibrateWithAudio(int level) {
    if (Platform.isWindows) {
      return;
    }
    switch (level) {
      case (1):
        Vibration.vibrate(duration: 50);
        break;
      case (2):
        Vibration.vibrate(duration: 100);
        break;
      case (3):
        // Reserved for adding and removing slices
        playPopSound();
        Vibration.vibrate(duration: 150);
        break;
      default:
        Vibration.vibrate(duration: 50);
    }
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
            onPressed: _showAddSliceDialogue,
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
        autofocus: true,
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

  void _editSelectedSlice() {
    tappedFloatingButton = true;
    vibrateWithAudio(1);
    Slice slice = pie.getSelectedSlice();
    showDialog(
      context: context,
      builder: (BuildContext context) {
        final taskController = TextEditingController(text: slice.task.taskName);
        taskController.selection = TextSelection(
            baseOffset: 0, extentOffset: slice.task.taskName.length);

        return AlertDialog(
          backgroundColor: themeColor1,
          title: const Text('Edit Task Description'),
          content: Form(
            child: _buildTextField(taskController, 'Task Description'),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () {
                var taskText = taskController.text.trim();

                // Create a default slice if the user has entered nothing in
                if (taskText.isEmpty) {
                  taskText = "Default Task";
                }
                if (taskText.isNotEmpty) {
                  setState(() {
                    slice.task.taskName = taskText;
                    vibrateWithAudio(1);
                    pie.resetSelectedSlice();
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
              child: const Text('Rename Slice'),
            ),
          ],
        );
      },
    );
    tappedFloatingButton = false;
  }

  /// Creates form to add a new slice to the pie.
  void _showAddSliceDialogue() {
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
                _buildTextField(
                    startTimeController, 'Start Time', 'E.g. 1:00 or 1 or 100'),
                _buildTextField(
                    durationController, 'Duration', 'E.g. 1:00 or 1 or 100'),
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
                    pie.resetSelectedSlice();
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
    tappedFloatingButton = true;
    vibrateWithAudio(3);
    pie.removeSlice();
    savePie();
    tappedFloatingButton = false;
  }

  /// List the Tasks for the current Pie.
  void _listSlices() {
    tappedFloatingButton = true;
    print(aMPie.toJson('AM'));
    print(pMPie.toJson('PM'));
    String ampm = "Morning";
    if (isAfternoon) {
      ampm = "Evening";
    }
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: themeColor1,
          title: Text('$ampm Tasks Today:'),
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
    tappedFloatingButton = false;
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
    });
  }

  void startTimer() {
    // 90 fps
    _timer = Timer.periodic(const Duration(milliseconds: 12), (timer) {
      updateScreen();
      msgs = _getSliceInfoText();
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
  if (minutes < 10) {
    timeOfDay = "${timeOfDay}0";
  }
  return timeOfDay;
}

bool isEditing() {
  /// checks if there is a current selected slice
  return pie.getSelectedSliceIndex() != -1;
}
