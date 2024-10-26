import 'package:flutter/material.dart';
import '../services/auth_service.dart';

class AuthViewModel extends ChangeNotifier {
  final AuthService _authService = AuthService();

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  String? _errorMessage;
  String? get errorMessage => _errorMessage;

  // Метод для авторизации
  Future<void> login(String email, String password) async {
    _setLoading(true);
    try {
      await _authService.login(email, password);
      _setLoading(false);
      // Обработка успешного логина (перенаправление на другой экран и т.д.)
    } catch (e) {
      _errorMessage = e.toString();
      _setLoading(false);
      notifyListeners();
    }
  }

  // Метод для регистрации
  Future<void> register(String email, String password) async {
    _setLoading(true);
    try {
      await _authService.register(email, password);
      _setLoading(false);
      // Обработка успешной регистрации
    } catch (e) {
      _errorMessage = e.toString();
      _setLoading(false);
      notifyListeners();
    }
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
