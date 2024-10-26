import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../main.dart';

class LocalizationManager {
  static const String _localeKey = 'locale';

  // Получение сохраненной локали
  static Future<Locale> getSavedLocale() async {
    final prefs = await SharedPreferences.getInstance();
    final localeCode = prefs.getString(_localeKey) ?? 'en';
    return Locale(localeCode);
  }

  // Установка новой локали
  static Future<void> setLocale(String localeCode) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_localeKey, localeCode);
  }

  // Метод для обновления локали в приложении
  static void changeLocale(BuildContext context, String localeCode) {
    setLocale(localeCode);
    MyApp.setLocale(context, Locale(localeCode));
  }
}
