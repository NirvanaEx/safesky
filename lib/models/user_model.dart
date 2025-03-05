class UserModel {
  final int id;
  final String email;
  final String name;
  final String surname;
  final String patronymic; // Новое поле
  final String phoneNumber;
  final int applicantId;
  final String applicant;
  final String token;

  UserModel({
    required this.id,
    required this.email,
    required this.name,
    required this.surname,
    required this.patronymic, // Новое поле
    required this.phoneNumber,
    required this.applicantId,
    required this.applicant,
    required this.token,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['id'] ?? 0,
      email: json['email'] ?? '',
      name: json['name'] ?? '',
      surname: json['surname'] ?? '',
      patronymic: json['patronymic'] ?? '', // Добавляем отчество
      phoneNumber: json['phone'] ?? json['phoneNumber'] ?? '',
      applicantId: json['applicantId'] ?? 0,
      applicant: json['applicant'] ?? '',
      token: json['token'] ?? '',
    );
  }
  UserModel copyWith({
    String? name,
    String? surname,
    String? patronymic,
    String? phoneNumber,
  }) {
    return UserModel(
      id: id,
      email: email,
      name: name ?? this.name,
      surname: surname ?? this.surname,
      patronymic: patronymic ?? this.patronymic,
      phoneNumber: phoneNumber ?? this.phoneNumber,
      applicantId: applicantId,
      applicant: applicant,
      token: token,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'email': email,
      'name': name,
      'surname': surname,
      'patronymic': patronymic, // Добавление в JSON
      'phoneNumber': phoneNumber,
      'applicantId': applicantId,
      'applicant': applicant,
      'token': token,
    };
  }
}
