import 'area_point_location_model.dart';

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
  double? flightHeight; // Новый параметр
  DateTime? startDate;
  DateTime? flightStartDateTime;
  DateTime? flightEndDateTime;
  DateTime? permitDate;
  DateTime? contractDate;
  List<AreaPointLocationModel>? area;
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
    this.flightHeight,
    this.startDate,
    this.flightStartDateTime,
    this.flightEndDateTime,
    this.permitDate,
    this.contractDate,
    this.area,
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
      flightHeight: json['flightHeight'] != null ? json['flightHeight'].toDouble() : null,
      startDate: json['startDate'] != null ? DateTime.parse(json['startDate']) : null,
      flightStartDateTime: json['flightStartDateTime'] != null ? DateTime.parse(json['flightStartDateTime']) : null,
      flightEndDateTime: json['flightEndDateTime'] != null ? DateTime.parse(json['flightEndDateTime']) : null,
      permitDate: json['permitDate'] != null ? DateTime.parse(json['permitDate']) : null,
      contractDate: json['contractDate'] != null ? DateTime.parse(json['contractDate']) : null,
      area: json['area'] != null
          ? (json['area'] as List).map((item) => AreaPointLocationModel.fromJson(item)).toList()
          : null,
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
    'flightHeight': flightHeight, // Новый параметр
    'startDate': startDate?.toIso8601String(),
    'flightStartDateTime': flightStartDateTime?.toIso8601String(),
    'flightEndDateTime': flightEndDateTime?.toIso8601String(),
    'permitDate': permitDate?.toIso8601String(),
    'contractDate': contractDate?.toIso8601String(),
    'area': area?.map((item) => item.toJson()).toList(),
    'lang': lang,
  };
}
