import 'dart:convert';
import 'package:http/http.dart' as http;

class AuthService {
  final String _baseUrl = 'https://your-api-url.com/api'; // Замените на ваш URL API

  // Метод для входа пользователя
  Future<Map<String, dynamic>> login(String email, String password) async {
    final url = Uri.parse('$_baseUrl/login');

    final response = await http.post(
      url,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'email': email, 'password': password}),
    );

    if (response.statusCode == 200) {
      // Если успешный запрос, возвращаем данные
      return jsonDecode(response.body);
    } else {
      // Если ошибка, генерируем исключение
      throw Exception('Failed to login');
    }
  }

  // Метод для регистрации пользователя
  Future<Map<String, dynamic>> register(String email, String password) async {
    final url = Uri.parse('$_baseUrl/register');

    final response = await http.post(
      url,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'email': email, 'password': password}),
    );

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
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
