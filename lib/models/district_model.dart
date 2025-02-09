class DistrictModel {
  final String code;
  final String name;

  DistrictModel({
    required this.code,
    required this.name,
  });

  factory DistrictModel.fromJson(Map<String, dynamic> json) {
    return DistrictModel(
      code: json['code'] as String,
      name: json['name'] as String,
    );
  }
}
