import 'dart:io';

import 'package:flutter/material.dart';
import 'package:get_your_meals/data/FileManager.dart';
import 'package:get_your_meals/data/Meal.dart';
import 'package:get_your_meals/menus/Settings.dart';

/// Represents the home page of getyourmeals
class HomePage extends StatefulWidget {
  HomePage({Key key, this.meals}) : super(key: key);

  List<Meal> meals;

  @override
  _HomePageState createState() => _HomePageState(meals);
}

class _HomePageState extends State<HomePage> {

  List<Meal> meals;

  _HomePageState(meals){
    this.meals = meals;
  }

  bool loaded = false;

  void addMeal(meal){
    setState(() {
      meals.add(meal);
    });
  }

  @override
  Widget build(BuildContext context) {

    return Scaffold(
      appBar: AppBar(
        title: const Text("Your Meals"),
        actions: <Widget>[
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
                  trailing: Text(meals[index].time.toString()),
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
