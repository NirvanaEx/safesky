import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class ProfileView extends StatefulWidget {
  @override
  _ProfileViewState createState() => _ProfileViewState();
}

class _ProfileViewState extends State<ProfileView> {
  final _nameController = TextEditingController(text: "John");
  final _surnameController = TextEditingController(text: "Doe");
  final _phoneController = TextEditingController(text: "");

  @override
  void initState() {
    super.initState();
    _phoneController.text = formatPhoneNumber("+998 99 333 11 22");
  }

  // Метод для форматирования номера телефона (отделение кода страны)
  String formatPhoneNumber(String phoneNumber) {
    final countryCode = '+998';
    if (phoneNumber.startsWith(countryCode)) {
      return phoneNumber.replaceFirst(countryCode, '').trim();
    }
    return phoneNumber;
  }

  @override
  Widget build(BuildContext context) {
    final localizations = AppLocalizations.of(context)!;

    return Scaffold(
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 40.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Text(
                localizations.profile,
                style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
              ),
            ),
            SizedBox(height: 30),
            _buildLabel(localizations.name),
            _buildTextField(_nameController, hintText: localizations.name),
            SizedBox(height: 16),
            _buildLabel(localizations.surname),
            _buildTextField(_surnameController, hintText: localizations.surname),
            SizedBox(height: 16),
            _buildLabel(localizations.phone),
            _buildPhoneField(),
            SizedBox(height: 16),
            _buildLabel(localizations.password),
            _buildPasswordField(),
            SizedBox(height: 20),
            TextButton(
              onPressed: () => _showChangePasswordDialog(context),
              child: Text(
                localizations.changePassword,
                style: TextStyle(color: Colors.blue, fontSize: 16),
              ),
            ),
            SizedBox(height: 20),
            Center(
              child: ElevatedButton(
                onPressed: () {
                  // Логика для сохранения профиля
                },
                style: ElevatedButton.styleFrom(
                  primary: Colors.black,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30),
                  ),
                  padding: EdgeInsets.symmetric(horizontal: 100, vertical: 16),
                  minimumSize: Size(double.infinity, 48),
                ),
                child: Text(localizations.save, style: TextStyle(fontSize: 16)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Метод для отображения метки
  Widget _buildLabel(String label) {
    return Text(
      label,
      style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.black),
    );
  }

  // Метод для текстовых полей
  Widget _buildTextField(TextEditingController controller, {required String hintText}) {
    return TextField(
      controller: controller,
      decoration: InputDecoration(
        hintText: hintText,
        filled: true,
        fillColor: Colors.grey[200],
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(30),
          borderSide: BorderSide.none,
        ),
        contentPadding: EdgeInsets.symmetric(horizontal: 20, vertical: 15),
      ),
    );
  }

  // Метод для поля с телефоном
  Widget _buildPhoneField() {
    final localizations = AppLocalizations.of(context)!;

    return Container(
      decoration: BoxDecoration(
        color: Colors.grey[200],
        borderRadius: BorderRadius.circular(30),
      ),
      padding: EdgeInsets.symmetric(horizontal: 10),
      child: Row(
        children: [
          SizedBox(width: 8),
          Text("🇺🇿", style: TextStyle(fontSize: 18)),
          SizedBox(width: 8),
          Text("+998", style: TextStyle(fontSize: 16, color: Colors.black)),
          Expanded(
            child: TextField(
              controller: _phoneController,
              keyboardType: TextInputType.phone,
              decoration: InputDecoration(
                border: InputBorder.none,
                hintText: localizations.phone,
                contentPadding: EdgeInsets.symmetric(horizontal: 10, vertical: 18),
              ),
              style: TextStyle(fontSize: 16),
            ),
          ),
        ],
      ),
    );
  }

  // Метод для поля пароля (нередактируемое)
  Widget _buildPasswordField() {
    return TextField(
      obscureText: true,
      enableSuggestions: false,
      autocorrect: false,
      readOnly: true,
      decoration: InputDecoration(
        hintText: "**********", // 10 звездочек
        filled: true,
        fillColor: Colors.grey[200],
        prefixIcon: Icon(Icons.lock, color: Colors.grey),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(30),
          borderSide: BorderSide.none,
        ),
        contentPadding: EdgeInsets.symmetric(horizontal: 20, vertical: 15),
      ),
    );
  }

  // Метод для отображения диалогового окна смены пароля
  void _showChangePasswordDialog(BuildContext context) {
    final localizations = AppLocalizations.of(context)!;

    showDialog(
      context: context,
      builder: (BuildContext context) {
        final newPasswordController = TextEditingController();
        final confirmPasswordController = TextEditingController();
        bool isPasswordVisible = false;

        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),
              contentPadding: EdgeInsets.all(20),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    localizations.changePassword,
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  SizedBox(height: 20),
                  TextField(
                    controller: newPasswordController,
                    obscureText: !isPasswordVisible,
                    decoration: InputDecoration(
                      hintText: localizations.newPassword,
                      filled: true,
                      fillColor: Colors.grey[200],
                      prefixIcon: Icon(Icons.lock, color: Colors.grey),
                      suffixIcon: IconButton(
                        icon: Icon(
                          isPasswordVisible ? Icons.visibility : Icons.visibility_off,
                          color: Colors.grey,
                        ),
                        onPressed: () {
                          setState(() {
                            isPasswordVisible = !isPasswordVisible;
                          });
                        },
                      ),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(30),
                        borderSide: BorderSide.none,
                      ),
                      contentPadding: EdgeInsets.symmetric(horizontal: 20, vertical: 15),
                    ),
                  ),
                  SizedBox(height: 16),
                  TextField(
                    controller: confirmPasswordController,
                    obscureText: !isPasswordVisible,
                    decoration: InputDecoration(
                      hintText: localizations.confirmPassword,
                      filled: true,
                      fillColor: Colors.grey[200],
                      prefixIcon: Icon(Icons.lock, color: Colors.grey),
                      suffixIcon: IconButton(
                        icon: Icon(
                          isPasswordVisible ? Icons.visibility : Icons.visibility_off,
                          color: Colors.grey,
                        ),
                        onPressed: () {
                          setState(() {
                            isPasswordVisible = !isPasswordVisible;
                          });
                        },
                      ),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(30),
                        borderSide: BorderSide.none,
                      ),
                      contentPadding: EdgeInsets.symmetric(horizontal: 20, vertical: 15),
                    ),
                  ),
                  SizedBox(height: 20),
                  ElevatedButton(
                    onPressed: () {
                      // Логика для смены пароля
                      Navigator.pop(context);
                    },
                    style: ElevatedButton.styleFrom(
                      primary: Colors.black,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(30),
                      ),
                      padding: EdgeInsets.symmetric(horizontal: 80, vertical: 16),
                    ),
                    child: Text(localizations.change, style: TextStyle(fontSize: 16)),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }
}
