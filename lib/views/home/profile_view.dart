import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:safe_sky/services/auth_service.dart';
import 'package:safe_sky/viewmodels/add_request_viewmodel.dart';

import '../../viewmodels/auth_viewmodel.dart';
import 'package:provider/provider.dart';

class ProfileView extends StatefulWidget {
  @override
  _ProfileViewState createState() => _ProfileViewState();
}

class _ProfileViewState extends State<ProfileView> {


  final _nameController = TextEditingController(text: "John");
  final _surnameController = TextEditingController(text: "Doe");
  final _phoneController = TextEditingController(text: "");

  String selectedCountryCode = "+998";
  bool isLoading = false; // Переменная для отслеживания состояния загрузки


  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final authViewModel = Provider.of<AuthViewModel>(context, listen: false); // listen: false, чтобы избежать перерисовок
      _nameController.text = authViewModel.user?.name ?? '';
      _surnameController.text = authViewModel.user?.surname ?? '';
      _phoneController.text = formatPhoneNumber(authViewModel.user?.phoneNumber ?? '');
    });
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
                localizations.profileView_profile,
                style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
              ),
            ),
            SizedBox(height: 30),
            _buildLabel(localizations.profileView_name),
            _buildTextField(_nameController, hintText: localizations.profileView_name),
            SizedBox(height: 16),
            _buildLabel(localizations.profileView_surname),
            _buildTextField(_surnameController, hintText: localizations.profileView_surname),
            SizedBox(height: 16),
            _buildLabel(localizations.profileView_phone),
            _buildPhoneField(),
            SizedBox(height: 16),
            _buildLabel(localizations.profileView_password),
            _buildPasswordField(),
            SizedBox(height: 20),
            TextButton(
              onPressed: () => _showChangePasswordDialog(context),
              child: Text(
                localizations.profileView_changePassword,
                style: TextStyle(color: Colors.blue, fontSize: 16),
              ),
            ),
            SizedBox(height: 20),
            Center(
              child: ElevatedButton(
                onPressed: isLoading
                    ? null
                    : () async {
                  setState(() {
                    isLoading = true;
                  });
                  try {
                    final authService = AuthService();
                    await authService.changeProfileData(
                      _nameController.text,
                      _surnameController.text,
                      '$selectedCountryCode${_phoneController.text}',
                    );

                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text(localizations.profileView_profileUpdated)),
                    );
                  } catch (e) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text(e.toString())),
                    );
                  } finally {
                    setState(() {
                      isLoading = false;
                    });
                  }
                },
                style: ElevatedButton.styleFrom(
                  primary: Colors.black,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30),
                  ),
                  padding: EdgeInsets.symmetric(horizontal: 100, vertical: 16),
                  minimumSize: Size(double.infinity, 48),
                ),
                child: isLoading
                    ? SizedBox(
                      width: 20, // Устанавливаем ширину индикатора
                      height: 20, // Устанавливаем высоту индикатора
                      child: CircularProgressIndicator(
                        strokeWidth: 2, // Уменьшаем толщину линии индикатора
                        valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                      ),
                    )
                    : Text(localizations.profileView_save, style: TextStyle(fontSize: 16)),
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

  // Метод для поля с телефоном с выпадающим списком кода страны
  Widget _buildPhoneField() {
    // Доступные страны
    final List<Map<String, String>> countries = [
      {"code": "+998", "flag": "🇺🇿"},
      {"code": "+1", "flag": "🇺🇸"},
      {"code": "+44", "flag": "🇬🇧"},
      {"code": "+7", "flag": "🇷🇺"},
      {"code": "+997", "flag": "🇰🇿"},
    ];

    return Container(
      decoration: BoxDecoration(
        color: Colors.grey[200],
        borderRadius: BorderRadius.circular(30),
      ),
      padding: EdgeInsets.symmetric(horizontal: 10),
      child: Row(
        children: [
          DropdownButtonHideUnderline(
            child: DropdownButton<String>(
              value: selectedCountryCode,
              items: countries.map((country) {
                return DropdownMenuItem<String>(
                  value: country['code'],
                  child: Row(
                    children: [
                      SizedBox(width: 8),
                      Text(country['flag']!, style: TextStyle(fontSize: 18)),
                      SizedBox(width: 8),
                      Text(country['code']!, style: TextStyle(fontSize: 16)),
                    ],
                  ),
                );
              }).toList(),
              onChanged: (value) {
                setState(() {
                  selectedCountryCode = value!; // Обновляем выбранный код страны
                });
              },
            ),
          ),
          Expanded(
            child: TextField(
              controller: _phoneController,
              keyboardType: TextInputType.phone,
              decoration: InputDecoration(
                border: InputBorder.none,
                hintText: '991234567',
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

  void _showChangePasswordDialog(BuildContext context) {
    final localizations = AppLocalizations.of(context)!;
    final authViewModel = Provider.of<AuthViewModel>(context, listen: false);

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
                    localizations.profileView_changePassword,
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  SizedBox(height: 20),
                  TextField(
                    controller: newPasswordController,
                    obscureText: !isPasswordVisible,
                    decoration: InputDecoration(
                      hintText: localizations.profileView_newPassword,
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
                      hintText: localizations.profileView_confirmPassword,
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
                    onPressed: () async {
                      final isSuccess = await authViewModel.changePassword(
                        newPasswordController.text,
                        confirmPasswordController.text,
                      );

                      if (isSuccess) {
                        Navigator.pop(context);
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text(localizations.profileView_changePassword)),
                        );
                      } else {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text(authViewModel.errorMessage ?? 'Error changing password')),
                        );
                      }
                    },
                    style: ElevatedButton.styleFrom(
                      primary: Colors.black,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(30),
                      ),
                      padding: EdgeInsets.symmetric(horizontal: 80, vertical: 16),
                    ),
                    child: Text(localizations.profileView_change, style: TextStyle(fontSize: 16)),
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
