import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:safe_sky/views/auth/login_view.dart';
import 'utils/localization_manager.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Получаем сохраненную локаль перед запуском приложения
  Locale locale = await LocalizationManager.getSavedLocale();

  runApp(MyApp(locale: locale));
}

class MyApp extends StatefulWidget {
  final Locale locale;

  MyApp({required this.locale});

  // Метод для изменения локали
  static void setLocale(BuildContext context, Locale newLocale) {
    _MyAppState? state = context.findAncestorStateOfType<_MyAppState>();
    state?.changeLocale(newLocale);
  }

  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  Locale? _locale;

  @override
  void initState() {
    super.initState();
    _locale = widget.locale;
  }

  // Метод для смены локали
  void changeLocale(Locale locale) {
    setState(() {
      _locale = locale;
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      locale: _locale,
      localizationsDelegates: [
        AppLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ],
      supportedLocales: [
        Locale('en', ''),
        Locale('ru', ''),
      ],
      home: LoginView(), // Устанавливаем LoginView как начальную страницу
    );
  }
}

class HomeScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(AppLocalizations.of(context)!.title)),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(AppLocalizations.of(context)!.greeting),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                LocalizationManager.changeLocale(context, 'en');
              },
              child: Text('Switch to English'),
            ),
            ElevatedButton(
              onPressed: () {
                LocalizationManager.changeLocale(context, 'ru');
              },
              child: Text('Переключить на русский'),
            ),
          ],
        ),
      ),
    );
  }
}
