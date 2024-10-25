// Dennis Skoy
class Task {
  // This is the data of a task/slice. This must be able to be stored in .json
  String taskName; //
  double duration;
  double startTime;
  double endTime;

  // Constructor
  // Time Syntax is as such: 1.25 = 1:30, 0.5 = 12:30
  Task(this.taskName, this.startTime, this.endTime)
    : duration = endTime - startTime;

  // Changes taskName.
  void changeTaskName(String taskName) {
    this.taskName = taskName;
  }

  // Changes the tasks's duration.
  void changeDuration(double duration) {
    this.duration = duration;
  }

  // Changes the task's startTime.
  void changeStartTime(double startTime) {
    this.startTime = startTime;
  }

  // Changes the task's endTime.
  void changeEndTime(double endTime) {
    this.endTime = endTime;
  }

  // Convert Task object to JSON.
  // String jsonString = jsonEncode(task.toJson());
  Map<String, dynamic> toJson() {
    return {
      'taskName': taskName,
      'duration': duration,
      'startTime': startTime,
      'endTime': endTime,
    };
  }

  // Convert JSON to Task object.
  // Task taskFromJson = Task.fromJson(jsonDecode(jsonString));
  factory Task.fromJson(Map<String, dynamic> json) {
    return Task(
      json['taskName'] as String,
      json['startTime'] as double,
      json['endTime'] as double,
    );
  }
}
