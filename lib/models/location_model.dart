import 'package:safe_sky/models/user_model.dart';

class Location {
  final double latitude;
  final double longitude;
  final UserModel? user; // Опциональный пользователь

  Location({
    required this.latitude,
    required this.longitude,
    this.user,
  });

  // Фабричный метод для создания Location из JSON
  factory Location.fromJson(Map<String, dynamic> json) {
    return Location(
      latitude: json['latitude'],
      longitude: json['longitude'],
      user: json['user'] != null ? UserModel.fromJson(json['user']) : null,
    );
  }

  // Метод для преобразования модели в JSON
  Map<String, dynamic> toJson() {
    final data = {
      'latitude': latitude,
      'longitude': longitude,
    };
    // if (user != null) {
    //   data['user'] = user!.toJson();
    // }
    return data;
  }
}
