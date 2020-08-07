import 'dart:io';
import 'dart:isolate';
import 'dart:ui';
import 'package:android_alarm_manager/android_alarm_manager.dart';
import 'package:flutter/material.dart';
import 'package:get_your_meals/data/FileManager.dart';
import 'package:get_your_meals/data/Meal.dart';
import 'package:get_your_meals/menus/Settings.dart';
import 'package:get_your_meals/styles/Style.dart';

const String portName = "GetYourMealsPort";

/// Represents the home page of getyourmeals
class HomePage extends StatefulWidget {
  HomePage({Key key, this.meals}) : super(key: key);

  List<Meal> meals;

  @override
  _HomePageState createState() => _HomePageState(meals);
}

class _HomePageState extends State<HomePage> {

  List<Meal> meals;
  int currentMeal = 0;
  ReceivePort receivePort = ReceivePort();

  _HomePageState(meals){
    this.meals = meals;
  }

  bool loaded = false;

  void addMeal(meal){
    setState(() {
      meals.add(meal);
    });
  }

  void startTimer() async {
    await AndroidAlarmManager.initialize();
    currentMeal = 0;
    await AndroidAlarmManager.oneShot(
        meals[currentMeal].time, currentMeal, (id) => callBack(id), wakeup: true);
    print(meals[currentMeal].time);
  }

  static void callBack(int id) async {
    List<Meal> meals = await FileManager.loadMeals();
    id++;
    await AndroidAlarmManager.oneShot( meals[id].time, id, (id) => callBack(id),
    wakeup: true,);
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
            return Padding(
              padding: const EdgeInsets.symmetric(vertical: 2.0, horizontal: 4.0),
              child: Card(
                child: ListTile(
                  leading: CircleAvatar(
                    radius: 30,
                    backgroundImage: meals[index].image == ""  ?
                    const AssetImage(Meal.defaultImage) :
                    FileImage(File(meals[index].image)),
                  ),
                  title: Text(meals[index].name),
                  subtitle: Text(meals[index].comment),
                  trailing: CloseButton(
                    onPressed: () => FileManager.removeMeal(meals[index].name),
                  )
                ),
              ),
            );
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
