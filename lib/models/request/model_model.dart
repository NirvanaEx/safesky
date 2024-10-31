class ModelModel {
  final int id;
  final String lang;
  final String name;

  ModelModel({required this.id, required this.lang, required this.name});

  factory ModelModel.fromJson(Map<String, dynamic> json) {
    return ModelModel(
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