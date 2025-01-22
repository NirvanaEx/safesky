import 'dart:convert';

class RequestModelMain {
  final int planId;
  final String applicationNum;
  final String planDate;
  final String timeFrom;
  final String timeTo;
  final int stateId;
  final String state;

  RequestModelMain({
    required this.planId,
    required this.applicationNum,
    required this.planDate,
    required this.timeFrom,
    required this.timeTo,
    required this.stateId,
    required this.state,
  });

  factory RequestModelMain.fromJson(Map<String, dynamic> json) {
    return RequestModelMain(
      planId: json['planId'],
      applicationNum: json['applicationNum'],
      planDate: json['planDate'],
      timeFrom: json['timeFrom'],
      timeTo: json['timeTo'],
      stateId: json['stateId'],
      state: utf8.decode(json['state'].toString().codeUnits),
    );
  }
}
