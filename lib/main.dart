// ignore_for_file: avoid_print, prefer_final_fields

import 'package:flutter/material.dart';
import 'package:pie_agenda/dragbutton.dart';
import 'package:pie_agenda/pie.dart';
import 'package:pie_agenda/piepainter.dart';
import 'package:pie_agenda/task.dart';

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
        return AlertDialog(
          title: const Text('Add New Slice'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: startTimeController,
                decoration: const InputDecoration(
                  labelText: 'Start Time (int)',
                ),
                keyboardType: TextInputType.number,
              ),
              TextField(
                controller: endTimeController,
                decoration: const InputDecoration(
                  labelText: 'Duration (int)',
                ),
                keyboardType: TextInputType.number,
              ),
              TextField(
                controller: taskController,
                decoration: const InputDecoration(
                  labelText: 'Task Description',
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                final startTime = int.tryParse(startTimeController.text) ?? 0;
                final endTime = int.tryParse(endTimeController.text) ?? 0;
                final taskText = taskController.text;
                Task task = Task.parameterized(
                    taskText, startTime.toDouble(), endTime.toDouble());

                if (startTime >= 0 && endTime >= 0 && taskText.isNotEmpty) {
                  setState(() {
                    pie.addSpecificSlice(startTime, endTime, task);
                    painter = PiePainter(pie: pie);
                  });
                  Navigator.of(context).pop();
                } else {
                  print("Invalid input for start or end time, or empty task");
                }
              },
              child: const Text('Add Slice'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
      ),
      body: Center(
        child: Stack(alignment: Alignment.center, children: [
          CustomPaint(size: Size(pie.width, pie.width), painter: painter),
          DragButton(time: 0, shown: true),
        ]),
      ),
      floatingActionButton: Row(
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
      ),
    );
  }
}
