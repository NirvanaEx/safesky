import 'location_model.dart';

class LocationShareModel {
  final String? id;
  final String client;
  final LocationModel location;

  LocationShareModel({
    this.id,
    required this.client,
    required this.location,
  });

  // Фабричный метод для создания LocationShareModel из JSON
  factory LocationShareModel.fromJson(Map<String, dynamic> json) {
    return LocationShareModel(
      id: json['id'] as String?,
      client: json['client'] as String,
      location: LocationModel.fromJson(json['location'] as Map<String, dynamic>),
    );
  }

  // Метод для преобразования модели в JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'client': client,
      'location': location.toJson(),
    };
  }
}
