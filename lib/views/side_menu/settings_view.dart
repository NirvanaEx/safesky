import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:provider/provider.dart';
import '../../viewmodels/settings_viewmodel.dart';

class SettingsView extends StatefulWidget {
  @override
  _SettingsViewState createState() => _SettingsViewState();
}

class _SettingsViewState extends State<SettingsView> {
  @override
  void initState() {
    super.initState();
    // Инициализируем viewmodel после первого кадра
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<SettingsViewModel>(context, listen: false).initialize(context);
    });
  }

  @override
  Widget build(BuildContext context) {
    final localizations = AppLocalizations.of(context)!;

    // Мапа для языков: ключ – код, значение – локализованное название
    final languageMap = {
      'ru': localizations.russian,
      'en': localizations.english,
      'uz': localizations.uzbek,
    };

    // Мапа для темы: ключ – условный код, значение – локализованное название
    final themeMap = {
      'light': localizations.light,
      'dark': localizations.dark,
    };

    return Scaffold(
      // AppBar теперь берётся из темы (AppBarTheme), можно задать только centerTitle и title
      appBar: AppBar(
        centerTitle: true,
        title: Text(localizations.mainView_settings),
      ),
      body: Consumer<SettingsViewModel>(
        builder: (context, viewModel, child) {
          if (viewModel.selectedLanguageCode == null ||
              viewModel.selectedThemeMode == null) {
            return Center(child: CircularProgressIndicator());
          }
          return Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildDropdown(
                  label: localizations.language,
                  value: languageMap[viewModel.selectedLanguageCode]!,
                  items: languageMap,
                  onChanged: (String? newCode) {
                    if (newCode != null) {
                      viewModel.updateLanguageCode(newCode);
                    }
                  },
                ),
                SizedBox(height: 20),
                _buildDropdown(
                  label: localizations.theme,
                  value: viewModel.selectedThemeMode == ThemeMode.light
                      ? themeMap['light']!
                      : themeMap['dark']!,
                  items: themeMap,
                  onChanged: (String? newKey) {
                    if (newKey != null) {
                      if (newKey == 'light') {
                        viewModel.updateThemeMode(ThemeMode.light);
                      } else if (newKey == 'dark') {
                        viewModel.updateThemeMode(ThemeMode.dark);
                      }
                    }
                  },
                ),
                Spacer(),
                SizedBox(
                  width: double.infinity,
                  // Кнопка "Сохранить" не задаёт стиль вручную – стиль берётся из темы
                  child: ElevatedButton(
                    onPressed: () {
                      viewModel.saveSettings(context);
                    },
                    child: Text(localizations.settingsView_save),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  /// Универсальный виджет для выпадающего списка, который принимает мапу значений.
  /// Ключ мапы используется как значение, а значение – как отображаемый текст.
  Widget _buildDropdown({
    required String label,
    required String value,
    required Map<String, String> items,
    required ValueChanged<String?> onChanged,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: Theme.of(context)
              .textTheme
              .bodyLarge
              ?.copyWith(color: Colors.grey),
        ),
        SizedBox(height: 8),
        GestureDetector(
          onTap: () async {
            final selectedValue = await showModalBottomSheet<String>(
              context: context,
              builder: (BuildContext context) {
                return Container(
                  padding: EdgeInsets.symmetric(vertical: 16),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: items.entries.map((entry) {
                      return ListTile(
                        title: Text(entry.value, textAlign: TextAlign.center),
                        onTap: () {
                          Navigator.pop(context, entry.key);
                        },
                      );
                    }).toList(),
                  ),
                );
              },
            );
            if (selectedValue != null) {
              onChanged(selectedValue);
            }
          },
          child: Container(
            padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: Theme.of(context).inputDecorationTheme.fillColor,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(value,
                    style: Theme.of(context).textTheme.bodyLarge),
                Icon(Icons.arrow_drop_down,
                    color: Theme.of(context).iconTheme.color),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
