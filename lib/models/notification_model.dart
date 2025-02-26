class NotificationModel {
  final String id; // Добавленное поле id
  final String dateTime;
  final String shortDescription;
  final String description;
  final String lang;

  NotificationModel({
    required this.id, // Инициализация id в конструкторе
    required this.dateTime,
    required this.shortDescription,
    required this.description,
    required this.lang,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id, // Добавлено поле id для сериализации
      'dateTime': dateTime,
      'shortDescription': shortDescription,
      'description': description,
      'lang': lang,
    };
  }

  factory NotificationModel.fromJson(Map<String, dynamic> json) {
    return NotificationModel(
      id: json['id'], // Инициализация id при десериализации
      dateTime: json['dateTime'],
      shortDescription: json['shortDescription'],
      description: json['description'],
      lang: json['lang'],
    );
  }
}
