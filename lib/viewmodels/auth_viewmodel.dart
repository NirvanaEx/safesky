import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../services/auth_service.dart';
import '../models/user_model.dart';

class AuthViewModel extends ChangeNotifier {
  final AuthService _authService = AuthService();

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  String? _errorMessage;
  String? get errorMessage => _errorMessage;

  UserModel? _user;
  UserModel? get user => _user;

  // Метод для авторизации
  Future<bool> login(String email, String password) async {
    _setLoading(true);  // Устанавливаем состояние загрузки
    notifyListeners();

    try {
      bool success = await _authService.login(email, password);
      _setLoading(false);
      return success;
    } catch (e) {
      // Сохраняем сообщение об ошибке
      _errorMessage = e is Exception ? e.toString() : 'Ошибка авторизации';
      print('Login error: $_errorMessage'); // Лог ошибки
      _setLoading(false);
      notifyListeners();
      return false;
    }
  }

  // Метод для проверки аутентификации
  Future<bool> isAuthenticated() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? token = prefs.getString('auth_token');

    if (token != null && token.isNotEmpty) {
      // Проверяем токен на сервере
      final isValid = await _authService.isTokenValid();
      if (!isValid) {
        await logout(); // Удаляем недействительный токен и очищаем данные пользователя
        return false;
      }

      // Восстанавливаем данные пользователя, если они сохранены
      String? userData = prefs.getString('user_data');
      if (userData != null) {
        _user = UserModel.fromJson(jsonDecode(userData));
        notifyListeners();
      }
      return true;
    }
    return false;
  }

  // Метод для регистрации
  //Шаг 1 : Метод отправки email
  Future<void> sendEmail(String email) async {
    _setLoading(true);
    _errorMessage = null; // Очистка предыдущих ошибок
    try {
      await _authService.sendEmail(email);
    } catch (e) {
      _errorMessage = e.toString();
    } finally {
      _setLoading(false);
    }
  }

  //Шаг 2 : Метод для проверки кода верификации
  Future<bool> checkCode(String email, String code) async {
    _setLoading(true);
    _errorMessage = null;
    try {
      await _authService.checkCode(email, code); // Отправляем код на сервер
      _setLoading(false);
      return true; // Успешная верификация
    } catch (e) {
      _errorMessage = e.toString();
      _setLoading(false);
      notifyListeners();
      return false; // Ошибка верификации
    }
  }

  //Последний шаг
  Future<bool> register(
      String name,
      String surname,
      String email,
      String password,
      String confirmPassword,
      String phoneNumber,
      String code
      ) async {
    _setLoading(true);

    if (password != confirmPassword) {
      _errorMessage = 'Passwords do not match';
      _setLoading(false);
      notifyListeners();
      return false;
    }

    try {
      await _authService.register(
        email: email,
        password: password,
        confirmPassword: confirmPassword,
        otp: code,
        surname: surname,
        name: name,
        phoneNumber: phoneNumber,
      );

      _setLoading(false);
      return true; // Успешная регистрация
    } catch (e) {
      _errorMessage = e.toString();
      _setLoading(false);
      notifyListeners();
      return false; // Ошибка регистрации
    }
  }


  // Метод для смены пароля
  Future<bool> changePassword(String newPassword, String confirmPassword) async {
    if (newPassword != confirmPassword) {
      _errorMessage = 'Passwords do not match';
      notifyListeners();
      return false;
    }

    _setLoading(true);
    _errorMessage = null;
    try {
      await _authService.changePassword(newPassword); // Запрос на сервер для смены пароля
      _setLoading(false);
      return true; // Успешная смена пароля
    } catch (e) {
      _errorMessage = e.toString();
      _setLoading(false);
      notifyListeners();
      return false;
    }
  }

// Метод для выхода из системы
  Future<void> logout() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? token = prefs.getString('auth_token');

    if (token != null && token.isNotEmpty) {
      try {
        await _authService.logout(); // Отправляем запрос на сервер
      } catch (e) {
        _errorMessage = e.toString();
        notifyListeners();
        return; // Прерываем выход, если запрос не удался
      }
    }

    // Удаляем токен и данные пользователя из локального хранилища
    await prefs.remove('auth_token');
    await prefs.remove('user_data');
    _user = null;
    notifyListeners();
  }

  void _setLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }

  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }
}
