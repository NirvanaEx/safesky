import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:safe_sky/services/notification_service.dart';
import 'package:safe_sky/viewmodels/add_request_viewmodel.dart';
import 'package:safe_sky/viewmodels/map_share_location_viewmodel.dart';
import 'package:safe_sky/viewmodels/notification_viewmodel.dart';
import 'package:safe_sky/viewmodels/request_list_viewmodel.dart';
import 'package:safe_sky/views/auth/registration/registration_view.dart';
import 'package:safe_sky/views/home/main_view.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:geolocator/geolocator.dart';
import 'package:safe_sky/views/map_share_location_view.dart';
import 'package:safe_sky/views/splash_screen_view.dart';

import 'utils/localization_manager.dart';
import 'viewmodels/auth_viewmodel.dart';
import 'views/auth/login_view.dart';
import 'package:flutter_map_tile_caching/flutter_map_tile_caching.dart';
import 'package:workmanager/workmanager.dart';

void callbackDispatcher() {
  Workmanager().executeTask((task, inputData) async {
    // Загружайте данные о местоположении и отправляйте уведомление
    if (MapShareLocationViewModel().isSharingLocation) { // Убедитесь, что LocationViewModel доступен
      Position position = await Geolocator.getCurrentPosition(
          desiredAccuracy: LocationAccuracy.high);
      String newText = 'Current Location: ${position.latitude}, ${position
          .longitude}';
      NotificationService.updateLocationNotification(newText);
    }

    return Future.value(true);
  });
}


void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await FlutterMapTileCaching.initialise();
  FMTC.instance('openstreetmap').manage.createAsync();

  // Инициализация WorkManager и NotificationService
  Workmanager().initialize(callbackDispatcher, isInDebugMode: false);
  await NotificationService.init();

  await requestPermissions(); // Запрос разрешений перед запуском приложения

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
        ChangeNotifierProvider<MapShareLocationViewModel>(
          create: (_) => MapShareLocationViewModel(),
        ),
        ChangeNotifierProvider<AddRequestViewModel>(
          create: (_) => AddRequestViewModel(),
        ),
        ChangeNotifierProvider<NotificationViewModel>(
          create: (_) => NotificationViewModel(),
        ),
        ChangeNotifierProvider<RequestListViewModel>(
          create: (_) => RequestListViewModel(),
        ),
      ],
      child: Consumer<LocalizationManager>(
        builder: (context, localizationManager, child) {
          return MaterialApp(
            navigatorKey: NotificationService.navigatorKey, // Используем navigatorKey из NotificationService
            locale: localizationManager.currentLocale,
            localizationsDelegates: [
              AppLocalizations.delegate,
              GlobalMaterialLocalizations.delegate,
              GlobalWidgetsLocalizations.delegate,
            ],
            supportedLocales: LocalizationManager.supportedLocales,
            home: SplashScreenView(),
            routes: {
              '/location_view': (context) => MapShareLocationView(), // Маршрут для нужного view
            },
          );
        },
      ),
    );
  }
}


Future<void> requestPermissions() async {
  // Проверка и запрос разрешения на доступ к геолокации
  LocationPermission locationPermission = await Geolocator.checkPermission();
  if (locationPermission == LocationPermission.denied) {
    locationPermission = await Geolocator.requestPermission();
  }

  if (locationPermission == LocationPermission.deniedForever) {
    // Инструкция для пользователя открыть настройки и дать доступ
    print("Please enable location permission in settings.");
  }

  // Запрос на доступ к фоновому местоположению (только для Android 10+)
  if (await Permission.locationWhenInUse.isGranted && await Permission.locationAlways.isDenied) {
    await Permission.locationAlways.request();
  }

  // Проверка и запрос разрешения на камеру
  if (await Permission.camera.isDenied) {
    await Permission.camera.request();
  }

  if (await Permission.notification.isDenied) {
    await Permission.notification.request();
  }
}