class FlightSignModel {
  final int id;
  final String lang;
  final String name;

  FlightSignModel({required this.id, required this.lang, required this.name});

  factory FlightSignModel.fromJson(Map<String, dynamic> json) {
    return FlightSignModel(
      id: json['id'],
      lang: json['lang'],
      name: json['name'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'lang': lang,
      'name': name,
    };
  }
}