import 'dart:convert';

class Config {
   static const String apiUrl = String.fromEnvironment(
     'API_URL',
     defaultValue: 'http://91.213.31.234:8898/bpla_mobile_service/api/v1/'
   );

   static const String apiMap = "831619ba-7e99-483b-8e59-9e885b6cd7d4";
}