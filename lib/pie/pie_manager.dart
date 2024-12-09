import 'dart:convert';
import 'dart:io';
import 'package:flutter/services.dart' show rootBundle;
import 'package:pie_agenda/pie/pie.dart';

class PieManager {
  final filePath = 'assets/data/pie.json';

  /// Save the Pie to JSON file.
  Future<void> savePie(String time, Pie pie) async {
    try {
      final file = File(filePath);
      String jsonString = await file.readAsString();
      Map<String, dynamic> existingData = jsonDecode(jsonString);

      // Convert the list of Task objects to a list of JSON maps.
      Map<String, dynamic> newData = pie.toJson(time);

      existingData[time] = newData[time];

      // Encode the list to a JSON string.
      String updatedJsonString = jsonEncode(existingData);

      // Write the JSON string to the specified file.
      await file.writeAsString(updatedJsonString);
      print('Tasks saved successfully!');
    } catch (e) {
      print('Failed to save tasks: $e');
    }
  }

  /// Loads a JSON file and returns a list of tasks.
  Future<Pie> loadPie(String time) async {
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
        jsonMap.containsKey(time),
        'JSON does not contain the required "$time" key.',
      );
      assert(
        jsonMap[time] is List,
        '"$time" should be a List.',
      );
      //

      // Convert JSON to Pie object
      Pie pie = Pie.fromJson(jsonMap, time);

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
        //
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
