import 'config.dart';

class ApiRoutes {
  static const String add_request = '${Config.apiUrl}/add_request';

  // Роуты для авторизации
  static const String login = '${Config.apiUrl}/auth/login';
  static const String register = '${Config.apiUrl}/auth/reg';
  static const String sendEmail = '${Config.apiUrl}/auth/otp';

  static const String userInfo = '${Config.apiUrl}/profile/info';



  static const String requestList = '${Config.apiUrl}/bpla/plan/list';
  static const String requestPrepare = '${Config.apiUrl}/bpla/plan/prepare';

  static const String requestCreate = '${Config.apiUrl}/bpla/plan/create';
  static const String requestDetailInfo = '${Config.apiUrl}/bpla/plan/';



  static const String verifyCode = '${Config.apiUrl}/auth/verify-code';


  static const String logout = '${Config.apiUrl}/auth/logout';

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

  // Трасляция местоположение
  static const String updateLocation = '${Config.apiUrl}/location/update';

}
