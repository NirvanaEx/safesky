class NewsModel {
  final String id; // Добавленное поле id
  final String dateTime;
  final String shortDescription;
  final String imageUrl;
  final String description;
  final String lang;

  NewsModel({
    required this.id, // Инициализация id в конструкторе
    required this.dateTime,
    required this.shortDescription,
    required this.imageUrl,
    required this.description,
    required this.lang,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id, // Добавлено поле id для сериализации
      'dateTime': dateTime,
      'shortDescription': shortDescription,
      'imageUrl': imageUrl,
      'description': description,
      'lang': lang,
    };
  }

  factory NewsModel.fromJson(Map<String, dynamic> json) {
    return NewsModel(
      id: json['id'], // Инициализация id при десериализации
      dateTime: json['dateTime'],
      shortDescription: json['shortDescription'],
      imageUrl: json['imageUrl'],
      description: json['description'],
      lang: json['lang'],
    );
  }
}
