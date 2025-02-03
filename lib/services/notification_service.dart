import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import '../viewmodels/map_share_location_viewmodel.dart';
import 'package:provider/provider.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class NotificationService {
  static final FlutterLocalNotificationsPlugin _notifications =
  FlutterLocalNotificationsPlugin();
  static final GlobalKey<NavigatorState> navigatorKey =
  GlobalKey<NavigatorState>(); // добавляем navigatorKey

  // Callback для локальных уведомлений на iOS
  static Future<void> _onDidReceiveLocalNotification(
      int id,
      String? title,
      String? body,
      String? payload,
      ) async {
    // Обработка локального уведомления для iOS (например, переход на нужный экран)
    if (payload != null) {
      _handleNotificationTap(payload);
    }
  }

  static Future<void> init() async {
    const AndroidInitializationSettings initializationSettingsAndroid =
    AndroidInitializationSettings('@mipmap/ic_launcher');

    // Настройки для iOS
    const DarwinInitializationSettings initializationSettingsIOS =
    DarwinInitializationSettings(
      onDidReceiveLocalNotification: _onDidReceiveLocalNotification,
    );

    final InitializationSettings initializationSettings =
    InitializationSettings(
      android: initializationSettingsAndroid,
      iOS: initializationSettingsIOS,
    );

    await _notifications.initialize(
      initializationSettings,
      onDidReceiveNotificationResponse:
          (NotificationResponse notificationResponse) {
        // Обработка действий в уведомлении
        final String? payload = notificationResponse.payload;
        if (notificationResponse.actionId == 'stop_action') {
          _stopLocationSharing();
        } else if (payload != null) {
          _handleNotificationTap(payload);
        }
      },
    );
  }

  static void _handleNotificationTap(String payload) {
    if (payload == 'location_view') {
      navigatorKey.currentState?.pushNamed('/location_view');
    }
  }

  static Future<void> showLocationSharingNotification(
      BuildContext context) async {
    final localizations = AppLocalizations.of(context)!;

    AndroidNotificationDetails androidDetails = AndroidNotificationDetails(
      'location_channel',
      localizations.notification_channelName,
      channelDescription: localizations.notification_channelDescription,
      importance: Importance.max,
      priority: Priority.high,
      ongoing: true,
      autoCancel: false,
      showWhen: false,
      actions: <AndroidNotificationAction>[
        AndroidNotificationAction(
          'stop_action', // Уникальный идентификатор действия
          localizations.notification_stopAction, // Название кнопки завершения
          cancelNotification: true, // Убирает уведомление при нажатии
        ),
      ],
    );

    // Добавляем настройки для iOS
    const DarwinNotificationDetails iOSDetails = DarwinNotificationDetails();

    NotificationDetails platformDetails = NotificationDetails(
      android: androidDetails,
      iOS: iOSDetails,
    );

    await _notifications.show(
      0,
      localizations.notification_activeTitle,
      localizations.notification_activeBody,
      platformDetails,
      payload: 'location_view', // Указываем payload для определения целевого view
    );
  }

  static Future<void> updateLocationNotification(String newText) async {
    const AndroidNotificationDetails androidDetails = AndroidNotificationDetails(
      'location_channel',
      'Location Sharing',
      channelDescription: 'Notification for location sharing',
      importance: Importance.max,
      priority: Priority.high,
      ongoing: true,
      showWhen: false,
      actions: <AndroidNotificationAction>[
        AndroidNotificationAction(
          'stop_action',
          'Stop Sharing',
          cancelNotification: true,
        ),
      ],
    );

    // Добавляем настройки для iOS
    const DarwinNotificationDetails iOSDetails = DarwinNotificationDetails();

    const NotificationDetails platformDetails = NotificationDetails(
      android: androidDetails,
      iOS: iOSDetails,
    );

    await _notifications.show(
      0,
      'Location Sharing Active',
      newText,
      platformDetails,
    );
  }

  static Future<void> cancelNotification() async {
    await _notifications.cancel(0);
  }

  static Future<void> _stopLocationSharing() async {
    final locationVM =
    navigatorKey.currentContext?.read<MapShareLocationViewModel>();
    if (locationVM != null) {
      locationVM.resetLocationSharing(); // Сбрасываем состояние трансляции
    }
    // Явно отменяем уведомление, если оно осталось активным
    await cancelNotification();
  }
}
