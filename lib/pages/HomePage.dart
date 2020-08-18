import 'dart:io';
import 'dart:isolate';
import 'dart:math';
import 'dart:ui';
import 'package:android_alarm_manager/android_alarm_manager.dart';
import 'package:assets_audio_player/assets_audio_player.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get_your_meals/data/FileManager.dart';
import 'package:get_your_meals/data/Meal.dart';
import 'package:get_your_meals/menus/Settings.dart';
import 'package:get_your_meals/styles/Style.dart';
import 'package:shared_preferences/shared_preferences.dart';


/// The [SharedPreferences] key to access the current meal count.
const String countKey = 'mealCounter';

/// The [SharedPreferences] key to access the old id.
const String id = 'id';

/// The name associated with the UI isolate's [SendPort].
const String isolateName = 'isolate';

/// A port used to communicate from a background isolate to the UI isolate.
final ReceivePort port = ReceivePort();

/// Global [SharedPreferences] object.
SharedPreferences prefs;


/// Represents the home page of getyourmeals
class HomePage extends StatefulWidget {

  HomePage({Key key, this.meals}) : super(key: key);
  final List<Meal> meals;

  @override
  _HomePageState createState() => _HomePageState(meals);
}

class _HomePageState extends State<HomePage> {
  static const platform = const MethodChannel("get_your_meals.com/fsalarm");


  List<Meal> meals;
  String startBtn = "Start";

  _HomePageState(meals) {
    this.meals = meals;
    init();
  }

  void init() async {
    // Register the UI isolate's SendPort to allow for communication from the
    // background isolate.
    IsolateNameServer.registerPortWithName(
      port.sendPort,
      isolateName,
    );
    prefs = await SharedPreferences.getInstance();
    await prefs.setInt(countKey, 0);
  }

  bool loaded = false;

  void addMeal(meal){
    setState(() {
      meals.add(meal);
    });
  }

  void update() async {
     meals = await FileManager.loadMeals();
    setState(() {});
  }

  void setAlarm() async {
    final prefs = await SharedPreferences.getInstance();
    int currentCount = prefs.getInt(countKey);
    await prefs.setInt(countKey, currentCount + 1);
    await AndroidAlarmManager.oneShot(
      Duration(seconds: meals[currentCount].time.inSeconds),
      // Ensure we have a unique alarm ID.
      Random().nextInt(pow(2, 31)),
      callback,
      alarmClock : true,
      allowWhileIdle : true,
      exact : true,
      wakeup : true,
      rescheduleOnReboot : true,
    );
  }

  void resetAlarmBttn(str) async {
    setState(() {
      startBtn = str;
    });
  }

  Future<void> _callBackAlarm() async {
    // Ensure we've loaded the updated count from the background isolate.
    final prefs = await SharedPreferences.getInstance();
    int currentCount = prefs.getInt(countKey);
    String value;
    List<String> map = List<String>();
    meals.forEach((meal) {
      map.add(meal.toCSVString());
    });
    try {
      value =
      await platform.invokeMethod("setAlarm", {"meal": map[currentCount-1]});
    } catch (e) {
      print(e);
    }

    if (currentCount < meals.length) {
      await setAlarm();
    } else {
      await prefs.setInt(countKey, 0);
      resetAlarmBttn("Start");
    }
  }

  // The background
  static SendPort uiSendPort;

  // The callback for our alarm
  static Future<void> callback() async {

    // This will be null if we're running in the background.
    uiSendPort ??= IsolateNameServer.lookupPortByName(isolateName);
    uiSendPort?.send(null);
  }

  @override
  void initState() {
    super.initState();

    AndroidAlarmManager.initialize();

    // Register for events from the background isolate. These messages will
    // always coincide with an alarm firing.
    port.listen((_) async => await _callBackAlarm());
  }

  @override
  Widget build(BuildContext context) {

    return Scaffold(
      appBar: AppBar(
        title: const Text("Your Meals"),
        actions: <Widget>[
          RaisedButton(
            child: Text(startBtn, style: Styles.darkThemeTextSmall,),
            onPressed: (){
              if(startBtn == "Start") {
                setAlarm();
                setState(() {
                  startBtn = "Done";
                });
              }
            },

          ),
          PopupMenuButton<Settings>(
            // TODO Popup setting menu
            itemBuilder: (BuildContext context) {  },
          )
        ],
      ),
      body: Container(
        color: Colors.black,
        child: ListView.builder(
          itemCount: meals.length,
          itemBuilder: (BuildContext context, int index){
            return MealListItem(meal: meals[index], callback: update);
          },
        ),
      ),
      floatingActionButton: FloatingActionButton(
        child: Image.asset("assets/icons/burger_t.png"),
        backgroundColor: Colors.black,
        onPressed: () async {
          final newMeal = await Navigator.pushNamed(context, '/addMeal');
          addMeal(newMeal);
        },
      ),
    );
  }
}


class MealListItem extends StatelessWidget {
  final Meal meal;
  final callback;

  MealListItem({this.meal, this.callback});

  void removeMeal() async {
    await FileManager.removeMeal(meal.name);
    this.callback();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2.0, horizontal: 4.0),
      child: Card(
        child: ListTile(
            leading: CircleAvatar(
              radius: 30,
              backgroundImage: meal.image == ""  ?
              const AssetImage(Meal.defaultImage) :
              FileImage(File(meal.image)),
            ),
            title: Text(meal.name),
            trailing: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: <Widget>[
                Text((meal.time.inMinutes/60).floor().toString() + " H "
                  + (meal.time.inMinutes%60).toString() + " Min",
                style: Styles.darkThemeTextSmall,),
                const SizedBox(width: 30,),
                CloseButton(
                  onPressed: removeMeal
                ),
              ],
            )
        ),
      ),
    );
  }
}
