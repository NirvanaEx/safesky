class NotificationModel {
  final String dateTime;
  final String shortDescription;
  final String description;
  final String lang; // Новый параметр для языка

  NotificationModel({
    required this.dateTime,
    required this.shortDescription,
    required this.description,
    required this.lang,
  });

  Map<String, dynamic> toJson() {
    return {
      'dateTime': dateTime,
      'shortDescription': shortDescription,
      'description': description,
      'lang': lang,
    };
  }

  factory NotificationModel.fromJson(Map<String, dynamic> json) {
    return NotificationModel(
      dateTime: json['dateTime'],
      shortDescription: json['shortDescription'],
      description: json['description'],
      lang: json['lang'],
    );
  }
}
