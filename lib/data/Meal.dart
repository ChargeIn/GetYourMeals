import 'package:flutter/cupertino.dart';

class Meal {
  String name; // name of the meal
  Duration time; // time till this meal needs to be eaten
  String comment; // comment about this meal
  String image; // path to the picture of this meal
  String sound; // path to a sound file (mp3)
  bool vibration; // should the alarm vibrate

  static const sounds  = [
    "trumpet1",
    "no-other",
  ];

  static const String defaultSound =  "trumpet1";

  static const String defaultImage =  "assets/icons/cupcake.png";

  Meal({@required this.name, @required this.time, @required this.comment,
    @required this.image, @required this.sound, @required this.vibration});


  String toCSVString() {
    return "$name,$time,$comment,$image,$sound,$vibration;\n";
  }

}