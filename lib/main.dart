// ignore_for_file: avoid_print, prefer_final_fields

import 'package:flutter/material.dart';
import 'package:pie_agenda/pie.dart';
import 'package:pie_agenda/piepainter.dart';
import 'package:pie_agenda/task.dart';

int zoomLevel = 1; //zoom range from 1 to 3
// Initialize PM Pie, AM Pie is for later
Pie pie = Pie();
PiePainter painter = PiePainter(pie: pie);
void main() {
  runApp(const MyApp());
}

void loadDay(String fileName) {}
void saveDay(String fileName) {}
void addTask(Task task) {}
void removeTask(Task task) {}
void interpretInput() {}

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
      title: 'pie-agenda',
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
  bool _editModeOn = false; // State variable to track edit mode

  void _toggleEditMode() {
    setState(() {
      _editModeOn = !_editModeOn; // Toggle the edit mode
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // Put a widget in scaffold that can hold a "children" attribute
      // fill that attribute with a list of button widgets to be functional dragbuttons
      // Place the widgets on the screen with Position Widgets
      // Implement math function to position widget on the edge of the circle based on a time input (time syntax: 0.5 = 12:30)
      appBar: AppBar(
        title: Text(widget.title),
      ),
      body: Center(
        child: CustomPaint(
          size: Size(pie.width, pie.width),
          painter: painter
        )
      ),
      floatingActionButton: Row(
        mainAxisAlignment: MainAxisAlignment.end,
        children: <Widget>[
          Text(
            _editModeOn ? "Edit Mode is ON " : "Edit Mode is OFF ",
            style: const TextStyle(fontSize: 24),
          ),
          // For Eli
          // Just make another floatingactionbutton
          // also make the function it calls, whose syntax is very similar to _toggleEditMode
          // call the addSlice method from pie.
          FloatingActionButton(
            onPressed: _toggleEditMode, // Toggle edit mode on button press
            tooltip: 'Toggle Edit Mode',
            child: const Icon(Icons.edit),
          ),
        ],
      ),
    );
  }
}
