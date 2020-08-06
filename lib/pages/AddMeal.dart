import 'dart:io';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_time_picker_spinner/flutter_time_picker_spinner.dart';
import 'package:get_your_meals/data/FileManager.dart';
import 'package:get_your_meals/data/Meal.dart';
import 'package:get_your_meals/styles/Style.dart';
import 'package:image_picker/image_picker.dart';

class AddMeal extends StatefulWidget {
  @override
  _AddMealState createState() => _AddMealState();
}

class _AddMealState extends State<AddMeal> {

  final Map inputs = {
    "name": "",
    "time": Duration(hours: 0),
    "comment" : "",
    "sound": Meal.defaultSound,
    "image" : "",
    "vibration" : true
  };

  final picker = ImagePicker();
  int index = 0;
  final List<DropdownMenuItem<String>> soundItems = Meal.sounds.map((e) =>
            DropdownMenuItem(value: e, child: Text(e))).toList();
  //final String defaultImage = "assets/icons/AddPicture.png";
  
  void update(String field, value) {
    setState(() {
      inputs[field] = value;
    });
  }

  void updateSound(String audio, index){
    setState(() {
      inputs["sound"] = audio;
      this.index = index;
    });
  }

  void _getImage() async {
    final pickedFile = await picker.getImage(source: ImageSource.gallery);
    setState(() {
      inputs["image"] = pickedFile.path;
    });
  }

  void addMeal() async {
    if( inputs["image"] != "") inputs["image"] =
        await FileManager.saveImage(inputs["image"]);

    if(inputs["name"] == "") inputs["name"] = "no-name";

    Meal newMeal = Meal(
        name: inputs["name"],
        image: inputs["image"],
        comment: inputs["comment"],
        time: inputs["time"],
        sound: inputs["sound"],
        vibration: inputs["vibration"]
    );

    FileManager.addMeal(newMeal);
    Navigator.pop(context, newMeal);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Add new meal"),
      ),
      body: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          verticalDirection: VerticalDirection.down,
          children: <Widget>[

            /// name & picture container
            Row(
              children: <Widget>[
                Container(
                  child: Column(
                    children: <Widget>[
                      const SizedBox(height: 5.0),
                      const Text("Chose Icon"),
                      const SizedBox(height: 15.0),
                      GestureDetector(
                        child: CircleAvatar(
                          radius: 35,
                          backgroundImage: inputs["image"] == "" ?
                          const AssetImage(Meal.defaultImage)
                          : FileImage(File(inputs["image"])),
                        ),
                        onTap: _getImage,
                      ),
                    ],
                  ),
                  padding: const EdgeInsets.fromLTRB(15.0, 15.0, 10.0, 10.0),
                ),
                Container(
                  // reduce size by 2*radius and 2* edges
                  width: MediaQuery.of(context).size.width -80 -20 -10,
                  padding: const EdgeInsets.fromLTRB(10.0, 20.0, 20.0,10.0),
                  child: TextField(
                    decoration: const InputDecoration(
                      labelText: "Name",
                      labelStyle: Styles.darkThemeTextSmall,
                    ),
                    onChanged: (String name) {
                      update("name", name);
                    },
                  ),
                ),
              ],
            ),

            /// timer
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 20.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: <Widget>[
                  const Text("Time since last meal: ",
                      style: Styles.darkThemeTextSmall),
                  const SizedBox(width: 20.0,),
                  TimePickerSpinner(
                    is24HourMode: true,
                    normalTextStyle: Styles.darkThemeTextMiddleGrey,
                    highlightedTextStyle: Styles.darkThemeTextMiddle,
                    spacing: 0,
                    itemHeight: 30,
                    isForce2Digits: true,
                    time: DateTime(0),
                    minutesInterval: 5,
                    onTimeChange: (DateTime time) { update("time",
                      Duration(hours: time.hour, minutes: time.minute)); },
                  ),
                ],
              ),
            ),

            /// sound chooser
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 20.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: <Widget>[
                  const Text("Sound: ", style: Styles.darkThemeTextSmall),
                  const SizedBox(width: 20.0,),
                  DropdownButton(
                    value: inputs["sound"],
                    items: soundItems,
                    onChanged: (selected) { update("sound", selected);},
                  ),
                ],
              ),
            ),

            /// Vibration
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 12.0, horizontal: 20.0),
              child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: <Widget>[
                  const Text("Vibration: ", style: Styles.darkThemeTextSmall,),
                  Switch(
                    value: inputs["vibration"],
                    onChanged: (bool s) { update("vibration", s);},
                  ),
                ]
              ),
            ),

            /// Comments
            Container(
              child: TextField(
                decoration: const InputDecoration(
                  labelText: "Comment:",
                  labelStyle: Styles.darkThemeTextSmall,
                ),
                onChanged: (String comment) {
                  update("comment", comment);
                },
              ),
              padding: const EdgeInsets.symmetric(vertical: 5.0, horizontal: 20.0),
            ),

            /// Save Button
            Center(
              child: RaisedButton(
                onPressed: addMeal,
                child:
                  const Text("Add meal"),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
