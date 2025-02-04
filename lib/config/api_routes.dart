import 'config.dart';

class ApiRoutes {
  static const String add_request = '${Config.apiUrl}/add_request';

  // Роуты для авторизации
  static const String login = '${Config.apiUrl}/auth/login';
  static const String register = '${Config.apiUrl}/auth/reg';
  static const String sendEmail = '${Config.apiUrl}/auth/otp';

  static const String userInfo = '${Config.apiUrl}/profile/info';
  static const String checkToken = '${Config.apiUrl}/profile/check_token';
  static const String changeProfileData = '${Config.apiUrl}/profile/info';
  static const String changePassword = '${Config.apiUrl}/profile/change_password';



  static const String requestList = '${Config.apiUrl}/bpla/plan/list';
  static const String requestPrepare = '${Config.apiUrl}/bpla/plan/prepare';

  static const String requestCreate = '${Config.apiUrl}/bpla/plan/create';
  static const String requestDetailInfo = '${Config.apiUrl}/bpla/plan/';
  static const String requestDetailInfoByUuid = '${Config.apiUrl}/bpla/plan/uuid/';

  static const String requestCancel = '${Config.apiUrl}/bpla/plan';
  static const String requestDelete = '${Config.apiUrl}/bpla/plan';


  // Трасляция местоположение
  static const String updateLocation = '${Config.apiUrl}/bpla/operator/track';
  static const String pauseLocation = '${Config.apiUrl}/bpla/operator/pause';
  static const String stopLocation = '${Config.apiUrl}/bpla/operator/stop';





  static const String logout = '${Config.apiUrl}/auth/logout';






}
