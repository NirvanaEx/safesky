import 'dart:convert';

class Config {
  static const String apiUrl = 'https://webhook.site/c68f5dbe-6d7a-470a-ad18-cfcd36b243f8';

  // Выделяем username и password отдельно
  static const String username = 'my_username';
  static const String password = 'my_password';

  // Создаем basicAuth, используя username и password
  static final String basicAuth = 'Basic ' + base64Encode(utf8.encode('$username:$password'));
}
