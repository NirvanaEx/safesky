class UserModel {
  final int id;
  final String email;
  final String name;
  final String token;

  UserModel({
    required this.id,
    required this.email,
    required this.name,
    required this.token,
  });

  // Фабричный метод для создания UserModel из JSON
  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['id'],
      email: json['email'],
      name: json['name'],
      token: json['token'],
    );
  }

  // Метод для преобразования модели в JSON (если потребуется отправить данные)
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'email': email,
      'name': name,
      'token': token,
    };
  }
}
