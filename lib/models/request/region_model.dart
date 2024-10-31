class RegionModel {
  final int id;
  final String lang;
  final String name;

  RegionModel({required this.id, required this.lang, required this.name});

  factory RegionModel.fromJson(Map<String, dynamic> json) {
    return RegionModel(
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