import 'package:flutter/material.dart';
import 'package:get_your_meals/pages/AddMeal.dart';
import 'package:get_your_meals/pages/HomePage.dart';
import 'package:get_your_meals/pages/LoadingScreen.dart';
import 'package:get_your_meals/styles/Style.dart';

void main() async {

  runApp(
      MaterialApp(
        title: 'GetYourMeals',
        theme: Styles.darkTheme,
        routes: {
          '/': (context) => LoadingScreen(),
          '/home': (context) => HomePage(),
          '/addMeal': (context) => AddMeal(),
        },
  ));
}
