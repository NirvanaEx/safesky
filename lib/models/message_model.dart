class Message {
  final String type; // 'text', 'image', 'file'
  final String content; // Текст сообщения или путь к файлу
  final bool isUser;
  String status; // 'pending', 'sent', 'read'
  final DateTime timestamp; // Время отправки сообщения

  Message({
    required this.type,
    required this.content,
    required this.isUser,
    this.status = 'pending',
    required this.timestamp, // Добавлено обязательное поле для времени
  });
}
