class RequestModel {
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
