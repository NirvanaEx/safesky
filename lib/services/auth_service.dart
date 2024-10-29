import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/user_model.dart';

class AuthService {
  final String _baseUrl = 'https://your-api-url.com/api';

  // Метод для входа пользователя
  Future<UserModel> login(String email, String password) async {

    return UserModel(id: 1, email: 'my@mail.com', name: 'Dias', token: 'token');
    final url = Uri.parse('$_baseUrl/login');

    final response = await http.post(
      url,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'email': email, 'password': password}),
    );

    if (response.statusCode == 200) {
      // Парсим JSON в модель
      return UserModel.fromJson(jsonDecode(response.body));
    } else {
      throw Exception('Failed to login');
    }
  }

  // Метод для регистрации пользователя
  Future<UserModel> register(String email, String password) async {
    final url = Uri.parse('$_baseUrl/register');

    final response = await http.post(
      url,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'email': email, 'password': password}),
    );

    if (response.statusCode == 200) {
      return UserModel.fromJson(jsonDecode(response.body));
    } else {
      throw Exception('Failed to register');
    }
  }

  // Метод для выхода пользователя
  Future<void> logout() async {
    final url = Uri.parse('$_baseUrl/logout');

    final response = await http.post(
      url,
      headers: {'Content-Type': 'application/json'},
    );

    if (response.statusCode != 200) {
      throw Exception('Failed to logout');
    }
  }
}
