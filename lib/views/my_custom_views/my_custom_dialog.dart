import 'package:flutter/material.dart';

class MyCustomDialog {
  /// Отображает диалоговое окно с заголовком, сообщением и кнопками "OK" и "Отмена"
  /// [okText] и [cancelText] можно передать для кастомизации текста кнопок.
  /// Возвращает Future<bool?>, где true – пользователь нажал "OK", false – "Отмена" или закрытие диалога.
  static Future<bool?> showOkCancelNotificationDialog(
      BuildContext context,
      String title,
      String message, {
        String cancelText = "Отмена",
        String okText = "OK",
      }) {
    return showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          contentPadding: EdgeInsets.all(20),
          title: Text(
            title,
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          content: Text(message),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context, false);
              },
              child: Text(
                cancelText,
                style: TextStyle(fontSize: 16),
              ),
            ),
            TextButton(
              onPressed: () {
                Navigator.pop(context, true);
              },
              child: Text(
                okText,
                style: TextStyle(fontSize: 16),
              ),
            ),
          ],
        );
      },
    );
  }

  /// Пример простого диалога с кнопкой "OK"
  static void showNotificationDialog(
      BuildContext context, String title, String message) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          contentPadding: EdgeInsets.all(20),
          title: Text(
            title,
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          content: Text(message),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: Text(
                "OK",
                style: TextStyle(fontSize: 16),
              ),
            ),
          ],
        );
      },
    );
  }
}
