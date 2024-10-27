import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:provider/provider.dart';
import '../../../viewmodels/auth_viewmodel.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class VerifyView extends StatefulWidget {
  final String email;
  final VoidCallback onNext;

  VerifyView({required this.email, required this.onNext});

  @override
  _VerifyViewState createState() => _VerifyViewState();
}

class _VerifyViewState extends State<VerifyView> {
  final _codeController = TextEditingController();

  // Метод для обработки нажатия кнопки "Продолжить"
  void _onContinue() {
    // Скрываем клавиатуру перед переходом
    FocusScope.of(context).unfocus();
    widget.onNext();
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
                    Icon(Icons.email, color: Colors.grey, size: 40),
                    SizedBox(height: 20),
                    RichText(
                      textAlign: TextAlign.center, // Центрирование текста
                      text: TextSpan(
                        text: '${localizations.verificationSent} ', // Текст до email
                        style: TextStyle(fontSize: 16, color: Colors.white),
                        children: [
                          TextSpan(
                            text: widget.email,
                            style: TextStyle(
                              fontSize: 16,
                              color: Colors.white,
                              decoration: TextDecoration.underline, // Подчеркивание email
                            ),
                          ),
                        ],
                      ),
                    ),
                    SizedBox(height: 20),
                    TextField(
                      controller: _codeController,
                      textAlign: TextAlign.center,
                      keyboardType: TextInputType.number,
                      maxLength: 6,
                      showCursor: false,
                      decoration: InputDecoration(
                        hintText: '______',
                        hintStyle: TextStyle(letterSpacing: 10, color: Colors.grey),
                        filled: true,
                        fillColor: Colors.white.withOpacity(0.9),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(30),
                          borderSide: BorderSide(color: Colors.grey),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(30),
                          borderSide: BorderSide(color: Colors.grey),
                        ),
                        contentPadding: EdgeInsets.symmetric(horizontal: 20, vertical: 15),
                        counterText: "",
                      ),
                      style: TextStyle(letterSpacing: 10, fontSize: 20, color: Colors.black),
                    ),
                    SizedBox(height: 24),
                    ElevatedButton(
                      onPressed: _onContinue, // Используем метод _onContinue
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
                    Text(
                      localizations.acceptTerms,
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
