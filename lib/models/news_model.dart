class NewsModel {
  final String dateTime;
  final String shortDescription;
  final String imageUrl;
  final String description;
  final String lang; // Новый параметр для языка

  NewsModel({
    required this.dateTime,
    required this.shortDescription,
    required this.imageUrl,
    required this.description,
    required this.lang,
  });

  Map<String, dynamic> toJson() {
    return {
      'dateTime': dateTime,
      'shortDescription': shortDescription,
      'imageUrl': imageUrl,
      'description': description,
      'lang': lang,
    };
  }

  factory NewsModel.fromJson(Map<String, dynamic> json) {
    return NewsModel(
      dateTime: json['dateTime'],
      shortDescription: json['shortDescription'],
      imageUrl: json['imageUrl'],
      description: json['description'],
      lang: json['lang'],
    );
  }
}
