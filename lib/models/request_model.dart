class RequestModel {
  String? id; // Добавленное поле id
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
  String? flightSign; // Новое поле для знака полета
  double? latitude; // Поле для широты
  double? longitude; // Поле для долготы
  double? radius;
  DateTime? startDate; // Новое поле для даты начала
  DateTime? flightStartDateTime; // Новое поле для времени начала полета
  DateTime? flightEndDateTime; // Новое поле для времени окончания полета
  DateTime? permitDate; // Новое поле для даты разрешения
  DateTime? contractDate; // Новое поле для даты контракта
  String? lang; // Новое поле для языка (ru, en, uz)

  RequestModel({
    this.id,
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
      flightSign: json['flightSign'], // Добавлено поле знака полета
      latitude: json['latitude'] != null ? json['latitude'].toDouble() : null,
      longitude: json['longitude'] != null ? json['longitude'].toDouble() : null,
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
    'radius': radius,
    'startDate': startDate?.toIso8601String(),
    'flightStartDateTime': flightStartDateTime?.toIso8601String(),
    'flightEndDateTime': flightEndDateTime?.toIso8601String(),
    'permitDate': permitDate?.toIso8601String(),
    'contractDate': contractDate?.toIso8601String(),
    'lang': lang,
  };
}
