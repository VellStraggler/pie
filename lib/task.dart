// Dennis Skoy
class Task {
  // This is the data of a task/slice. This must be able to be stored in .json
  String taskName; //
  int duration;
  int startTime;
  int endTime;

  // Constructor
  Task(this.taskName, this.duration, this.startTime, this.endTime);

  // Changes the tasks's duration.
  void changeDuration(int duration) {
    this.duration = duration;
  }

  //Changes the task's startTime.
  void changeStartTime(int startTime) {
    this.startTime = startTime;
  }

  // Changes the task's endTime.
  void changeEndTime(int endTime) {
    this.endTime = endTime;
  }

  // Convert Task object to JSON.
  Map<String, dynamic> toJson() {
    return {
      'taskName': taskName,
      'duration': duration,
      'startTime': startTime,
      'endTime': endTime,
    };
  }

  // Convert JSON to Task object.
  factory Task.fromJson(Map<String, dynamic> json) {
    return Task(
      json['taskName'] as String,
      json['duration'] as int,
      json['startTime'] as int,
      json['endTime'] as int,
    );
  }
}
