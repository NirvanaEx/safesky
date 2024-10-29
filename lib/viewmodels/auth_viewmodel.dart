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
    try {
      _user = await _authService.login(email, password);

      // Сохраняем токен (предполагается, что он есть в модели пользователя или возвращаемом результате)
      SharedPreferences prefs = await SharedPreferences.getInstance();
      await prefs.setString('auth_token', _user?.token ?? ''); // Сохраняем токен пользователя
      _setLoading(false);
      return true; // Успешный вход
    } catch (e) {
      _errorMessage = e.toString();
      _setLoading(false);
      notifyListeners();
      return false; // Ошибка входа
    }
  }

  // Метод для проверки аутентификации
  Future<bool> isAuthenticated() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? token = prefs.getString('auth_token');
    return token != null && token.isNotEmpty;
  }

  // Метод для регистрации
  Future<UserModel?> register(String email, String password) async {
    _setLoading(true);
    try {
      _user = await _authService.register(email, password);

      // Сохраняем токен после регистрации
      SharedPreferences prefs = await SharedPreferences.getInstance();
      await prefs.setString('auth_token', _user?.token ?? ''); // Сохраняем токен
      _setLoading(false);
      return _user;
    } catch (e) {
      _errorMessage = e.toString();
      _setLoading(false);
      notifyListeners();
      return null;
    }
  }

  // Метод для выхода из системы
  Future<void> logout() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.remove('auth_token'); // Удаление токена или других данных
    _user = null; // Очистка данных пользователя
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
