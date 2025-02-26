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

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
          other is DistrictModel &&
              runtimeType == other.runtimeType &&
              code == other.code;

  @override
  int get hashCode => code.hashCode;
}
