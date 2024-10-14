import 'package:flutter/material.dart';
import 'package:pie_agenda/pie.dart';
import 'package:pie_agenda/polygon.dart';
import 'package:pie_agenda/slice.dart';
import 'package:pie_agenda/task.dart';
import 'point.dart';

void main() {
  // Initialize PM Pie, AM Pie is for later
  List<Slice> slices = [];
  Point center = Point(800,800);
  Polygon circle = Polygon(age:300,name:"circle");
  Pie pie = Pie(slices: slices, center: center, circle: circle);

  int zoom = 1; //zoom range from 1 to 3


  runApp(const MyApp());
}
void addTask(Task task) {

}
void removeTask(Task task) {

}
void zoom(bool up) {
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
        // This is the theme of your application.
        // press "r" in console to reload
        //
        // This works for code too, not just values: Most code changes can be
        // tested with just a hot reload.
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: const MyHomePage(title: 'Pie Agenda Home Page', pie: pie),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title, required this.pie});
  final String title;
  final Pie pie;
  final int zoom = 1;

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
