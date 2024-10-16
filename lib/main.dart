import 'package:flutter/material.dart';
import 'package:pie_agenda/pie.dart';
import 'package:pie_agenda/task.dart';

int zoomLevel = 1;//zoom range from 1 to 3
// Initialize PM Pie, AM Pie is for later
Pie pie = Pie();
void main() {
  runApp(const MyApp());
}
void addTask(Task task) {

}
void removeTask(Task task) {

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
  const MyHomePage({super.key, required this.title});
  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  final bool _editModeOn = false;

  void _toggleEditMode() {
    setState(() {
      _editModeOn != _editModeOn;
    });
  }

  @override
  Widget build(BuildContext context) {
    // This method is rerun every time setState is called, for instance as done
    // by the _toggleEditMode method above.
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        // Here we take the value from the MyHomePage object that was created by
        // the App.build method, and use it to set our appbar title.
        title: Text(widget.title),
      ),
      body: const Center(
        // Center is a layout widget. It takes a single child and positions it
        // in the middle of the parent.
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
              Text('You have turned on edit mode'),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _toggleEditMode,
        tooltip: 'Toggle',
        child: const Icon(Icons.add),
      ), // This trailing comma makes auto-formatting nicer for build methods.
    );
  }
}
