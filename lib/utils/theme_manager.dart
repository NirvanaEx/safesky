import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ThemeManager extends ChangeNotifier {
  ThemeMode _themeMode = ThemeMode.light;
  ThemeMode get themeMode => _themeMode;

  ThemeManager() {
    _loadTheme(); // Загружаем сохранённую тему при инициализации
  }

  void setTheme(ThemeMode newTheme) async {
    _themeMode = newTheme;
    notifyListeners();
    // Сохраняем выбранную тему в SharedPreferences
    final prefs = await SharedPreferences.getInstance();
    prefs.setString('themeMode', newTheme == ThemeMode.dark ? 'dark' : 'light');
  }

  Future<void> _loadTheme() async {
    final prefs = await SharedPreferences.getInstance();
    final themeString = prefs.getString('themeMode');
    if (themeString != null) {
      _themeMode = themeString == 'dark' ? ThemeMode.dark : ThemeMode.light;
      notifyListeners();
    }
  }
}
