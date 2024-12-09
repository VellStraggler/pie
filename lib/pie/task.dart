/// An object that stores a task's main attributes:
/// * taskName - The task's name.
/// * duration - How long a task lasts.
/// * startTime - When a task starts.
/// * endTime - When a task ends.
class Task {
  // This is the data of a task/slice. This must be able to be stored in .json
  String taskName;
  double duration;
  double startTime;
  double endTime;

  /// Default Constructor for a Task object.
  Task()
      : taskName = "NewTask",
        startTime = 0,
        endTime = 1,
        duration = 1;

  /// Parameterized Task Constructor.
  /// Time Syntax is as such:
  /// * 1.25 = 1:30
  /// * 0.5 = 12:30
  Task.parameterized(this.taskName, this.startTime, this.duration)
      : endTime = duration + startTime;

// Getters and Setters
  /// Returns the task's name.
  String getTaskName() {
    return taskName;
  }

  /// Returns the task's duration
  double getDuration() {
    return duration;
  }

  /// Returns the task's startTime
  double getStartTime() {
    return startTime;
  }

  /// Returns the task's endTime.
  double getEndTime() {
    return startTime + duration;
  }

  /// Set the task's taskName.
  void setTaskName(String taskName) {
    this.taskName = taskName;
  }

  /// Set the tasks's duration.
  void setDuration(double duration) {
    this.duration = duration;
  }

  /// Set the task's startTime.
  void setStartTime(double startTime) {
    assert(startTime < endTime, "startTime must be before endTime.");
    this.startTime = startTime;
  }

  /// Set the task's endTime.
  void setEndTime(double endTime) {
    assert(endTime > startTime, "endTime must be after startTime.");
    this.endTime = endTime;
    duration = endTime - startTime;
  }

// Save Data Conversion
  /// Convert Task object to JSON.
  /// * String jsonString = jsonEncode(task.toJson());
  Map<String, dynamic> toJson() {
    return {
      'taskName': taskName,
      'startTime': startTime,
      'duration': duration,
    };
  }

  /// Convert JSON to a Task object.
  /// * Task taskFromJson = Task.fromJson(jsonDecode(jsonString));
  factory Task.fromJson(Map<String, dynamic> json) {
    return Task.parameterized(json['taskName'] as String,
        json['startTime'] as double, json['duration'] as double);
  }
  @override
  String toString() {
    return "$taskName, $duration, $startTime, $endTime";
  }
}
