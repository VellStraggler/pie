/// An object that stores a task's main attributes:
/// * taskName - The task's name.
/// * duration - How long a task lasts.
/// * startTime - When a task starts.
/// * endTime - When a task ends.
class Task {
  // This is the data of a task/slice. This must be able to be stored in .json
  String taskName;
  double _duration;
  double _startTime;
  double endTime;

  /// Default Constructor for a Task object.
  Task()
      : taskName = "NewTask",
        _startTime = 0,
        endTime = 1,
        _duration = 1;

  /// Parameterized Task Constructor.
  /// Time Syntax is as such:
  /// * 1.25 = 1:30
  /// * 0.5 = 12:30
  Task.parameterized(this.taskName, startTime, duration)
      : _startTime = startTime,
        endTime = duration + startTime,
        _duration = duration {
    // normalization required so decimal value stays in hundredths place
    setStartTime(startTime);
    setDuration(duration);
    endTime = _duration + _startTime;
  }

// Getters and Setters
  /// Returns the task's name.
  String getTaskName() {
    return taskName;
  }

  /// Returns the task's duration
  double getDuration() {
    return _duration;
  }

  /// Returns the task's startTime
  double getStartTime() {
    return _startTime;
  }

  /// Returns the task's endTime.
  double getEndTime() {
    return _startTime + _duration;
  }

  /// Set the task's taskName.
  void setTaskName(String taskName) {
    this.taskName = taskName;
  }

  /// Set the tasks's duration.
  void setDuration(double duration) {
    _duration = (duration * 100).round() / 100.00;
    // _duration = double.parse(duration.toStringAsFixed(2));
  }

  /// Set the task's startTime.
  void setStartTime(double startTime) {
    assert(startTime < endTime, "startTime must be before endTime.");
    _startTime = (startTime * 100).round() / 100.00;
    // this.startTime = double.parse(startTime.toStringAsFixed(2));
  }

  void roundTimes() {
    _startTime = (_startTime * 4).round() / 4.00;
    _duration = (_duration * 4).round() / 4.00;
    endTime = _startTime + _duration;
  }

  /// Set the task's endTime.
  void setEndTime(double endTime) {
    assert(endTime > _startTime, "endTime must be after startTime.");
    this.endTime = endTime;
    setDuration(endTime - _startTime);
  }

// Save Data Conversion
  /// Convert Task object to JSON.
  /// * String jsonString = jsonEncode(task.toJson());
  Map<String, dynamic> toJson() {
    return {
      'taskName': taskName,
      'startTime': _startTime,
      'duration': _duration,
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
    return "$taskName, $_duration, $_startTime, $endTime";
  }
}
