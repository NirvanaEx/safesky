class RequestModel {
  String? id;
  String? number;
  String? status;
  String? requesterName;
  String? operatorName;
  String? operatorPhone;
  String? email;
  String? permitNumber;
  String? contractNumber;
  String? note;
  String? model;
  String? region;
  String? purpose;
  String? flightSign;
  double? latitude;
  double? longitude;
  double? flightHeight; // Новый параметр
  double? radius;
  DateTime? startDate;
  DateTime? flightStartDateTime;
  DateTime? flightEndDateTime;
  DateTime? permitDate;
  DateTime? contractDate;
  String? lang;

  RequestModel({
    this.id,
    this.number,
    this.status,
    this.requesterName,
    this.operatorName,
    this.operatorPhone,
    this.email,
    this.permitNumber,
    this.contractNumber,
    this.note,
    this.model,
    this.region,
    this.purpose,
    this.flightSign,
    this.latitude,
    this.longitude,
    this.flightHeight, // Новый параметр
    this.radius,
    this.startDate,
    this.flightStartDateTime,
    this.flightEndDateTime,
    this.permitDate,
    this.contractDate,
    this.lang,
  });

  factory RequestModel.fromJson(Map<String, dynamic> json) {
    return RequestModel(
      id: json['id'],
      number: json['number'],
      status: json['status'],
      requesterName: json['requesterName'],
      operatorName: json['operatorName'],
      operatorPhone: json['operatorPhone'],
      email: json['email'],
      permitNumber: json['permitNumber'],
      contractNumber: json['contractNumber'],
      note: json['note'],
      model: json['model'],
      region: json['region'],
      purpose: json['purpose'],
      flightSign: json['flightSign'],
      latitude: json['latitude'] != null ? json['latitude'].toDouble() : null,
      longitude: json['longitude'] != null ? json['longitude'].toDouble() : null,
      flightHeight: json['flightHeight'] != null ? json['flightHeight'].toDouble() : null, // Новый параметр
      radius: json['radius'] != null ? json['radius'].toDouble() : null,
      startDate: json['startDate'] != null ? DateTime.parse(json['startDate']) : null,
      flightStartDateTime: json['flightStartDateTime'] != null ? DateTime.parse(json['flightStartDateTime']) : null,
      flightEndDateTime: json['flightEndDateTime'] != null ? DateTime.parse(json['flightEndDateTime']) : null,
      permitDate: json['permitDate'] != null ? DateTime.parse(json['permitDate']) : null,
      contractDate: json['contractDate'] != null ? DateTime.parse(json['contractDate']) : null,
      lang: json['lang'],
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'number': number,
    'status': status,
    'requesterName': requesterName,
    'operatorName': operatorName,
    'operatorPhone': operatorPhone,
    'email': email,
    'permitNumber': permitNumber,
    'contractNumber': contractNumber,
    'note': note,
    'model': model,
    'region': region,
    'purpose': purpose,
    'flightSign': flightSign,
    'latitude': latitude,
    'longitude': longitude,
    'flightHeight': flightHeight, // Новый параметр
    'radius': radius,
    'startDate': startDate?.toIso8601String(),
    'flightStartDateTime': flightStartDateTime?.toIso8601String(),
    'flightEndDateTime': flightEndDateTime?.toIso8601String(),
    'permitDate': permitDate?.toIso8601String(),
    'contractDate': contractDate?.toIso8601String(),
    'lang': lang,
  };
}
