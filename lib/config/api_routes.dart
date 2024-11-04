import 'config.dart';

class ApiRoutes {
  static const String add_request = '${Config.apiUrl}/add_request';

  // Роуты для авторизации
  static const String login = '${Config.apiUrl}/auth/login';
  static const String register = '${Config.apiUrl}/auth/register';
  static const String logout = '${Config.apiUrl}/auth/logout';
  static const String sendEmail = '${Config.apiUrl}/auth/send-email';
  static const String verifyCode = '${Config.apiUrl}/auth/verify-code';
  static const String changePassword = '${Config.apiUrl}/auth/change-password';
  static const String validateToken = '${Config.apiUrl}/auth/validate-token';
  static const String changeProfileData = '${Config.apiUrl}/auth/change-profile-data';


  // Другие роуты для данных
  //static const String userProfile = '${Config.apiUrl}/user/profile';
  static const String models = '${Config.apiUrl}/models';
  static const String flightSigns = '${Config.apiUrl}/flightSigns';
  static const String purposes = '${Config.apiUrl}/purposes';
  static const String regions = '${Config.apiUrl}/regions';
  static const String requests = '${Config.apiUrl}/requests';

  // Роуты для управления заявками
  static const String cancelRequest = '${Config.apiUrl}/cancel-request';
  static const String checkRequestStatus = '${Config.apiUrl}/check-request-status';
  static const String sendCodeAndGetStatus = '${Config.apiUrl}/send-code-and-get-status';




}
