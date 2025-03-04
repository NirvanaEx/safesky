import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../utils/theme_manager.dart';
import '../utils/localization_manager.dart';

class SettingsViewModel extends ChangeNotifier {
  String? selectedLanguageCode;
  ThemeMode? selectedThemeMode;

  /// Инициализация значений на основе текущей локали и темы
  void initialize(BuildContext context) {
    final localizationManager = Provider.of<LocalizationManager>(context, listen: false);
    final themeManager = Provider.of<ThemeManager>(context, listen: false);

    selectedLanguageCode = localizationManager.currentLocale.languageCode;
    selectedThemeMode = themeManager.themeMode;
    notifyListeners();
  }

  void updateLanguageCode(String languageCode) {
    selectedLanguageCode = languageCode;
    notifyListeners();
  }

  void updateThemeMode(ThemeMode themeMode) {
    selectedThemeMode = themeMode;
    notifyListeners();
  }

  Future<void> saveSettings(BuildContext context) async {
    // Сохраняем выбранную локаль и тему
    await Provider.of<LocalizationManager>(context, listen: false)
        .setLocale(selectedLanguageCode ?? 'en');
    if (selectedThemeMode != null) {
      Provider.of<ThemeManager>(context, listen: false)
          .setTheme(selectedThemeMode!);
    }
  }
}
