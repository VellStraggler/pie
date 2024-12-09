import 'dart:convert';
import 'dart:io';
import 'slice.dart';
import 'task.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:pie_agenda/pie/pie.dart';

class PieManager {
  final filePath = 'assets/data/pie.json';
  List<Task> day = []; //the variable that stores the list of tasks.

  Future<void> saveDay(List<Slice> slices, String filePath) async {
    try {
      // Convert the list of Task objects to a list of JSON maps.
      List<Map<String, dynamic>> jsonTasks =
          slices.map((slice) => slice.toJson()).toList();

      // Encode the list to a JSON string.
      String jsonString = jsonEncode(jsonTasks);

      // Write the JSON string to the specified file.
      final file = File(filePath);
      await file.writeAsString(jsonString);
      print('Tasks saved successfully!');
    } catch (e) {
      print('Failed to save tasks: $e');
    }
  }

  /// Loads a json file and returns a list of tasks.
  Future<Pie> loadPie() async {
    try {
      // Load the JSON file as a string
      String jsonString = await rootBundle.loadString(filePath);

      // Ensure the JSON string is not empty
      assert(
        jsonString.isNotEmpty,
        'Loaded JSON string is empty. Please check assets/data/pie.json.',
      );

      // Decode the JSON string into a Map
      Map<String, dynamic> jsonMap = jsonDecode(jsonString);

      // Ensure 'slices' key exists and is a List
      assert(
        jsonMap.containsKey('slices'),
        'JSON does not contain the required "slices" key.',
      );
      assert(
        jsonMap['slices'] is List,
        '"slices" should be a List.',
      );

      // Convert JSON to Pie object
      Pie pie = Pie.fromJson(jsonMap);

      // Ensure Pie contains slices

      // Validate each Slice
      for (var slice in pie.slices) {
        assert(
          slice.getTaskName().isNotEmpty,
          'Each Slice must have a non-empty task name.',
        );
        assert(
          slice.getStartTime() >= 0 && slice.getStartTime() < 24,
          'Slice startTime should be between 0 and 24.',
        );
        assert(
          slice.getEndTime() > slice.getStartTime() && slice.getEndTime() <= 24,
          'Slice endTime should be greater than startTime and at most 24.',
        );
      }
      print("Pie data loaded successfully from $filePath.");
      return pie;
    } catch (e, stackTrace) {
      // Enhanced error logging with stack trace
      print("No valid pie found: $e");
      print(stackTrace);

      // Return a default Pie
      return Pie();
    }
  }
}
