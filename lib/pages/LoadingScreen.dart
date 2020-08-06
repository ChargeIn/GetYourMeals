import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:get_your_meals/data/FileManager.dart';
import 'package:get_your_meals/data/Meal.dart';
import 'package:get_your_meals/pages/HomePage.dart';
import 'package:get_your_meals/styles/Style.dart';


class LoadingScreen extends StatelessWidget {

  void loadMeals(context) async {
    List<Meal> meals =  await FileManager.loadMeals();
    Navigator.of(context).pushReplacement(
        new MaterialPageRoute(
          builder: (BuildContext builder) =>
              HomePage(key: key, meals: meals)));
  }

  @override
  Widget build(BuildContext context) {

    SchedulerBinding.instance.addPostFrameCallback((timeStamp) {
      loadMeals(context);
    });

    return Scaffold(
      body: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: <Widget>[
            const Text(" Loading ...",
              style: Styles.darkThemeTextBig2,
            ),
            const SizedBox( height: 40.0),
            const SpinKitWave(
              color: Colors.deepOrange,
              size: 50,
            ),
            const SizedBox( height: 30.0),
          ],
        )
    );
  }
}
