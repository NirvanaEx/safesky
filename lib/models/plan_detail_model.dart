class PlanDetailModel {
  final int planId;
  final DateTime? planDate;
  final int? applicantId;
  final String? applicant;
  final int? applicationNum;
  final String? timeFrom;
  final String? timeTo;
  final String? regionCode;
  final String? region;
  final String? districtCode;
  final String? district;
  final String? flightArea;
  final int? zoneTypeId;
  final String? zoneType;
  final String? purpose;
  final List<OperatorModel> operatorList;
  final List<BplaModel> bplaList;
  final List<CoordModel> coordList;
  final String? operatorPhones;
  final String? email;
  final String? notes;
  final PermissionModel? permission;
  final AgreementModel? agreement;
  final String? source;
  final int? stateId;
  final String? state;
  final String? checkUrl;
  final String? cancelReason;
  final String? uuid;
  final int? execStateId;
  final String? execState;
  final int? activity;
  final int? mAltitude;   // высота, скорее всего в метрах
  final double? fAltitude; // высота в футах (к примеру)

  PlanDetailModel({
    required this.planId,
    this.planDate,
    this.applicantId,
    this.applicant,
    this.applicationNum,
    this.timeFrom,
    this.timeTo,
    this.regionCode,
    this.region,
    this.districtCode,
    this.district,
    this.flightArea,
    this.zoneTypeId,
    this.zoneType,
    this.purpose,
    required this.operatorList,
    required this.bplaList,
    required this.coordList,
    this.operatorPhones,
    this.email,
    this.notes,
    this.permission,
    this.agreement,
    this.source,
    this.stateId,
    this.state,
    this.checkUrl,
    this.cancelReason,
    this.uuid,
    this.execStateId,
    this.execState,
    this.activity,
    this.mAltitude,
    this.fAltitude,
  });

  factory PlanDetailModel.fromJson(Map<String, dynamic> json) {
    try {
      return PlanDetailModel(
        planId: json['planId'] as int,
        planDate: _tryParseDateTime(json['planDate']),
        applicantId: json['applicantId'] as int?,
        applicant: json['applicant'] as String?,
        applicationNum: json['applicationNum'] as int?,
        timeFrom: json['timeFrom'] as String?,
        timeTo: json['timeTo'] as String?,
        // Новые поля:
        regionCode: json['regionCode'] as String?,
        region: json['region'] as String?,
        districtCode: json['districtCode'] as String?,
        district: json['district'] as String?,
        flightArea: json['flightArea'] as String?,
        zoneTypeId: json['zoneTypeId'] as int?,
        zoneType: json['zoneType'] as String?,
        purpose: json['purpose'] as String?,
        operatorList: (json['operatorList'] as List?)
            ?.map((e) => OperatorModel.fromJson(e as Map<String, dynamic>))
            .toList() ?? [],
        bplaList: (json['bplaList'] as List?)
            ?.map((e) => BplaModel.fromJson(e as Map<String, dynamic>))
            .toList() ?? [],
        coordList: (json['coordList'] as List?)
            ?.map((e) => CoordModel.fromJson(e as Map<String, dynamic>))
            .toList() ?? [],
        operatorPhones: json['operatorPhones'] as String?,
        email: json['email'] as String?,
        notes: json['notes'] as String?,
        permission: json['permission'] is Map<String, dynamic>
            ? PermissionModel.fromJson(json['permission'])
            : null,
        // Обработка agreement: поддержка и Map, и String
        agreement: json['agreement'] is Map<String, dynamic>
            ? AgreementModel.fromJson(json['agreement'] as Map<String, dynamic>)
            : (json['agreement'] is String
            ? AgreementModel(docNum: json['agreement'] as String, docDate: null)
            : null),
        source: json['source'] as String?,
        stateId: json['stateId'] as int?,
        state: json['state'] as String?,
        checkUrl: json['checkUrl'] as String?,
        cancelReason: json['cancelReason'] as String?,
        uuid: json['uuid'] as String?,
        execStateId: json['execStateId'] as int?,
        execState: json['execState'] as String?,
        activity: json['activity'] as int?,
        mAltitude: json['mAltitude'] as int?,
        fAltitude: (json['fAltitude'] as num?)?.toDouble(),
      );
    } catch (e, stackTrace) {
      print('Error parsing PlanDetailModel: $e\n$stackTrace');
      throw Exception('Failed to parse PlanDetailModel');
    }
  }



  /// Пример метода для безопасного парсинга даты (может быть null или некорректной)
  static DateTime? _tryParseDateTime(dynamic value) {
    if (value == null) return null;
    try {
      return DateTime.parse(value as String);
    } catch (_) {
      return null;
    }
  }
}

class OperatorModel {
  final int id;
  final String? surname;
  final String? name;
  final String? patronymic;
  final String? phone;

  OperatorModel({
    required this.id,
    this.surname,
    this.name,
    this.patronymic,
    this.phone,
  });

  factory OperatorModel.fromJson(Map<String, dynamic> json) {
    return OperatorModel(
      id: json['id'] as int,
      surname: json['surname'] as String?,
      name: json['name'] as String?,
      patronymic: json['patronymic'] as String?,
      phone: json['phone'] as String?,
    );
  }
}

class BplaModel {
  final int id;
  final String? type;
  final String? name;
  final String? regnum;

  BplaModel({
    required this.id,
    this.type,
    this.name,
    this.regnum,
  });

  factory BplaModel.fromJson(Map<String, dynamic> json) {
    return BplaModel(
      id: json['id'] as int,
      type: json['type'] as String?,
      name: json['name'] as String?,
      regnum: json['regnum'] as String?,
    );
  }
}

class CoordModel {
  final String? latitude;
  final String? longitude;
  final int? radius;

  CoordModel({
    this.latitude,
    this.longitude,
    this.radius,
  });

  factory CoordModel.fromJson(Map<String, dynamic> json) {
    return CoordModel(
      latitude: json['latitude'] as String?,
      longitude: json['longitude'] as String?,
      radius: json['radius'] as int?,
    );
  }
}

class PermissionModel {
  final String? orgName;
  final String? docNum;
  final DateTime? docDate;

  PermissionModel({
    this.orgName,
    this.docNum,
    this.docDate,
  });

  factory PermissionModel.fromJson(Map<String, dynamic> json) {
    return PermissionModel(
      orgName: json['orgName'] as String?,
      docNum: json['docNum'] as String?,
      docDate: PlanDetailModel._tryParseDateTime(json['docDate']),
    );
  }
}

class AgreementModel {
  final String? docNum;
  final DateTime? docDate;

  AgreementModel({this.docNum, this.docDate});

  factory AgreementModel.fromJson(Map<String, dynamic> json) {
    return AgreementModel(
      docNum: json['docNum'] as String?,
      docDate: PlanDetailModel._tryParseDateTime(json['docDate']),
    );
  }
}
