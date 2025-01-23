class BplaPlan {
  final int? planId;
  final String? planDate;
  final int? applicantId;
  final String? applicant;
  final String? applicationNum;
  final String? timeFrom;
  final String? timeTo;
  final String? flightArea;
  final int? zoneTypeId;
  final String? zoneType;
  final String? purpose;
  final List<Operator>? operatorList;
  final List<Bpla>? bplaList;
  final List<Coordinate>? coordList;
  final String? operatorPhones;
  final String? email;
  final String? notes;
  final Permission? permission;
  final String? agreement;
  final String? source;
  final int? stateId;
  final String? state;
  final String? checkUrl;
  final String? cancelReason;
  final String? uuid;
  final int? execStateId;
  final String? execState;
  final int? activity;
  final int? mAltitude;
  final double? fAltitude;

  BplaPlan({
    this.planId,
    this.planDate,
    this.applicantId,
    this.applicant,
    this.applicationNum,
    this.timeFrom,
    this.timeTo,
    this.flightArea,
    this.zoneTypeId,
    this.zoneType,
    this.purpose,
    this.operatorList,
    this.bplaList,
    this.coordList,
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

  factory BplaPlan.fromJson(Map<String, dynamic> json) {
    return BplaPlan(
      planId: json['planId'],
      planDate: json['planDate'],
      applicantId: json['applicantId'],
      applicant: json['applicant'],
      applicationNum: json['applicationNum'],
      timeFrom: json['timeFrom'],
      timeTo: json['timeTo'],
      flightArea: json['flightArea'],
      zoneTypeId: json['zoneTypeId'],
      zoneType: json['zoneType'],
      purpose: json['purpose'],
      operatorList: (json['operatorList'] as List?)?.map((e) => Operator.fromJson(e)).toList(),
      bplaList: (json['bplaList'] as List?)?.map((e) => Bpla.fromJson(e)).toList(),
      coordList: (json['coordList'] as List?)?.map((e) => Coordinate.fromJson(e)).toList(),
      operatorPhones: json['operatorPhones'],
      email: json['email'],
      notes: json['notes'],
      permission: json['permission'] != null ? Permission.fromJson(json['permission']) : null,
      agreement: json['agreement'],
      source: json['source'],
      stateId: json['stateId'],
      state: json['state'],
      checkUrl: json['checkUrl'],
      cancelReason: json['cancelReason'],
      uuid: json['uuid'],
      execStateId: json['execStateId'],
      execState: json['execState'],
      activity: json['activity'],
      mAltitude: json['mAltitude'],
      fAltitude: (json['fAltitude'] as num?)?.toDouble(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'planId': planId,
      'planDate': planDate,
      'applicantId': applicantId,
      'applicant': applicant,
      'applicationNum': applicationNum,
      'timeFrom': timeFrom,
      'timeTo': timeTo,
      'flightArea': flightArea,
      'zoneTypeId': zoneTypeId,
      'zoneType': zoneType,
      'purpose': purpose,
      'operatorList': operatorList?.map((e) => e.toJson()).toList(),
      'bplaList': bplaList?.map((e) => e.toJson()).toList(),
      'coordList': coordList?.map((e) => e.toJson()).toList(),
      'operatorPhones': operatorPhones,
      'email': email,
      'notes': notes,
      'permission': permission?.toJson(),
      'agreement': agreement,
      'source': source,
      'stateId': stateId,
      'state': state,
      'checkUrl': checkUrl,
      'cancelReason': cancelReason,
      'uuid': uuid,
      'execStateId': execStateId,
      'execState': execState,
      'activity': activity,
      'mAltitude': mAltitude,
      'fAltitude': fAltitude,
    };
  }
}

class Operator {
  final int? id;
  final String? surname;
  final String? name;
  final String? patronymic;
  final String? phone;

  Operator({
    this.id,
    this.surname,
    this.name,
    this.patronymic,
    this.phone,
  });

  factory Operator.fromJson(Map<String, dynamic> json) {
    return Operator(
      id: json['id'],
      surname: json['surname'],
      name: json['name'],
      patronymic: json['patronymic'],
      phone: json['phone'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'surname': surname,
      'name': name,
      'patronymic': patronymic,
      'phone': phone,
    };
  }
}

class Bpla {
  final int? id;
  final String? type;
  final String? name;
  final String? regnum;

  Bpla({
    this.id,
    this.type,
    this.name,
    this.regnum,
  });

  factory Bpla.fromJson(Map<String, dynamic> json) {
    return Bpla(
      id: json['id'],
      type: json['type'] ?? '',
      name: json['name'] ?? 'Unnamed BPLA',  // Устанавливаем значение по умолчанию
      regnum: json['regnum'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'type': type,
      'name': name,
      'regnum': regnum,
    };
  }
}

class Coordinate {
  final String? latitude;
  final String? longitude;
  final int? radius;

  Coordinate({
    this.latitude,
    this.longitude,
    this.radius,
  });

  factory Coordinate.fromJson(Map<String, dynamic> json) {
    return Coordinate(
      latitude: json['latitude'],
      longitude: json['longitude'],
      radius: json['radius'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'latitude': latitude,
      'longitude': longitude,
      'radius': radius,
    };
  }
}

class Permission {
  final String? orgName;
  final String? docNum;
  final String? docDate;

  Permission({
    this.orgName,
    this.docNum,
    this.docDate,
  });

  factory Permission.fromJson(Map<String, dynamic> json) {
    return Permission(
      orgName: json['orgName'],
      docNum: json['docNum'],
      docDate: json['docDate'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'orgName': orgName,
      'docNum': docNum,
      'docDate': docDate,
    };
  }
}
