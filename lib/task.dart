// Dennis Skoy
class Task {
  // This is the data of a task/slice. This must be able to be stored in .json
  String name; //
  int duration;
  int startTime;
  int endTime;

  // Constructor
  Task(this.name, this.duration, this.startTime, this.endTime);

  void changeDuration(int duration) {
    // Changes the tasks's duration.
    this.duration = duration;
  }

  void changeStartTime(int startTime) {
    //Changes the task's startTime.
    this.startTime = startTime;
  }

  void changeEndTime(int endTime) {
    // Changes the task's endTime.
    this.endTime = endTime;
  }
}
