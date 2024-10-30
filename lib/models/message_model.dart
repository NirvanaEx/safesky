class Message {
  final String id; // Добавленное поле id
  final String type; // 'text', 'image', 'file'
  final String content; // Текст сообщения или путь к файлу
  final bool isUser;
  String status; // 'pending', 'sent', 'read'
  final DateTime timestamp; // Время отправки сообщения

  Message({
    required this.id, // Инициализация id в конструкторе
    required this.type,
    required this.content,
    required this.isUser,
    this.status = 'pending',
    required this.timestamp,
  });

  // Преобразование в JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'type': type,
      'content': content,
      'isUser': isUser,
      'status': status,
      'timestamp': timestamp.toIso8601String(),
    };
  }

  // Создание объекта из JSON
  factory Message.fromJson(Map<String, dynamic> json) {
    return Message(
      id: json['id'],
      type: json['type'],
      content: json['content'],
      isUser: json['isUser'],
      status: json['status'] ?? 'pending',
      timestamp: DateTime.parse(json['timestamp']),
    );
  }
}
