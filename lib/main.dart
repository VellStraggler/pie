// ignore_for_file: avoid_print, prefer_final_fields

import 'dart:io';

import 'package:flutter/material.dart';
import 'package:pie_agenda/screens/my_home_page.dart';
import 'package:window_manager/window_manager.dart';

void main() async {
  if (Platform.isWindows) {
    WidgetsFlutterBinding.ensureInitialized();
    await windowManager.ensureInitialized();
    WindowOptions windowOptions = const WindowOptions(
        size: Size(400, 800),
        minimumSize: Size(400, 650),
        title: "Pie Agenda",
        maximumSize: Size(600, 800));

    windowManager.waitUntilReadyToShow(windowOptions, () async {
      await windowManager.show();
      await windowManager.focus();
    });
  }

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
