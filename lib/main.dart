import 'dart:async';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:safe_sky/config/theme_config.dart'; // Импорт темы
import 'package:safe_sky/utils/theme_manager.dart';
import 'package:safe_sky/utils/localization_manager.dart';
import 'package:safe_sky/viewmodels/auth_viewmodel.dart';
import 'package:safe_sky/viewmodels/profile_viewmodel.dart';
import 'package:safe_sky/viewmodels/settings_viewmodel.dart';
import 'package:safe_sky/views/auth/login_view.dart';
// Остальные импорты
import 'package:safe_sky/services/notification_service.dart';
import 'package:safe_sky/viewmodels/add_request_viewmodel.dart';
import 'package:safe_sky/viewmodels/map_share_location_viewmodel.dart';
import 'package:safe_sky/viewmodels/notification_viewmodel.dart';
import 'package:safe_sky/viewmodels/request_list_viewmodel.dart';
import 'package:safe_sky/viewmodels/show_request_viewmodel.dart';

import 'package:permission_handler/permission_handler.dart';
import 'package:geolocator/geolocator.dart';
import 'package:safe_sky/views/map/map_share_location_view.dart';
import 'package:safe_sky/views/side_menu/settings_view.dart';
import 'package:safe_sky/views/splash_screen_view.dart';
import 'package:flutter_map_tile_caching/flutter_map_tile_caching.dart';
import 'package:workmanager/workmanager.dart';

void callbackDispatcher() {
  Workmanager().executeTask((task, inputData) async {
    // Пример: обновление уведомления с текущим местоположением
    // Замените условие на нужное вам
    if (false) {
      Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );
      String newText =
          'Current Location: ${position.latitude}, ${position.longitude}';
      NotificationService.updateLocationNotification(newText);
    }
    return Future.value(true);
  });
}

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await FlutterMapTileCaching.initialise();
  FMTC.instance('openstreetmap').manage.createAsync();
  FMTC.instance('stadiamaps').manage.createAsync();

  Workmanager().initialize(callbackDispatcher, isInDebugMode: false);
  await NotificationService.init();

  await requestPermissions();

  runApp(MyApp());
}

class MyApp extends StatefulWidget {
  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider<LocalizationManager>(create: (_) => LocalizationManager()),
        ChangeNotifierProvider<ThemeManager>(create: (_) => ThemeManager()),
        ChangeNotifierProvider<SettingsViewModel>(create: (_) => SettingsViewModel()),
        ChangeNotifierProvider<MapShareLocationViewModel>(create: (_) => MapShareLocationViewModel()),
        ChangeNotifierProvider<AddRequestViewModel>(create: (_) => AddRequestViewModel()),
        ChangeNotifierProvider<NotificationViewModel>(create: (_) => NotificationViewModel()),
        ChangeNotifierProvider<RequestListViewModel>(create: (_) => RequestListViewModel()),
        ChangeNotifierProvider<ShowRequestViewModel>(create: (_) => ShowRequestViewModel()),
        ChangeNotifierProvider<AuthViewModel>(create: (_) => AuthViewModel()),
        ChangeNotifierProvider<ProfileViewModel>(create: (_) => ProfileViewModel()),
      ],
      child: Consumer2<LocalizationManager, ThemeManager>(
        builder: (context, localizationManager, themeManager, child) {
          return MaterialApp(
            navigatorKey: NotificationService.navigatorKey,
            locale: localizationManager.currentLocale,
            localizationsDelegates: [
              AppLocalizations.delegate,
              GlobalMaterialLocalizations.delegate,
              GlobalWidgetsLocalizations.delegate,
            ],
            supportedLocales: LocalizationManager.supportedLocales,
            home: SplashScreenView(),
            routes: {
              '/location_view': (context) => MapShareLocationView(),
              '/login': (context) => LoginView(),
              '/settings': (context) => SettingsView(),
            },
            theme: lightTheme,
            darkTheme: darkTheme,
            themeMode: themeManager.themeMode,
          );
        },
      ),
    );
  }
}

Future<void> requestPermissions() async {
  // Сначала запрашиваем разрешение на локацию при использовании приложения
  if (await Permission.locationWhenInUse.isDenied) {
    await Permission.locationWhenInUse.request();
  }
  // Затем запрашиваем разрешение на постоянный доступ к локации
  if (await Permission.locationAlways.isDenied) {
    await Permission.locationAlways.request();
  }
  if (await Permission.locationAlways.isPermanentlyDenied) {
    print("Please enable locationAlways permission in settings.");
  }

  // Запрашиваем разрешения для камеры и уведомлений
  if (await Permission.camera.isDenied) {
    await Permission.camera.request();
  }
  if (await Permission.notification.isDenied) {
    await Permission.notification.request();
  }
}