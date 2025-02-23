import 'package:safe_sky/models/request.dart';

class PrepareData {
  final List<Bpla> bplaList;
  final List<Operator> operatorList;
  final Permission? permission;
  final Agreement? agreement;
  final List<String> purposeList;
  final List<ZoneType> zoneTypeList;
  final String email; // Новое поле

  PrepareData({
    required this.bplaList,
    required this.operatorList,
    this.permission,
    this.agreement,
    required this.purposeList,
    required this.zoneTypeList,
    required this.email, // Добавлено в конструктор
  });

  factory PrepareData.fromJson(Map<String, dynamic> json) {
    return PrepareData(
      bplaList: json['bplaList'] != null
          ? (json['bplaList'] as List<dynamic>)
          .map((item) => Bpla.fromJson(item as Map<String, dynamic>))
          .toList()
          : [],
      operatorList: json['operatorList'] != null
          ? (json['operatorList'] as List<dynamic>)
          .map((item) => Operator.fromJson(item as Map<String, dynamic>))
          .toList()
          : [],
      permission: json['permission'] is Map<String, dynamic>
          ? Permission.fromJson(json['permission'] as Map<String, dynamic>)
          : null,
      agreement: json['agreement'] != null
          ? Agreement.fromJson(json['agreement'])
          : null,
      purposeList: (json['purposeList'] as List<dynamic>?)
          ?.map((e) => e.toString())
          .toList() ??
          [],
      zoneTypeList: json['zoneTypeList'] != null
          ? (json['zoneTypeList'] as List<dynamic>)
          .map((item) => ZoneType.fromJson(item as Map<String, dynamic>))
          .toList()
          : [],
      email: json['email'] ?? '', // Обработка email
    );
  }
}

class Agreement {
  final String docNum;
  final String docDate;

  Agreement({
    required this.docNum,
    required this.docDate,
  });

  factory Agreement.fromJson(Map<String, dynamic> json) {
    return Agreement(
      docNum: json['docNum'] ?? '',
      docDate: json['docDate'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'docNum': docNum,
      'docDate': docDate,
    };
  }
}

class ZoneType {
  final int id;
  final String name;

  ZoneType({required this.id, required this.name});

  factory ZoneType.fromJson(Map<String, dynamic> json) {
    return ZoneType(
      id: json['id'] ?? 0,
      name: json['name'] ?? '',
    );
  }
}
