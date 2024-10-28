import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:safe_sky/views/auth/registration/registration_view.dart';
import 'package:safe_sky/views/home/main_view.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:geolocator/geolocator.dart';

import 'utils/localization_manager.dart';
import 'viewmodels/auth_viewmodel.dart';
import 'views/auth/login_view.dart';
import 'package:flutter_map_tile_caching/flutter_map_tile_caching.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  // Инициализация кэширования карты перед запуском приложения
  await FlutterMapTileCaching.initialise(); // Инициализируем кэш

  // Создаем хранилище с именем 'openstreetmap' для карты
  FMTC.instance('openstreetmap').manage.createAsync();

  runApp(MyApp());
}

// Запрос разрешений для камеры и геолокации
Future<void> requestPermissions() async {
  await Geolocator.requestPermission();
  await Permission.camera.request();
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: initializeApp(),
      builder: (context, snapshot) {
        // Экран-загрузчик до завершения инициализации
        if (snapshot.connectionState != ConnectionState.done) {
          return MaterialApp(
            home: Scaffold(
              body: Center(child: CircularProgressIndicator()), // Индикатор загрузки
            ),
          );
        }
        // Основное приложение после инициализации
        return MultiProvider(
          providers: [
            ChangeNotifierProvider<AuthViewModel>(
              create: (_) => AuthViewModel(),
            ),
          ],
          child: Consumer<AuthViewModel>(
            builder: (context, authViewModel, child) {
              return MaterialApp(
                locale: snapshot.data as Locale? ?? Locale('en'), // Значение по умолчанию, если locale = null
                localizationsDelegates: [
                  AppLocalizations.delegate,
                  GlobalMaterialLocalizations.delegate,
                  GlobalWidgetsLocalizations.delegate,
                ],
                supportedLocales: LocalizationManager.supportedLocales,
                home: MainView(),
              );
            },
          ),
        );
      },
    );
  }

  // Функция для инициализации приложения
  Future<Locale> initializeApp() async {
    await requestPermissions(); // Запрашиваем разрешения

    // Получаем сохраненную локаль или используем значение по умолчанию
    Locale? locale = await LocalizationManager.getSavedLocale();
    return locale ?? Locale('en'); // Замените 'en' на язык по умолчанию, если нужен другой
  }
}
