import 'package:flutter_local_notifications/flutter_local_notifications.dart';

class NotificationService {
  static final FlutterLocalNotificationsPlugin _notifications =
  FlutterLocalNotificationsPlugin();

  static Future<void> init() async {
    const AndroidInitializationSettings initializationSettingsAndroid =
    AndroidInitializationSettings('@mipmap/ic_launcher');

    final InitializationSettings initializationSettings =
    InitializationSettings(android: initializationSettingsAndroid);

    await _notifications.initialize(initializationSettings);
  }

  static Future<void> showLocationSharingNotification() async {
    const AndroidNotificationDetails androidDetails = AndroidNotificationDetails(
      'location_channel', // ID канала
      'Location Sharing',
      channelDescription: 'Notification for location sharing',
      importance: Importance.max,
      priority: Priority.high,
      ongoing: true,
      showWhen: false,
    );

    const NotificationDetails platformDetails =
    NotificationDetails(android: androidDetails);

    await _notifications.show(
      0,
      'Location Sharing Active',
      'Your location is being shared',
      platformDetails,
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
    );

    const NotificationDetails platformDetails =
    NotificationDetails(android: androidDetails);

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
}
