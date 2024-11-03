class LocationModel {
  final String id;
  final double latitude;
  final double longitude;

  LocationModel({
    required this.id,
    required this.latitude,
    required this.longitude,
  });

  // Фабричный метод для создания LocationModel из JSON
  factory LocationModel.fromJson(Map<String, dynamic> json) {
    return LocationModel(
      id: json['id'] as String,
      latitude: json['latitude'] as double,
      longitude: json['longitude'] as double,
    );
  }

  // Метод для преобразования модели в JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'latitude': latitude,
      'longitude': longitude,
    };
  }
}
