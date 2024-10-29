import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:provider/provider.dart';
import '../../utils/localization_manager.dart';

class SettingsView extends StatefulWidget {
  @override
  _SettingsViewState createState() => _SettingsViewState();
}

class _SettingsViewState extends State<SettingsView> {
  String? _selectedLanguage;
  String? _selectedTheme;

  @override
  void initState() {
    super.initState();

    // Инициализация значений языка и темы
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _initializeValues();
    });
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _initializeValues();
  }

  void _initializeValues() {
    final localizations = AppLocalizations.of(context);
    final currentLocale = context.read<LocalizationManager>().currentLocale;

    setState(() {
      // Устанавливаем текущий язык
      _selectedLanguage = _getLanguageFromLocale(currentLocale.languageCode, localizations!);

      // Устанавливаем текущую тему на основании текущей локализации
      _selectedTheme = localizations.light;  // Значение по умолчанию (можно установить на основе сохранённого состояния)
    });
  }

  String _getLanguageFromLocale(String languageCode, AppLocalizations localizations) {
    switch (languageCode) {
      case 'ru':
        return localizations.russian;
      case 'en':
        return localizations.english;
      case 'uz':
        return localizations.uzbek;
      default:
        return localizations.english;
    }
  }

  @override
  Widget build(BuildContext context) {
    final localizations = AppLocalizations.of(context)!;

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        iconTheme: IconThemeData(color: Colors.black),
        elevation: 1,
        centerTitle: true,
      ),
      body: _selectedLanguage == null || _selectedTheme == null
          ? Center(child: CircularProgressIndicator())
          : Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Text(
                localizations.settings,
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              ),
            ),
            SizedBox(height: 20),
            _buildDropdown(
              label: localizations.language,
              value: _selectedLanguage!,
              items: [
                localizations.russian,
                localizations.english,
                localizations.uzbek
              ],
              onChanged: (String? newValue) {
                setState(() {
                  _selectedLanguage = newValue!;
                });
              },
            ),
            SizedBox(height: 20),
            _buildDropdown(
              label: localizations.theme,
              value: _selectedTheme!,
              items: [localizations.light],
              onChanged: (String? newValue) {
                setState(() {
                  _selectedTheme = newValue!;
                });
              },
            ),
            Spacer(),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  String localeCode;
                  if (_selectedLanguage == localizations.russian) {
                    localeCode = 'ru';
                  } else if (_selectedLanguage == localizations.english) {
                    localeCode = 'en';
                  } else {
                    localeCode = 'uz';
                  }

                  // Сохраняем и применяем выбранную локаль
                  context.read<LocalizationManager>().setLocale(localeCode).then((_) {
                    // После изменения локали пересоздаем значения на основе текущей локализации
                    _initializeValues();
                  });
                },
                style: ElevatedButton.styleFrom(
                  primary: Colors.black,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30),
                  ),
                  padding: EdgeInsets.symmetric(vertical: 15),
                ),
                child: Text(
                  localizations.save,
                  style: TextStyle(color: Colors.white),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDropdown({
    required String label,
    required String value,
    required List<String> items,
    required ValueChanged<String?> onChanged,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(fontSize: 16, color: Colors.grey),
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
                    children: items.map((item) {
                      return ListTile(
                        title: Text(item, textAlign: TextAlign.center),
                        onTap: () {
                          Navigator.pop(context, item);
                        },
                      );
                    }).toList(),
                  ),
                );
              },
            );

            if (selectedValue != null && selectedValue != value) {
              onChanged(selectedValue);
            }
          },
          child: Container(
            padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: Colors.grey[200],
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(value, style: TextStyle(fontSize: 16)),
                Icon(Icons.arrow_drop_down, color: Colors.grey[700]),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
