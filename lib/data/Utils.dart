class Utils {
  static Duration parseDuration(String s) {
    int sec = int.parse(s);
    int hours = (sec/360).floor();
    int minutes = (sec/60).floor();
    return Duration(hours: hours, minutes: minutes);
  }
}