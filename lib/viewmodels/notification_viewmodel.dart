import 'package:flutter/material.dart';
import 'dart:convert';
import '../models/news_model.dart';
import '../models/notification_model.dart';

class NotificationViewModel extends ChangeNotifier {
  List<NewsModel> _newsList = [];
  List<NotificationModel> _notificationList = [];
  bool _isLoading = false;

  bool get isLoading => _isLoading;

  // Получаем текущую локаль
  String _getCurrentLanguage(BuildContext context) {
    return Localizations.localeOf(context).languageCode;
  }

  List<NewsModel> get newsList => _newsList;
  List<NotificationModel> get notificationList => _notificationList;

  Future<void> loadNews(BuildContext context) async {
    _isLoading = true;
    notifyListeners();

    try {
      final currentLang = _getCurrentLanguage(context);

      // Статически заданные данные
      _newsList = [
        NewsModel(
          dateTime: "2024-10-31 12:00",
          shortDescription: "Breaking News",
          imageUrl: "https://example.com/news_image.jpg",
          description: "This is the full description of the news article.",
          lang: "en",
        ),
        NewsModel(
          dateTime: "2024-10-30 10:30",
          shortDescription: "Новости дня",
          imageUrl: "https://example.com/news_image2.jpg",
          description: "Полное описание новости на русском языке.",
          lang: "ru",
        ),
      ].where((news) => news.lang == currentLang).toList();
    } catch (e) {
      print("Ошибка загрузки новостей: $e");
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> loadNotifications(BuildContext context) async {
    _isLoading = true;
    notifyListeners();

    try {
      final currentLang = _getCurrentLanguage(context);

      // Статически заданные данные
      _notificationList = [
        NotificationModel(
          dateTime: "2024-10-31 08:30",
          shortDescription: "Urgent Update",
          description: "Notification in English",
          lang: "en",
        ),
        NotificationModel(
          dateTime: "2024-10-30 14:00",
          shortDescription: "Системное сообщение",
          description: "Уведомление на русском языке.",
          lang: "ru",
        ),
      ].where((notification) => notification.lang == currentLang).toList();
    } catch (e) {
      print("Ошибка загрузки уведомлений: $e");
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> refreshData(BuildContext context) async {
    await loadNews(context);
    await loadNotifications(context);
  }
}
