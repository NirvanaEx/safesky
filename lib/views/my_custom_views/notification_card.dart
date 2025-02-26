import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class NotificationCard extends StatelessWidget {
  final String dateTime;
  final String shortDescription;
  final String description;

  NotificationCard({
    required this.dateTime,
    required this.shortDescription,
    required this.description,
  });

  // Метод для форматирования даты и времени
  String _formatDateTime(String dateTime) {
    final parsedDateTime = DateTime.parse(dateTime);
    return DateFormat('dd.MM.yyyy HH:mm').format(parsedDateTime);
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 3,
      margin: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Дата и время с разделительной линией
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  _formatDateTime(dateTime),
                  style: TextStyle(fontSize: 12, color: Colors.grey),
                ),
                Divider(color: Colors.grey[300], thickness: 1),
              ],
            ),
            SizedBox(height: 8),
            // Краткое описание жирным текстом
            Text(
              shortDescription,
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.black),
            ),
            SizedBox(height: 8),
            // Описание обычным текстом
            Text(
              description,
              style: TextStyle(fontSize: 14, color: Colors.black87),
            ),
          ],
        ),
      ),
    );
  }
}
