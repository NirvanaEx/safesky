import 'dart:async'; // Для Timer
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:safe_sky/services/auth_service.dart';
import 'package:safe_sky/services/notification_service.dart';
import 'package:safe_sky/viewmodels/add_request_viewmodel.dart';
import 'package:safe_sky/viewmodels/map_share_location_viewmodel.dart';
import 'package:safe_sky/viewmodels/notification_viewmodel.dart';
import 'package:safe_sky/viewmodels/request_list_viewmodel.dart';
import 'package:safe_sky/viewmodels/show_request_viewmodel.dart';
import 'package:safe_sky/views/auth/registration/registration_view.dart';
import 'package:safe_sky/views/home/main_view.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:geolocator/geolocator.dart';
import 'package:safe_sky/views/map/map_share_location_view.dart';
import 'package:safe_sky/views/splash_screen_view.dart';

// Импорты для работы с WorkManager, FlutterMapTileCaching
import 'package:flutter_map_tile_caching/flutter_map_tile_caching.dart';
import 'package:workmanager/workmanager.dart';


import 'utils/localization_manager.dart';
import 'viewmodels/auth_viewmodel.dart';
import 'views/auth/login_view.dart';

void callbackDispatcher() {
  Workmanager().executeTask((task, inputData) async {
    // Загружайте данные о местоположении и отправляйте уведомление
    if (MapShareLocationViewModel().isSharingLocation) {
      Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );
      String newText = 'Current Location: ${position.latitude}, ${position.longitude}';
      NotificationService.updateLocationNotification( newText);
    }

    return Future.value(true);
  });
}

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await FlutterMapTileCaching.initialise();
  FMTC.instance('openstreetmap').manage.createAsync();

  // Инициализация WorkManager и NotificationService
  Workmanager().initialize(callbackDispatcher, isInDebugMode: false);
  await NotificationService.init();

  await requestPermissions(); // Запрос разрешений перед запуском приложения

  runApp(MyApp());
}

///
/// Мы делаем MyApp stateful-классом, чтобы запустить Timer для проверки токена.
///
class MyApp extends StatefulWidget {
  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {



  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider<AuthViewModel>(create: (_) => AuthViewModel()),
        ChangeNotifierProvider<LocalizationManager>(create: (_) => LocalizationManager()),
        ChangeNotifierProvider<MapShareLocationViewModel>(create: (_) => MapShareLocationViewModel()),
        ChangeNotifierProvider<AddRequestViewModel>(create: (_) => AddRequestViewModel()),
        ChangeNotifierProvider<NotificationViewModel>(create: (_) => NotificationViewModel()),
        ChangeNotifierProvider<RequestListViewModel>(create: (_) => RequestListViewModel()),
        ChangeNotifierProvider<ShowRequestViewModel>(create: (_) => ShowRequestViewModel()),
      ],
      child: Consumer<LocalizationManager>(
        builder: (context, localizationManager, child) {
          return MaterialApp(
            navigatorKey: NotificationService.navigatorKey,
            locale: localizationManager.currentLocale,
            localizationsDelegates: [
              AppLocalizations.delegate,
              GlobalMaterialLocalizations.delegate,
              GlobalWidgetsLocalizations.delegate,
            ],
            supportedLocales: LocalizationManager.supportedLocales,

            /// Экран-загрузчик (SplashScreen) ставим как начальный
            home: SplashScreenView(),

            /// Определяем маршруты
            routes: {
              '/location_view': (context) => MapShareLocationView(),
              '/login': (context) => LoginView(), // <-- Роут на экран логина
              // Добавьте остальные, если нужно
            },
          );
        },
      ),
    );
  }
}

///
/// Запрос всех нужных разрешений (геолокация, камера, уведомления и т.д.)
///
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
  if (await Permission.locationWhenInUse.isGranted &&
      await Permission.locationAlways.isDenied) {
    await Permission.locationAlways.request();
  }

  // Проверка и запрос разрешения на камеру
  if (await Permission.camera.isDenied) {
    await Permission.camera.request();
  }

  // Проверка и запрос разрешения на уведомления
  if (await Permission.notification.isDenied) {
    await Permission.notification.request();
  }
}
