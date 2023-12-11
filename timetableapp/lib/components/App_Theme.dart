import 'package:flutter/material.dart';


class AppTheme {
  static ThemeData lightTheme = ThemeData(
    primaryColor: Colors.blue,
    secondaryHeaderColor: Colors.orange,
  );

  static ThemeData darkTheme = ThemeData(
    primaryColor: Colors.teal,
    secondaryHeaderColor : Colors.amber,
    brightness: Brightness.dark,
    hintColor: Colors.grey[100],



  );
}

