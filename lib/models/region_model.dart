class RegionModel {
  final String code;
  final String name;

  RegionModel({
    required this.code,
    required this.name,
  });

  factory RegionModel.fromJson(Map<String, dynamic> json) {
    return RegionModel(
      code: json['code'] as String,
      name: json['name'] as String,
    );
  }
}
