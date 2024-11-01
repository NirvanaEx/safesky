import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:provider/provider.dart';
import '../../../viewmodels/auth_viewmodel.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import '../login_view.dart';

class EmailView extends StatefulWidget {
  final ValueChanged<String> onNext;

  EmailView({required this.onNext});

  @override
  _EmailViewState createState() => _EmailViewState();
}

class _EmailViewState extends State<EmailView> {
  final _emailController = TextEditingController();
  DateTime? _lastSnackBarTime; // Переменная для отслеживания времени последнего SnackBar

  // Метод для проверки правильного формата email
  bool isValidEmail(String email) {
    final emailRegex = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
    return emailRegex.hasMatch(email);
  }

  // Метод для обработки нажатия кнопки "Продолжить"
  void _onContinue() async {
    final authViewModel = Provider.of<AuthViewModel>(context, listen: false);

    FocusScope.of(context).unfocus();

    final email = _emailController.text.trim();
    final now = DateTime.now();

    if (isValidEmail(email)) {
      // Отправляем email через authViewModel
      await authViewModel.sendEmail(email);

      if (authViewModel.errorMessage == null) {
        widget.onNext(email); // Переход к следующему экрану при успехе
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(authViewModel.errorMessage!)),
        );
      }
    } else if (_lastSnackBarTime == null || now.difference(_lastSnackBarTime!) > Duration(seconds: 5)) {
      _lastSnackBarTime = now;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(AppLocalizations.of(context)!.invalidEmailFormat)),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final localizations = AppLocalizations.of(context)!;
    final authViewModel = Provider.of<AuthViewModel>(context);

    return Scaffold(
      body: Stack(
        fit: StackFit.expand,
        children: [
          Image.asset('assets/images/auth_back.png', fit: BoxFit.cover),
          Container(color: Colors.black.withOpacity(0.5)),
          Column(
            children: [
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
                          style: TextStyle(fontSize: 18, color: Colors.white, fontWeight: FontWeight.bold),
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
              Spacer(),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 40),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    Text(localizations.register, style: TextStyle(fontSize: 22, color: Colors.white)),
                    SizedBox(height: 20),
                    TextField(
                      controller: _emailController,
                      decoration: InputDecoration(
                        prefixIcon: Icon(Icons.email, color: Colors.grey),
                        hintText: localizations.email,
                        filled: true,
                        fillColor: Colors.white.withOpacity(0.9),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(30),
                          borderSide: BorderSide.none,
                        ),
                        contentPadding: EdgeInsets.symmetric(horizontal: 20, vertical: 15),
                      ),
                    ),
                    SizedBox(height: 24),
                    ElevatedButton(
                      onPressed: _onContinue,
                      style: ElevatedButton.styleFrom(
                        primary: Colors.black,
                        padding: EdgeInsets.symmetric(horizontal: 100, vertical: 12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(30),
                        ),
                        minimumSize: Size(double.infinity, 48),
                      ),
                      child: authViewModel.isLoading
                          ? CircularProgressIndicator(color: Colors.white)
                          : Text(localizations.continueLabel, style: TextStyle(fontSize: 16)),
                    ),
                    SizedBox(height: 16),
                    TextButton(
                      onPressed: () {
                        Navigator.pushReplacement(
                          context,
                          MaterialPageRoute(builder: (context) => LoginView()),
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
                      child: Text(localizations.alreadyHaveAccount, style: TextStyle(color: Colors.white, fontSize: 16)),
                    ),
                    SizedBox(height: 16),
                    Text(
                      localizations.termsOfService,
                      style: TextStyle(color: Colors.white.withOpacity(0.7), fontSize: 12),
                      textAlign: TextAlign.center,
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
