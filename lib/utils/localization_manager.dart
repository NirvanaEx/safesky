import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LocalizationManager extends ChangeNotifier {
  static const supportedLocales = [
    Locale('en', ''),
    Locale('ru', ''),
    Locale('uz', ''),
  ];

  Locale _currentLocale = supportedLocales[0];

  LocalizationManager() {
    _loadSavedLocale();
  }

  Locale get currentLocale => _currentLocale;

  Future<void> _loadSavedLocale() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? localeCode = prefs.getString('locale');
    if (localeCode != null) {
      _currentLocale = supportedLocales.firstWhere(
              (locale) => locale.languageCode == localeCode,
          orElse: () => supportedLocales[0]);
      notifyListeners();
    }
  }

  Future<void> setLocale(String code) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setString('locale', code);
    _currentLocale = supportedLocales.firstWhere(
            (locale) => locale.languageCode == code,
        orElse: () => supportedLocales[0]);
    notifyListeners();
  }
}
