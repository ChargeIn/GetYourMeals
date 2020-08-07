import 'dart:io';
import 'package:get_your_meals/data/Meal.dart';
import 'package:path_provider/path_provider.dart';

import 'Utils.dart';

class FileManager{

  static const String config = "config.txt";
  static const String mealsPath = "meals.csv";
  static const String pictures = "/pictures";

  FileManager();

  static Future<List<Meal>> loadMeals() async {
    final file = await getFile(mealsPath);

    if(!await file.exists()) return [];

    final meals = await file.readAsString();

    List<Meal> list = [];

    meals.split(";\n").forEach( (element) {
      if(element.isEmpty) return;
      List strList = element.split(",");
      list.add(Meal(
        name: strList[0],
        time: Utils.parseDuration(strList[1]),
        comment: strList[2],
        image: strList[3],
        sound: strList[4],
        vibration: strList[5] == "true"
      ));
    });
    return list;
  }

  static Future<File> addMeal(Meal meal) async {
    final file = await getFile(mealsPath);

    return file.writeAsString(meal.toCSVString(),mode: FileMode.append);
  }

  static void removeMeal(String meal) async {
    final file = await getFile(mealsPath);
    final str = await file.readAsString();
    final lines = str.split(";\n");
    file.writeAsStringSync(""); // clear old file

    lines.forEach((element) {
      if(element == "") return;
      if(element.substring(0, element.indexOf(",")) != meal)
        file.writeAsString(element); });
  }

  static Future<String> get _localPath async {
    final directory = await getApplicationDocumentsDirectory();
    return directory.path;
  }

  static Future<File> getFile(String file) async {
    final path = await _localPath;
    return File('$path/$file');
  }

  static Future<String> saveImage(imagePath) async {
    List<String> l = imagePath.split("/");
    final path = await _localPath;
    await new Directory(path + pictures).create();
    final newPath = path + pictures + "/" + l.last;
    File(imagePath).copy( newPath);
    return newPath;
  }

}