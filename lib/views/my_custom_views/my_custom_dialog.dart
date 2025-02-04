import 'package:flutter/material.dart';

class MyCustomDialog {
  /// Отображает диалоговое окно с заголовком, сообщением и кнопками "OK" и "Отмена"
  /// [okText] и [cancelText] можно передать для кастомизации текста кнопок.
  /// Возвращает Future<bool?>, где true – пользователь нажал "OK", false – "Отмена" или закрытие диалога.
  static Future<bool?> showOkCancelNotificationDialog(
      BuildContext context,
      String title,
      String message, {
        String cancelText = "Cancel",
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
  static Future<void> showNotificationDialog(BuildContext context, String title, String message) {
    return showDialog<void>(
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


  static Future<String?> showCancelReasonDialog(
      BuildContext context,
      String title,
      String hintText, {
        String cancelText = "Cancel",
        String okText = "OK",
      }) async {
    TextEditingController reasonController = TextEditingController();
    return showDialog<String>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          title: Text(
            title,
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          content: TextField(
            controller: reasonController,
            decoration: InputDecoration(hintText: hintText),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text(
                cancelText,
                style: TextStyle(fontSize: 16),
              ),
            ),
            TextButton(
              onPressed: () => Navigator.of(context).pop(reasonController.text),
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
}
