class StatusModel {
  final String id;
  final String status;
  final String message;

  StatusModel({required this.id, required this.status, required this.message});

  factory StatusModel.fromJson(Map<String, dynamic> json) {
    return StatusModel(
      id: json['id'],
      status: json['status'],
      message: json['message'],
    );
  }
}
