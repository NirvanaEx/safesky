import 'config.dart';

class ApiRoutes {
  // Роут для добавления заявки
  static const String add_request = '${Config.apiUrl}/add_request';

  // Роуты для авторизации
  static const String login = '${Config.apiUrl}/auth/login';
  static const String register = '${Config.apiUrl}/auth/register';

  // Пример других роутов, если потребуется
  static const String userProfile = '${Config.apiUrl}/user/profile';

  // Роуты для получения данных
  static const String models = '${Config.apiUrl}/models';
  static const String flightSigns = '${Config.apiUrl}/flightSigns';
  static const String purposes = '${Config.apiUrl}/purposes';
  static const String regions = '${Config.apiUrl}/regions';

  // Роут для получения всех заявок
  static const String fetch_requests = '${Config.apiUrl}/requests';
}
