class UserModel {
  final int id;
  final String email;
  final String name;
  final String surname; // добавлено поле для фамилии
  final String phoneNumber; // добавлено поле для номера телефона
  final int applicantId; // добавлено поле для идентификатора заявителя
  final String applicant; // добавлено поле для названия заявителя
  final String token;

  UserModel({
    required this.id,
    required this.email,
    required this.name,
    required this.surname,
    required this.phoneNumber,
    required this.applicantId,
    required this.applicant,
    required this.token,
  });

  // Фабричный метод для создания UserModel из JSON
  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['id'] ?? 0,
      email: json['email'] ?? '',
      name: json['name'] ?? '',
      surname: json['surname'] ?? '', // обработка фамилии из JSON
      phoneNumber: json['phoneNumber'] ?? '', // обработка номера телефона из JSON
      applicantId: json['applicantId'] ?? 0, // обработка ID заявителя из JSON
      applicant: json['applicant'] ?? '', // обработка названия заявителя из JSON
      token: json['token'] ?? '',
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
      'applicantId': applicantId, // добавление ID заявителя в JSON
      'applicant': applicant, // добавление названия заявителя в JSON
      'token': token,
    };
  }
}
