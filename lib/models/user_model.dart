class UserModel {
  final int id;
  final String email;
  final String name;
  final String surname; // добавлено поле для фамилии
  final String phoneNumber; // добавлено поле для номера телефона
  final String token;

  UserModel({
    required this.id,
    required this.email,
    required this.name,
    required this.surname,
    required this.phoneNumber,
    required this.token,
  });

  // Фабричный метод для создания UserModel из JSON
  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['id'],
      email: json['email'],
      name: json['name'],
      surname: json['surname'], // обработка фамилии из JSON
      phoneNumber: json['phoneNumber'], // обработка номера телефона из JSON
      token: json['token'],
    );
  }

  // Метод для преобразования модели в JSON (если потребуется отправить данные)
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'email': email,
      'name': name,
      'surname': surname, // добавление фамилии в JSON
      'phoneNumber': phoneNumber, // добавление номера телефона в JSON
      'token': token,
    };
  }
}
