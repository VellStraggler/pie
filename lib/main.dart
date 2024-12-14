// ignore_for_file: avoid_print, prefer_final_fields

import 'package:flutter/material.dart';
import 'package:pie_agenda/screens/my_home_page.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  /// This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Pie Agenda',
      // press "r" in console to reload while running
      // completely ignore theme (maybe change this)
      theme: ThemeData(),
      home: const MyHomePage(title: 'Pie Agenda'),
      debugShowCheckedModeBanner: false,
    );
  }
}
