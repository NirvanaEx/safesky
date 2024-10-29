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
  await FlutterMapTileCaching.initialise(); // Инициализация кэширования карты

  // Создаем хранилище с именем 'openstreetmap' для карты
  FMTC.instance('openstreetmap').manage.createAsync();

  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider<AuthViewModel>(
          create: (_) => AuthViewModel(),
        ),
        ChangeNotifierProvider<LocalizationManager>(
          create: (_) => LocalizationManager(),
        ),
      ],
      child: Consumer<LocalizationManager>(
        builder: (context, localizationManager, child) {
          return MaterialApp(
            locale: localizationManager.currentLocale,
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
  }
}

// Запрос разрешений для камеры и геолокации
Future<void> requestPermissions() async {
  await Geolocator.requestPermission();
  await Permission.camera.request();
}
