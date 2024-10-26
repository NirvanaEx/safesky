import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LocalizationManager {
  static const supportedLocales = [
    Locale('en', ''),
    Locale('ru', ''),
  ];

  static Future<Locale> getSavedLocale() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? localeCode = prefs.getString('locale');
    if (localeCode == null) return supportedLocales[0];
    return supportedLocales.firstWhere((locale) => locale.languageCode == localeCode, orElse: () => supportedLocales[0]);
  }

  static void changeLocale(BuildContext context, String code) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setString('locale', code);
    (context as Element).markNeedsBuild();
  }
}
