class PieTime {
  double time = 0;

  PieTime(this.time);

  List getTimeAsLists() {
    int hour = time.toInt();
    int minute = (time % 1 * 60).toInt();
    int second = minute % 1 * 60;
    return [hour, minute, second];
  }

  int hr() {
    return time.toInt();
  }

  int min() {
    // additional thousandth fixes a rounding error
    return ((time + 0.001) % 1 * 60).toInt();
  }

  int sec() {
    return (((time * 60) % 1) * 60).toInt();
  }

  /// Does not include seconds
  @override
  String toString() {
    return "${hr()}:${minString()}";
  }

  String minString() {
    int minute = min();
    if (minute < 10) {
      return "0$minute";
    }
    return minute.toString();
  }

  String secString() {
    int second = sec();
    if (second < 10) {
      return "0$second";
    }
    return second.toString();
  }
}
