import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:provider/provider.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import '../home/main_view.dart';
import 'registration/registration_view.dart';
import '../../viewmodels/auth_viewmodel.dart';

class LoginView extends StatefulWidget {
  @override
  _LoginViewState createState() => _LoginViewState();
}

class _LoginViewState extends State<LoginView> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _isPasswordVisible = false;

  @override
  Widget build(BuildContext context) {
    final localizations = AppLocalizations.of(context)!;
    final authViewModel = Provider.of<AuthViewModel>(context);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    // Определяем цвет для поля ввода и стиль подсказки (hint)
    final fillColor = isDark ? Colors.grey[800] : Colors.white.withOpacity(0.9);
    final hintTextStyle = isDark ? TextStyle(color: Colors.white.withOpacity(0.7)) : null;

    return Scaffold(
      body: Stack(
        fit: StackFit.expand,
        children: [
          // Фон с фиксированным положением
          Container(
            decoration: BoxDecoration(
              image: DecorationImage(
                image: AssetImage('assets/images/auth_back.png'),
                fit: BoxFit.cover,
              ),
            ),
          ),
          // Overlay с разной прозрачностью для светлой/темной темы
          Container(color: isDark ? Colors.black.withOpacity(0.8) : Colors.black.withOpacity(0.5)),

          // Основной контент
          Column(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              // Верхняя часть с логотипом и заголовком
              Padding(
                padding: const EdgeInsets.only(top: 80),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    SvgPicture.asset('assets/svg/logo.svg', height: 60),
                    SizedBox(width: 10),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Uzaeronavigation',
                          style: TextStyle(
                            fontSize: 18,
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Container(
                          width: 140,
                          height: 1,
                          color: Colors.white.withOpacity(0.6),
                          margin: EdgeInsets.symmetric(vertical: 4),
                        ),
                        Text(
                          'State unitary enterprise centre',
                          style: TextStyle(fontSize: 10.5, color: Colors.white),
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              // Нижняя часть с формой логина
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 40),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      localizations.loginView_loginToAccount,
                      style: TextStyle(fontSize: 22, color: Colors.white),
                    ),
                    SizedBox(height: 20),
                    // Email TextField
                    TextField(
                      controller: _emailController,
                      decoration: InputDecoration(
                        prefixIcon: Icon(Icons.email, color: isDark ? Colors.white : Colors.grey),
                        hintText: localizations.loginView_email,
                        hintStyle: hintTextStyle,
                        filled: true,
                        fillColor: fillColor,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(30),
                          borderSide: BorderSide.none,
                        ),
                        contentPadding: EdgeInsets.symmetric(horizontal: 20, vertical: 15),
                      ),
                    ),
                    SizedBox(height: 16),
                    // Password TextField
                    TextField(
                      controller: _passwordController,
                      obscureText: !_isPasswordVisible,
                      decoration: InputDecoration(
                        prefixIcon: Icon(Icons.lock, color: isDark ? Colors.white : Colors.grey),
                        suffixIcon: IconButton(
                          icon: Icon(
                            _isPasswordVisible ? Icons.visibility : Icons.visibility_off,
                            color: isDark ? Colors.white : Colors.grey,
                          ),
                          onPressed: () => setState(() => _isPasswordVisible = !_isPasswordVisible),
                        ),
                        hintText: localizations.loginView_password,
                        hintStyle: hintTextStyle,
                        filled: true,
                        fillColor: fillColor,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(30),
                          borderSide: BorderSide.none,
                        ),
                        contentPadding: EdgeInsets.symmetric(horizontal: 20, vertical: 15),
                      ),
                    ),
                    SizedBox(height: 24),
                    TextButton(
                      onPressed: authViewModel.isLoading
                          ? null // Блокируем кнопку, если идёт загрузка
                          : () async {
                        FocusScope.of(context).unfocus(); // Закрываем клавиатуру
                        bool success = await authViewModel.login(
                          _emailController.text,
                          _passwordController.text,
                        );
                        if (success) {
                          Navigator.pushReplacement(
                            context,
                            MaterialPageRoute(builder: (context) => MainView()),
                          );
                        } else {
                          // Отображаем сообщение об ошибке
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text(authViewModel.errorMessage ?? 'Authentication error'),
                              backgroundColor: Colors.red,
                              duration: Duration(seconds: 3),
                            ),
                          );
                        }
                      },
                      style: TextButton.styleFrom(
                        backgroundColor: isDark ? Colors.blue : Colors.black,
                        padding: EdgeInsets.symmetric(horizontal: 100, vertical: 12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(30),
                        ),
                        minimumSize: Size(double.infinity, 48),
                      ),
                      child: authViewModel.isLoading
                          ? CircularProgressIndicator(color: Colors.white)
                          : Text(
                        localizations.loginView_login,
                        style: TextStyle(fontSize: 16, color: Colors.white),
                      ),
                    ),
                    SizedBox(height: 16),
                    TextButton(
                      onPressed: () {
                        Navigator.pushReplacement(
                          context,
                          MaterialPageRoute(builder: (context) => RegistrationView()),
                        );
                      },
                      style: TextButton.styleFrom(
                        padding: EdgeInsets.symmetric(horizontal: 10, vertical: 12),
                        backgroundColor: Colors.white.withOpacity(0.3),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(30),
                        ),
                        minimumSize: Size(double.infinity, 48),
                      ),
                      child: Text(
                        localizations.loginView_register,
                        style: TextStyle(color: Colors.white, fontSize: 16),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
