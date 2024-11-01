import 'config.dart';

class ApiRoutes {
  static const String add_request = '${Config.apiUrl}/add_request';

  // Роуты для авторизации
  static const String login = '${Config.apiUrl}/auth/login';
  static const String register = '${Config.apiUrl}/auth/register';
  static const String logout = '${Config.apiUrl}/auth/logout';
  static const String sendEmail = '${Config.apiUrl}/send-email';
  static const String verifyCode = '${Config.apiUrl}/verify-code';
  static const String changePassword = '${Config.apiUrl}/auth/change-password';
  static const String validateToken = '${Config.apiUrl}/auth/validate-token';

  // Другие роуты для данных
  static const String userProfile = '${Config.apiUrl}/user/profile';
  static const String models = '${Config.apiUrl}/models';
  static const String flightSigns = '${Config.apiUrl}/flightSigns';
  static const String purposes = '${Config.apiUrl}/purposes';
  static const String regions = '${Config.apiUrl}/regions';
  static const String fetch_requests = '${Config.apiUrl}/requests';
}
