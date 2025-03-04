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
    _setLoading(true);
    notifyListeners();

    try {
      bool success = await _authService.login(email, password);
      if (success) {
        // Получение профиля сразу в виде UserModel
        _user = await _authService.getUserInfo();

        print('User info loaded: ${_user?.name} ${_user?.surname}'); // Лог данных
      }

      _setLoading(false);
      notifyListeners();
      return success;
    } catch (e) {
      _errorMessage = e is Exception ? e.toString() : 'Ошибка авторизации';
      print('Login error: $_errorMessage');
      _setLoading(false);
      notifyListeners();
      return false;
    }
  }

  // Метод для проверки аутентификации
  Future<bool> isAuthenticated() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? token = prefs.getString('auth_token');

    if (token == null || token.isEmpty) {
      return false; // Токена нет — пользователь не авторизован
    }

    // Используем сервис для проверки валидности токена
    bool tokenIsValid = await _authService.checkToken();
    if (!tokenIsValid) {
      await logout();
      return false;
    }

    try {
      // Если токен валидный — получаем информацию о пользователе
      _user = await _authService.getUserInfo();

      // Сохраняем данные пользователя для дальнейшего использования
      await prefs.setString('user_data', jsonEncode(_user!.toJson()));
      notifyListeners();
      return true;
    } catch (e) {
      print('Ошибка получения информации о пользователе: $e');
      await logout();
      return false;
    }
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
  Future<bool> changePassword(String oldPassword, String newPassword, String confirmPassword) async {
    if (newPassword != confirmPassword) {
      _errorMessage = 'Passwords do not match';
      notifyListeners();
      return false;
    }

    _setLoading(true);
    _errorMessage = null;
    try {
      await _authService.changePassword(oldPassword, newPassword, confirmPassword);
      _setLoading(false);
      return true; // Успешная смена пароля
    } catch (e) {
      _errorMessage = e.toString();
      _setLoading(false);
      notifyListeners();
      return false;
    }
  }
  void updateUser({
    required String name,
    required String surname,
    required String patronymic,
    required String phoneNumber,
  }) {
    if (_user != null) {
      _user = _user!.copyWith(
        name: name,
        surname: surname,
        patronymic: patronymic,
        phoneNumber: phoneNumber,
      );
      notifyListeners();
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
