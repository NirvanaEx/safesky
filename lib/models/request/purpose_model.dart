class PurposeModel {
  final int id;
  final String lang;
  final String name;

  PurposeModel({required this.id, required this.lang, required this.name});

  factory PurposeModel.fromJson(Map<String, dynamic> json) {
    return PurposeModel(
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