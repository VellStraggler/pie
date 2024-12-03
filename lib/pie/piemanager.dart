import 'dart:convert';
import 'dart:io';
import 'task.dart';

class PieManager {
  List<Task> day = []; //the variable that stores the list of tasks.

  Future<void> saveDay(List<Task> tasks, String filePath) async {
    try {
      // Convert the list of Task objects to a list of JSON maps.
      List<Map<String, dynamic>> jsonTasks =
          tasks.map((task) => task.toJson()).toList();

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

  //saves all the tasks into a single json file labeled as a day
  Future<List<Task>> loadDay(String filePath) async {
    try {
      // Read the JSON string from the file.
      final file = File(filePath);
      String jsonString = await file.readAsString();

      // Decode the JSON string to a list of dynamic maps.
      List<dynamic> jsonTasks = jsonDecode(jsonString);

      // Convert the list of maps to a list of Task objects.
      List<Task> tasks = jsonTasks.map((json) => Task.fromJson(json)).toList();
      print('Tasks loaded successfully!');
      return tasks;
    } catch (e) {
      print('Failed to load tasks: $e');
      return []; // Return an empty list on failure.
    }
  }

  //loads a json file and returns a list of tasks
  void addTask() {}
  void removeTask() {}
  void interpretInput() {}
}
