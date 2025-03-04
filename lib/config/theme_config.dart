import 'package:flutter/material.dart';

/// Цветовые переменные для светлой темы
final Color lightPrimary = Colors.white;
final Color lightScaffoldBackground = Colors.white;
final Color lightBackground = Colors.white;
final Color lightAppBarBackground = Colors.white;
final Color lightAppBarIconColor = Colors.black;
final Color lightAppBarTitleColor = Colors.black;
final Color lightBottomNavSelected = Colors.blue;
final Color lightBottomNavUnselected = Colors.grey;
final Color lightInputFill = Colors.grey[200]!;
final Color lightText = Colors.black;
final Color lightDialogBackground = Colors.grey[200]!;
final Color lightDialogTextButton = Colors.black;

/// Цветовые переменные для тёмной темы
final Color darkPrimary = Colors.blueAccent;
final Color darkScaffoldBackground = Colors.grey[900]!;
final Color darkBackground = Colors.grey[850]!;
final Color darkAppBarBackground = Colors.grey[900]!;
final Color darkAppBarIconColor = Colors.white;
final Color darkAppBarTitleColor = Colors.white;
final Color darkBottomNavSelected = Colors.blueAccent;
final Color darkBottomNavUnselected = Colors.grey;
final Color darkInputFill = Colors.grey[800]!;
final Color darkText = Colors.white;
final Color darkDialogBackground = Colors.grey[800]!;
final Color darkDialogTextButton = Colors.white;

final ThemeData lightTheme = ThemeData(
  brightness: Brightness.light,
  primaryColor: lightPrimary,
  scaffoldBackgroundColor: lightScaffoldBackground,
  backgroundColor: lightBackground,
  appBarTheme: AppBarTheme(
    backgroundColor: lightAppBarBackground,
    iconTheme: IconThemeData(color: lightAppBarIconColor),
    titleTextStyle: TextStyle(
      color: lightAppBarTitleColor,
      fontSize: 20,
      fontWeight: FontWeight.bold,
    ),
  ),
  bottomNavigationBarTheme: BottomNavigationBarThemeData(
    selectedItemColor: lightBottomNavSelected,
    unselectedItemColor: lightBottomNavUnselected,
    backgroundColor: lightScaffoldBackground,
  ),
  inputDecorationTheme: InputDecorationTheme(
    fillColor: lightInputFill,
    filled: true,
    border: OutlineInputBorder(
      borderRadius: BorderRadius.circular(30),
      borderSide: BorderSide.none,
    ),
    enabledBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(30),
      borderSide: BorderSide.none,
    ),
    focusedBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(30),
      borderSide: BorderSide.none,
    ),
    contentPadding: const EdgeInsets.symmetric(horizontal: 25, vertical: 20),
  ),
  textTheme: TextTheme(
    titleMedium: TextStyle(color: lightText, fontSize: 16),
    bodyLarge: TextStyle(color: lightText, fontSize: 16),
  ),
  iconTheme: IconThemeData(color: lightText),
  dialogTheme: DialogTheme(
    backgroundColor: lightDialogBackground,
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(20),
    ),
  ),
  // ElevatedButton стиль для светлой темы
  elevatedButtonTheme: ElevatedButtonThemeData(
    style: ElevatedButton.styleFrom(
      backgroundColor: Colors.black,
      foregroundColor: Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(30),
      ),
      padding: EdgeInsets.symmetric(vertical: 15),
      textStyle: TextStyle(fontSize: 16),
    ),
  ),
  // TextButton стиль
  textButtonTheme: TextButtonThemeData(
    style: TextButton.styleFrom(
      foregroundColor: Colors.blue,
      textStyle: TextStyle(fontSize: 16),
    ),
  ),
  // Добавленная тема для FloatingActionButton
  floatingActionButtonTheme: FloatingActionButtonThemeData(
    backgroundColor: Colors.black,
  ),
);

final ThemeData darkTheme = ThemeData(
  brightness: Brightness.dark,
  primaryColor: darkPrimary,
  scaffoldBackgroundColor: darkScaffoldBackground,
  backgroundColor: darkBackground,
  appBarTheme: AppBarTheme(
    backgroundColor: darkAppBarBackground,
    iconTheme: IconThemeData(color: darkAppBarIconColor),
    titleTextStyle: TextStyle(
      color: darkAppBarTitleColor,
      fontSize: 20,
      fontWeight: FontWeight.bold,
    ),
  ),
  bottomNavigationBarTheme: BottomNavigationBarThemeData(
    selectedItemColor: darkBottomNavSelected,
    unselectedItemColor: darkBottomNavUnselected,
    backgroundColor: darkScaffoldBackground,
  ),
  inputDecorationTheme: InputDecorationTheme(
    fillColor: darkInputFill,
    filled: true,
    border: OutlineInputBorder(
      borderRadius: BorderRadius.circular(30),
      borderSide: BorderSide.none,
    ),
    enabledBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(30),
      borderSide: BorderSide.none,
    ),
    focusedBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(30),
      borderSide: BorderSide.none,
    ),
    contentPadding: const EdgeInsets.symmetric(horizontal: 25, vertical: 20),
  ),
  textTheme: TextTheme(
    titleMedium: TextStyle(color: darkText, fontSize: 16),
    bodyLarge: TextStyle(color: darkText, fontSize: 16),
  ),
  iconTheme: IconThemeData(color: darkText),
  dialogTheme: DialogTheme(
    backgroundColor: darkDialogBackground,
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(20),
    ),
  ),
  // ElevatedButton стиль для тёмной темы
  elevatedButtonTheme: ElevatedButtonThemeData(
    style: ElevatedButton.styleFrom(
      backgroundColor: Colors.blue,
      foregroundColor: Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(30),
      ),
      padding: EdgeInsets.symmetric(vertical: 15),
      textStyle: TextStyle(fontSize: 16),
    ),
  ),
  // TextButton стиль
  textButtonTheme: TextButtonThemeData(
    style: TextButton.styleFrom(
      foregroundColor: Colors.blue,
      textStyle: TextStyle(fontSize: 16),
    ),
  ),
  // Добавленная тема для FloatingActionButton
  floatingActionButtonTheme: FloatingActionButtonThemeData(
    backgroundColor: Colors.blue,
  ),
);
