import 'dart:async';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../config/api_routes.dart';
import '../models/user_model.dart';
import '../views/my_custom_views/my_custom_dialog.dart';
import 'notification_service.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class AuthService {
  /// Метод для входа пользователя
  Future<bool> login(String username, String password) async {
    final url = Uri.parse(ApiRoutes.login);

    try {
      final response = await http.post(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
        body: jsonEncode({'username': username, 'password': password}),
      );

      // Декодирование ответа в правильной кодировке UTF-8
      final String responseBody = utf8.decode(response.bodyBytes);
      final Map<String, dynamic> responseData = jsonDecode(responseBody);

      print('Server response: $responseData');

      if (response.statusCode == 200) {
        SharedPreferences prefs = await SharedPreferences.getInstance();
        await prefs.setString('auth_token', responseData['token']);
        await prefs.setString('token_expire_at', responseData['expireAt']);
        await prefs.setString('refresh_token', responseData['refreshToken']);

        print('Token saved: ${responseData['token']}');
        print('Refresh token saved: ${responseData['refreshToken']}');

        // Запускаем таймер для уведомления и автоматического выхода при истечении токена
        _startTokenExpirationTimer(responseData['expireAt']);
        return true;
      } else {
        print('Login error: ${responseData['message']}');
        throw Exception(responseData['message'] ?? 'Ошибка при входе');
      }
    } catch (e) {
      print('Network error occurred: $e');
      throw Exception('Не удалось подключиться к серверу: $e');
    }
  }

  /// Метод обновления токена с использованием refresh_token
  Future<bool> tokenRefresh() async {
    final url = Uri.parse(ApiRoutes.refreshToken);
    SharedPreferences prefs = await SharedPreferences.getInstance();
    final String? refreshToken = prefs.getString('refresh_token');

    if (refreshToken == null) {
      print('Refresh token отсутствует, выполняем выход');
      await logout();
      return false;
    }

    try {
      final response = await http.post(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
        body: jsonEncode({'refresh_token': refreshToken}),
      );

      final String responseBody = utf8.decode(response.bodyBytes);

      if (response.statusCode == 200) {
        final Map<String, dynamic> responseData = jsonDecode(responseBody);
        await prefs.setString('auth_token', responseData['token']);
        await prefs.setString('refresh_token', responseData['refresh_token']);
        await prefs.setString('token_expire_at', responseData['expireAt']);

        print('Токен успешно обновлён: ${responseData['token']}');
        // Перезапускаем таймер истечения токена
        _startTokenExpirationTimer(responseData['expireAt']);
        return true;
      } else if (response.statusCode == 401) {
        print('Refresh token недействителен или истёк, выполняем выход');
        await logout();
        return false;
      } else {
        print('Ошибка обновления токена, код ответа: ${response.statusCode}');
        return false;
      }
    } catch (e) {
      print('Ошибка при обновлении токена: $e');
      return false;
    }
  }

  /// Универсальная обёртка для запросов, требующих авторизации.
  /// Если сервер отвечает 401, производится попытка обновить токен и повторить запрос.
  Future<http.Response> _makeAuthorizedRequest(
      Future<http.Response> Function(String token) requestFunc) async {
    String? token = await _getToken();
    if (token == null) {
      throw Exception("Authorization token is missing");
    }
    var response = await requestFunc(token);
    if (response.statusCode == 401) {
      bool refreshed = await tokenRefresh();
      if (!refreshed) {
        throw Exception('Unauthorized and failed to refresh token');
      }
      token = await _getToken();
      if (token == null) {
        throw Exception('Token is null after refresh');
      }
      response = await requestFunc(token);
    }
    return response;
  }

  /// Запуск таймера для предварительного уведомления об истечении токена
  void _startTokenExpirationTimer(String expireAtString) {
    final expireAt = DateTime.parse(expireAtString);
    final duration = expireAt.difference(DateTime.now());
    // Предупреждение за 5 минут до истечения токена
    final preExpirationTime = Duration(minutes: 5);

    if (duration > preExpirationTime) {
      Timer(duration - preExpirationTime, () {
        NotificationService.showTokenExpirationNotification();
        final context = NotificationService.navigatorKey.currentContext;
        if (context != null) {
          final localizations = AppLocalizations.of(context)!;
          MyCustomDialog.showNotificationDialog(
              context,
              localizations.tokenPreExpirationTitle,
              localizations.tokenPreExpirationMessage);
        }
      });
    }

    Timer(duration, () async {
      await NotificationService.showTokenExpirationNotification(isFinal: true);
      await logout();
      NotificationService.navigatorKey.currentState
          ?.pushNamedAndRemoveUntil('/login', (route) => false);
    });
  }

  /// Метод для отправки email
  Future<Map<String, dynamic>> sendEmail(String username) async {
    final url = Uri.parse(ApiRoutes.sendEmail);

    try {
      final response = await http.post(
        url,
        headers: {
          'Content-Type': 'application/json',
        },
        body: jsonEncode({'username': username}),
      );

      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        final errorData = jsonDecode(response.body);
        throw Exception(errorData['message'] ?? 'Failed to send email');
      }
    } catch (e) {
      throw Exception('Не удалось подключиться к серверу: $e');
    }
  }

  /// Метод для регистрации пользователя
  Future<void> register({
    required String email,
    required String password,
    required String confirmPassword,
    required String otp,
    required String surname,
    required String name,
    required String phoneNumber,
  }) async {
    final url = Uri.parse(ApiRoutes.register);

    try {
      final response = await http.post(
        url,
        headers: {
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          'username': email,
          'password': password,
          'passwordConfirm': confirmPassword,
          'otp': otp,
          'surname': surname,
          'name': name,
          'phone': phoneNumber,
        }),
      );

      final String responseBody = utf8.decode(response.bodyBytes);

      if (response.statusCode == 200) {
        print('Registration successful');
      } else {
        final Map<String, dynamic> errorResponse = jsonDecode(responseBody);
        print('Server error: ${errorResponse['message']}');
        throw Exception('Failed to register: ${errorResponse['message']}');
      }
    } catch (e) {
      print('Network error occurred: $e');
      throw Exception('Network error: ${e.toString()}');
    }
  }

  /// Получение информации о пользователе с автоматическим обновлением токена при необходимости
  Future<UserModel> getUserInfo() async {
    final response = await _makeAuthorizedRequest((token) async {
      return await http.get(
        Uri.parse(ApiRoutes.userInfo),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );
    });

    final String responseBody = utf8.decode(response.bodyBytes);
    if (response.statusCode == 200) {
      final Map<String, dynamic> jsonData = jsonDecode(responseBody);
      UserModel user = UserModel.fromJson({
        'id': jsonData['id'],
        'email': jsonData['email'],
        'name': jsonData['name'],
        'surname': jsonData['surname'],
        'phoneNumber': jsonData['phone'],
        'applicantId': jsonData['applicantId'],
        'applicant': jsonData['applicant'],
        'token': await _getToken(),
      });

      SharedPreferences prefs = await SharedPreferences.getInstance();
      await prefs.setString('applicant', user.applicant);
      await prefs.setInt('userId', user.id);

      print('USER ID: ${user.id}');
      return user;
    } else {
      final Map<String, dynamic> errorResponse = jsonDecode(responseBody);
      throw Exception(errorResponse['message'] ?? 'Ошибка получения профиля');
    }
  }

  /// Получение текущего auth_token из SharedPreferences
  Future<String?> _getToken() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getString('auth_token');
  }

  /// Проверка валидности токена с автоматическим обновлением при необходимости
  Future<bool> checkToken() async {
    try {
      final response = await _makeAuthorizedRequest((token) async {
        return await http.get(
          Uri.parse(ApiRoutes.checkToken),
          headers: {
            'Authorization': 'Bearer $token',
          },
        );
      });
      return response.statusCode == 200;
    } catch (e) {
      return false;
    }
  }

  /// Изменение данных профиля с автоматическим обновлением токена при необходимости
  Future<void> changeProfileData(String name, String surname, String phone) async {
    final response = await _makeAuthorizedRequest((token) async {
      return await http.post(
        Uri.parse(ApiRoutes.changeProfileData),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode({
          'surname': surname,
          'name': name,
          'phone': phone,
        }),
      );
    });

    if (response.statusCode != 200) {
      final errorData = jsonDecode(utf8.decode(response.bodyBytes));
      throw Exception(errorData['message'] ?? 'Failed to update profile data');
    }
  }

  /// Изменение пароля с автоматическим обновлением токена при необходимости.
  /// После успешного изменения пароля производится выход из аккаунта.
  Future<void> changePassword(
      String oldPassword, String newPassword, String passwordConfirm) async {
    final response = await _makeAuthorizedRequest((token) async {
      return await http.post(
        Uri.parse(ApiRoutes.changePassword),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode({
          'oldPassword': oldPassword,
          'password': newPassword,
          'passwordConfirm': passwordConfirm,
        }),
      );
    });

    if (response.statusCode != 200) {
      final errorData = jsonDecode(utf8.decode(response.bodyBytes));
      throw Exception(errorData['message'] ?? 'Failed to change password');
    }
    await logout();
  }

  /// Выход из аккаунта – удаление токенов и связанных данных из SharedPreferences
  Future<void> logout() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.remove('auth_token');
    await prefs.remove('refresh_token');
    await prefs.remove('token_expire_at');
  }
}
