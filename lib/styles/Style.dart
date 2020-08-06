import 'package:flutter/material.dart';

class Styles {

  static const TextStyle darkThemeTextSmall = const TextStyle(
    color: Colors.white,
    fontSize: 15.0,
    fontWeight: FontWeight.w400
  );

  static const TextStyle darkThemeTextMiddle = const TextStyle(
      color: Colors.white,
      fontSize: 20.0,
      fontWeight: FontWeight.w400
  );

  static const TextStyle darkThemeTextBig = const TextStyle(
      color: Colors.white,
      fontSize: 15.0,
      fontWeight: FontWeight.w400
  );

  static const TextStyle darkThemeTextBig2 = const TextStyle(
      color: Colors.white,
      fontSize: 15.0,
      fontWeight: FontWeight.w400,
      letterSpacing: 2.0
  );

  static const TextStyle darkThemeTextMiddleGrey = const TextStyle(
      color: Colors.black12,
      fontSize: 20.0,
      fontWeight: FontWeight.w400
  );


  const Styles();

  // TODO: Define own dark theme
  static final ThemeData darkTheme = ThemeData.dark();

  static TextStyle darkThemeText(fontsize){
    return TextStyle(
      color: Colors.white,
      fontSize: fontsize,
      fontWeight: FontWeight.w400
    );
  }

  static TextStyle darkThemeText2(fontsize) {
    return TextStyle(
        fontSize: fontsize,
        letterSpacing: 2.0
    );
  }

  static TextStyle darkThemeTextGrey(fontsize){
    return TextStyle(
        color: Colors.grey[600],
        fontSize: fontsize,
        fontWeight: FontWeight.w400
    );
  }

  static Color getLightBackgroundColor() { return Colors.grey[820];}

  static Color getDarkBackgroundColor() { return Colors.grey[900];}

}