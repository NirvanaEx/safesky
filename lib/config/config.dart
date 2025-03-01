class Config {
  static const String apiUrl = String.fromEnvironment(
    'API_URL',
    defaultValue: 'http://91.213.31.234:8898/bpla_mobile_service/api/v1/',
  );
}
