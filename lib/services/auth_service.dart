import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../config/api_routes.dart';
import '../config/config.dart';
import '../models/user_model.dart';

class AuthService {
  final String _baseUrl = ApiRoutes.login; // Используем URL из ApiRoutes

  // Метод для входа пользователя
  Future<UserModel> login(String email, String password) async {
    //Заглушка
    await Future.delayed(Duration(seconds: 2));

    return UserModel(id: 1, email: 'email@gmail.com', name: 'Drake', surname: 'Brown', phoneNumber: '+998909883696', token: 'token_auth');
    final url = Uri.parse(_baseUrl);

    final response = await http.post(
      url,
      headers: {
        'Content-Type': 'application/json',
        'Authorization': Config.basicAuth, // Используем basicAuth
      },
      body: jsonEncode({'email': email, 'password': password}),
    );

    if (response.statusCode == 200) {
      // Парсим JSON в модель, включая новые поля
      return UserModel.fromJson(jsonDecode(response.body));
    } else {
      throw Exception('Failed to login');
    }
  }

  // Метод для проверки подлинности токена
  Future<bool> isTokenValid(String token) async {
    return true;

    final url = Uri.parse(ApiRoutes.validateToken);

    final response = await http.get(
      url,
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
    );

    if (response.statusCode == 200) {
      return true; // Токен действителен
    } else {
      return false; // Токен недействителен или истек
    }
  }

  // Метод для регистрации пользователя
  //Шаг 1
  Future<Map<String, dynamic>> sendEmail(String email) async {
    // Заменяем реальный HTTP-запрос на заглушку
    await Future.delayed(Duration(seconds: 2)); // Имитируем задержку сети

    // Возвращаем фиктивный ответ
    return {
      'status': 'success',
      'message': 'Verification email sent to $email'
    };


    final url = Uri.parse(ApiRoutes.sendEmail); // Для отправки email


    final response = await http.post(
      url,
      headers: {
        'Content-Type': 'application/json',
        'Authorization': Config.basicAuth,
      },
      body: jsonEncode({'email': email}),
    );

    if (response.statusCode == 200) {
      return jsonDecode(response.body); // Ожидаем ответ с 'status' и 'message'
    } else {
      throw Exception('Failed to send email');
    }
  }

  //Шаг 2
  Future<void> checkCode(String email, String code) async {
    // Имитация задержки, чтобы сделать поведение более реалистичным
    await Future.delayed(Duration(seconds: 2));

    // Имитация логики проверки кода
    if (code == "123456") { // Предполагаем, что "123456" — корректный код для теста
      // Успешная проверка, ничего не возвращаем
      return;
    } else {
      // Имитируем ошибку проверки
      throw Exception('Неверный код. Пожалуйста, попробуйте еще раз.');
    }

    final url = Uri.parse(ApiRoutes.verifyCode); // Для проверки кода

    final response = await http.post(
      url,
      headers: {
        'Content-Type': 'application/json',
        'Authorization': Config.basicAuth,
      },
      body: jsonEncode({'email': email, 'code': code}),
    );

    if (response.statusCode != 200) {
      final errorData = jsonDecode(response.body);
      throw Exception(errorData['message'] ?? 'Ошибка при проверке кода');
    }
  }


  //Последний шаг
  Future<UserModel> register(String email, String password, String name, String surname, String phoneNumber) async {
    // Имитация задержки для более реалистичного тестирования
    await Future.delayed(Duration(seconds: 2));

    // Возвращаем фиктивный экземпляр UserModel
    return UserModel(
      id: 1, // Предположительно ID, который бы вернул сервер
      email: email,
      name: name,
      surname: surname,
      phoneNumber: phoneNumber,
      token: 'fake_token_123', // Фиктивный токен для тестирования
    );

    final url = Uri.parse(ApiRoutes.register);

    final response = await http.post(
      url,
      headers: {
        'Content-Type': 'application/json',
        'Authorization': Config.basicAuth,
      },
      body: jsonEncode({
        'email': email,
        'password': password,
        'name': name,
        'surname': surname,
        'phoneNumber': phoneNumber,
      }),
    );

    if (response.statusCode == 200) {
      return UserModel.fromJson(jsonDecode(response.body));
    } else {
      throw Exception('Failed to register');
    }
  }

  Future<void> changeProfileData(String name, String surname, String phoneNumber) async {
    // Имитация задержки для эмуляции сети
    await Future.delayed(Duration(seconds: 2));
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? token = prefs.getString('auth_token');

    // URL для смены данных профиля
    final url = Uri.parse(ApiRoutes.changeProfileData);

    final response = await http.post(
      url,
      headers: {
        'Content-Type': 'application/json',
        'Authorization': Config.basicAuth, // Или 'Bearer {токен}' при использовании токенов доступа
      },
      body: jsonEncode({
        'name': name,
        'surname': surname,
        'phoneNumber': phoneNumber,
        'token': token,
      }),
    );


    // Проверка статуса ответа
    if (response.statusCode != 200) {
      final errorData = jsonDecode(response.body);
      throw Exception(errorData['message'] ?? 'Ошибка при изменении данных профиля');
    }
  }

  Future<void> changePassword(String newPassword) async {
    await Future.delayed(Duration(seconds: 2)); // Имитация задержки сети
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? token = prefs.getString('auth_token');

    // Имитация проверки длины пароля для успешного или неуспешного ответа
    if (newPassword.length >= 6) {
      // Успешная смена пароля — метод завершает работу без исключения
      return;
    } else {
      // Исключение, если пароль не соответствует требуемой длине
      throw Exception('Password must be at least 6 characters long');
    }

    final url = Uri.parse(ApiRoutes.changePassword); // URL для смены пароля

    final response = await http.post(
      url,
      headers: {
        'Content-Type': 'application/json',
        'Authorization': Config.basicAuth, // Или 'Bearer {токен}' при использовании токенов доступа
      },
      body: jsonEncode({
        'newPassword': newPassword, // Новый пароль
        'token': token,
      }),
    );

    if (response.statusCode != 200) {
      final errorData = jsonDecode(response.body);
      throw Exception(errorData['message'] ?? 'Ошибка при смене пароля');
    }
  }




  // Метод для выхода пользователя
  Future<void> logout(String token) async {

    final url = Uri.parse(ApiRoutes.logout);

    final response = await http.post(
      url,
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token', // Передаем токен в заголовке
      },
    );

    if (response.statusCode != 200) {
      throw Exception('Failed to logout');
    }
  }
}
