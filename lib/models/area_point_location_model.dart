import 'location_model.dart';

class AreaPointLocationModel {
  final String? id; // Уникальный идентификатор для каждой зоны
  final String? tag; // Метка зоны, описывающая ее назначение или тип
  final List<LocationModel>? coordinates; // Список координат, описывающих границы зоны
  final double? latitude; // Центральная широта зоны
  final double? longitude; // Центральная долгота зоны
  final double? radius; // Радиус зоны (если координаты отсутствуют)

  AreaPointLocationModel({
    this.id,
    this.tag,
    this.coordinates,
    this.latitude,
    this.longitude,
    this.radius,
  });

  // Метод для преобразования объекта в JSON, исключая null-значения
  Map<String, dynamic> toJson() {
    return {
      if (id != null) 'id': id,
      if (tag != null) 'tag': tag,
      if (coordinates != null)
        'coordinates': coordinates!.map((location) => location.toJson()).toList(),
      if (latitude != null) 'latitude': latitude,
      if (longitude != null) 'longitude': longitude,
      if (radius != null) 'radius': radius,
    };
  }

  // Фабричный метод для создания объекта из JSON, с поддержкой отсутствующих полей
  factory AreaPointLocationModel.fromJson(Map<String, dynamic> json) {
    return AreaPointLocationModel(
      id: json['id'] as String?,
      tag: json['tag'] as String?,
      coordinates: json['coordinates'] != null
          ? (json['coordinates'] as List).map((item) => LocationModel.fromJson(item)).toList()
          : null,
      latitude: json['latitude'] as double?,
      longitude: json['longitude'] as double?,
      radius: json['radius'] as double?,
    );
  }
}
