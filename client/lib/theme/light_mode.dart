import 'package:flutter/material.dart';

ThemeData lightTheme = ThemeData(
  brightness: Brightness.light,
  colorScheme: ColorScheme.light(
    surface: Colors.grey.shade300,
    primary: Colors.grey.shade200,
    secondary: Colors.deepPurple.shade400,
    inversePrimary: Colors.deepPurple.shade600,
  ),
  textTheme: ThemeData.light().textTheme.apply(bodyColor: Colors.grey[800]),
  disabledColor: Colors.black,
);
