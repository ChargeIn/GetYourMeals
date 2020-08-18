/*
import 'dart:io';
import 'dart:isolate';
import 'dart:math';
import 'dart:ui';
import 'package:android_alarm_manager/android_alarm_manager.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:get_your_meals/data/FileManager.dart';
import 'package:get_your_meals/data/Meal.dart';
import 'package:get_your_meals/menus/Settings.dart';
import 'package:get_your_meals/styles/Style.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// The [SharedPreferences] key to access the current meal count.
const String countKey = 'count';

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

  List<Meal> meals;
  ReceivePort receivePort = ReceivePort();
  // The background
  static SendPort uiSendPort;
  FlutterLocalNotificationsPlugin notificationsPlugin = FlutterLocalNotificationsPlugin();
  AndroidInitializationSettings androidInitSettings;
  InitializationSettings initSettings;


  _HomePageState(meals){
    this.meals = meals;
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

  void startTimer() async {
    if(meals.length == 0) return;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(countKey, 0);
    int oldID = Random().nextInt(pow(2, 31));
    await prefs.setInt(id, oldID);

    await AndroidAlarmManager.oneShot(
        meals[0].time, oldID, callback, wakeup: true);
  }

  static void callback() async {
    print("Fired");

    // This will be null if we're running in the background.
    uiSendPort ??= IsolateNameServer.lookupPortByName(isolateName);
    uiSendPort?.send(null);
  }

  Future<void> fireAlarm() async {
    print("fireAlarm");

    // Get the previous cached count and increment it.
    final prefs = await SharedPreferences.getInstance();
    int currentCount = prefs.getInt(countKey)+1;
    await prefs.setInt(countKey, currentCount);
    int oldID = Random().nextInt(pow(2, 31));
    await prefs.setInt(id, oldID);

    if(currentCount < meals.length) {
      List<Meal> meals = await FileManager.loadMeals();
      await AndroidAlarmManager.oneShot(meals[currentCount].time,
        oldID, callback, wakeup: true,);
    }

    _showNotifications(oldID, meals[currentCount-1]);
  }

  @override
  void initState() {
    super.initState();
    AndroidAlarmManager.initialize();

    IsolateNameServer.registerPortWithName(
      port.sendPort,
      isolateName,
    );

    // Register for events from the background isolate. These messages will
    // always coincide with an alarm firing.
    port.listen((_) async => await fireAlarm());


    init();
  }

  void init() async {
    androidInitSettings = AndroidInitializationSettings('app_icon');
    initSettings = InitializationSettings(androidInitSettings,null); // TODO: IOS Settings
    await notificationsPlugin.initialize(initSettings, onSelectNotification: onSelectNotification);
  }

  void _showNotifications(id, Meal meal) async {
    await notifications(id, meal);
  }

  Future<void> notifications(id, Meal meal) async {
     AndroidNotificationDetails androidNotificationDetails =
        AndroidNotificationDetails(
            'Channel ID',
            'Channel title',
            'Channel body',
            priority: Priority.High,
            importance: Importance.Max,
            ticker: 'test' );

     NotificationDetails notificationDetails = NotificationDetails(androidNotificationDetails, null);
    await notificationsPlugin.show(id, meal.name, meal.comment , notificationDetails);
  }

  Future<void> onSelectNotification(String payLoad){
    if(payLoad != null){
      print(payLoad);
    }
    // TODO: on select notification
  }

  @override
  Widget build(BuildContext context) {

    return Scaffold(
      appBar: AppBar(
        title: const Text("Your Meals"),
        actions: <Widget>[
          RaisedButton(
            child: const Text("Start", style: Styles.darkThemeTextSmall,),
            onPressed: (){
              startTimer();
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
            subtitle: Text(meal.comment),
            trailing: Row(
              mainAxisAlignment: MainAxisAlignment.end,
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.end,
              children: <Widget>[
                Text(meal.time.toString(),
                style: Styles.darkThemeTextSmall,),
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
*/
