import 'dart:io';
import 'dart:ui';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get_your_meals/data/FileManager.dart';
import 'package:get_your_meals/data/Meal.dart';
import 'package:get_your_meals/menus/Settings.dart';
import 'package:get_your_meals/styles/Style.dart';
import 'package:get_your_meals/utils/NotificationPlugin.dart';


/// Represents the home page of getyourmeals
class HomePage extends StatefulWidget {

  HomePage({Key key, this.meals}) : super(key: key);
  final List<Meal> meals;

  @override
  _HomePageState createState() => _HomePageState(meals);
}

class _HomePageState extends State<HomePage> {

  List<Meal> meals;
  String startBtn = "Start";
  NotificationPlugin notificationPlugin;

  _HomePageState(meals) {
    this.meals = meals;
    init();
  }

  void init() async {
    startBtn = await FileManager.isRestartOverdue() ? "Start" : "Stop";
  }

  bool loaded = false;

  void addMeal(meal){
    setState(() {
      meals.add(meal);
    });
  }

  void setAlarms() async {
    int id = 0;
    int sec = DateTime.now().millisecondsSinceEpoch;
    meals.forEach((meal) {
      notificationPlugin.setNotification(meal, id);
      sec += meal.time.inMilliseconds;
      id++;
    });
    FileManager.setRestartTime(DateTime.fromMicrosecondsSinceEpoch(sec).toString());
  }

  void update() async {
     meals = await FileManager.loadMeals();
    setState(() {});
  }

  @override
  void initState() {
    super.initState();

    notificationPlugin = NotificationPlugin();
    notificationPlugin
        .setListenerForLowerVersions(onNotificationInLowerVersions);
    notificationPlugin.setOnNotificationClick(onNotificationClick);
  }

  @override
  Widget build(BuildContext context) {

    return Scaffold(
      appBar: AppBar(
        title: const Text("Your Meals"),
        actions: <Widget>[
          RaisedButton(
            child: Text(startBtn, style: Styles.darkThemeTextSmall,),
            onPressed: () async {
              if(startBtn == "Start") {
                setAlarms();
                setState(() {
                  startBtn = "Stop";
                });
              } else {
                await notificationPlugin.cancelAllNotification();
                setState(() {
                  startBtn = "Start";
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

  onNotificationInLowerVersions(ReceivedNotification receivedNotification) {
    print('Notification Received ${receivedNotification.id}');
  }

  onNotificationClick(String payload) {
    print('Payload $payload');
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
