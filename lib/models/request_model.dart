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
  String? coordinates;
  double? radius;

  RequestModel({
    this.id, // Инициализация id в конструкторе
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
    this.coordinates,
    this.radius,
  });

  factory RequestModel.fromJson(Map<String, dynamic> json) {
    return RequestModel(
      id: json['id'], // Инициализация id при десериализации
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
      coordinates: json['coordinates'],
      radius: json['radius'] != null ? json['radius'].toDouble() : null,
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id, // Добавлено поле id для сериализации
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
    'coordinates': coordinates,
    'radius': radius,
  };
}
