import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class NewsCard extends StatelessWidget {
  final String dateTime;
  final String shortDescription;
  final String imageUrl;
  final String description;

  NewsCard({
    required this.dateTime,
    required this.shortDescription,
    required this.imageUrl,
    required this.description,
  });

  // Форматируем дату и время
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
            // Краткое описание
            Text(
              shortDescription,
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.black),
            ),
            SizedBox(height: 8),
            // Изображение, если оно есть, или placeholder при ошибке
            if (imageUrl.isNotEmpty)
              Image.network(
                imageUrl,
                height: 150,
                width: double.infinity,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) => Container(
                  height: 150,
                  width: double.infinity,
                  color: Colors.grey[300],
                  alignment: Alignment.center,
                  child: Icon(
                    Icons.image_not_supported,
                    color: Colors.grey[600],
                    size: 50,
                  ),
                ),
              ),
            if (imageUrl.isNotEmpty) SizedBox(height: 8),
            // Полное описание
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
