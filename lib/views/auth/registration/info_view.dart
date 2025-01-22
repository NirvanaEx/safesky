import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:provider/provider.dart';
import 'package:safe_sky/views/auth/login_view.dart';
import '../../../viewmodels/auth_viewmodel.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import '../../home/main_view.dart';
import '../../../models/user_model.dart';

class InfoView extends StatefulWidget {
  final String email;

  InfoView({required this.email});

  @override
  _InfoViewState createState() => _InfoViewState();
}

class _InfoViewState extends State<InfoView> {
  final _nameController = TextEditingController();
  final _surnameController = TextEditingController();
  final _passwordController = TextEditingController();
  final _passwordRepeatController = TextEditingController();

  final _phoneController = TextEditingController();


  bool _isPasswordVisible = false;
  String _selectedCountryCode = "+998";
  String _selectedFlag = "🇺🇿";

  late TextEditingController _codeController = TextEditingController();

  late Timer _timer;
  int _remainingTime = 300; // 5 минут в секундах
  bool _isTimerRunning = true;

  final List<Map<String, String>> _countries = [
    {"code": "+998", "flag": "🇺🇿"},
    {"code": "+1", "flag": "🇺🇸"},
    {"code": "+44", "flag": "🇬🇧"},
    {"code": "+7", "flag": "🇷🇺"},
    {"code": "+997", "flag": "🇰🇿"},
  ];

  void initState() {
    super.initState();
    _codeController = TextEditingController();
    _startCountdown();
  }

  @override
  void dispose() {
    _timer.cancel();
    _codeController.dispose();
    super.dispose();
  }

  // Функция для запуска обратного отсчёта
  void _startCountdown() {
    setState(() {
      _isTimerRunning = true;
      _remainingTime = 300;  // Сброс на 5 минут
    });

    _timer = Timer.periodic(Duration(seconds: 1), (timer) {
      if (_remainingTime > 0) {
        setState(() {
          _remainingTime--;
        });
      } else {
        _timer.cancel();
        setState(() {
          _isTimerRunning = false;  // Показываем иконку таймера для повторной отправки
        });
      }
    });
  }

  // Функция для повторной отправки кода
  Future<void> _resendCode() async {
    final authViewModel = Provider.of<AuthViewModel>(context);

    try {
      await authViewModel.sendEmail(widget.email);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Код отправлен повторно')),
      );
      _startCountdown();  // Перезапуск таймера
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Ошибка при отправке кода')),
      );
    }
  }

  // Форматирование оставшегося времени в минуты и секунды
  String _formatTime(int seconds) {
    final minutes = (seconds ~/ 60).toString().padLeft(2, '0');
    final secs = (seconds % 60).toString().padLeft(2, '0');
    return '$minutes:$secs';
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
          SingleChildScrollView(
            child: Column(
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
                SizedBox(height: 100),
                Align(
                  alignment: Alignment.bottomCenter,
                  child: SingleChildScrollView(
                    padding: EdgeInsets.only(
                      left: 32,
                      right: 32,
                      bottom: MediaQuery.of(context).viewInsets.bottom + 20,
                    ),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(localizations.register, style: TextStyle(fontSize: 22, color: Colors.white)),
                        SizedBox(height: 20),
                        TextField(
                          controller: _nameController,
                          decoration: InputDecoration(
                            prefixIcon: Icon(Icons.person, color: Colors.grey),
                            hintText: localizations.name,
                            filled: true,
                            fillColor: Colors.white.withOpacity(0.9),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(30),
                              borderSide: BorderSide.none,
                            ),
                            contentPadding: EdgeInsets.symmetric(horizontal: 20, vertical: 15),
                          ),
                        ),
                        SizedBox(height: 16),
                        TextField(
                          controller: _surnameController,
                          decoration: InputDecoration(
                            prefixIcon: Icon(Icons.person_outline, color: Colors.grey),
                            hintText: localizations.surname,
                            filled: true,
                            fillColor: Colors.white.withOpacity(0.9),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(30),
                              borderSide: BorderSide.none,
                            ),
                            contentPadding: EdgeInsets.symmetric(horizontal: 20, vertical: 15),
                          ),
                        ),
                        SizedBox(height: 16),
                        Container(
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.9),
                            borderRadius: BorderRadius.circular(30),
                          ),
                          padding: EdgeInsets.symmetric(horizontal: 10),
                          child: Row(
                            children: [
                              Padding(
                                padding: const EdgeInsets.only(right: 8),
                                child: Icon(Icons.phone, color: Colors.grey),
                              ),
                              GestureDetector(
                                onTap: () {
                                  _showCountryPicker();
                                },
                                child: Row(
                                  children: [
                                    Text(
                                      _selectedFlag,
                                      style: TextStyle(fontSize: 20),
                                    ),
                                    SizedBox(width: 0),
                                    Icon(Icons.arrow_drop_down, color: Colors.grey),
                                    Text(
                                      _selectedCountryCode,
                                      style: TextStyle(fontSize: 16, color: Colors.black),
                                    ),
                                  ],
                                ),
                              ),
                              Expanded(
                                child: TextField(
                                  controller: _phoneController,
                                  keyboardType: TextInputType.phone,
                                  decoration: InputDecoration(
                                    hintText: localizations.phone,
                                    border: InputBorder.none,
                                    contentPadding: EdgeInsets.symmetric(horizontal: 10, vertical: 16),
                                  ),
                                  style: TextStyle(fontSize: 16),
                                ),
                              ),
                            ],
                          ),
                        ),
                        SizedBox(height: 16),
                        TextField(
                          controller: _passwordController,
                          obscureText: !_isPasswordVisible,
                          decoration: InputDecoration(
                            prefixIcon: Icon(Icons.lock, color: Colors.grey),
                            suffixIcon: IconButton(
                              icon: Icon(
                                _isPasswordVisible ? Icons.visibility : Icons.visibility_off,
                                color: Colors.grey,
                              ),
                              onPressed: () => setState(() => _isPasswordVisible = !_isPasswordVisible),
                            ),
                            hintText: localizations.createPassword,
                            filled: true,
                            fillColor: Colors.white.withOpacity(0.9),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(30),
                              borderSide: BorderSide.none,
                            ),
                            contentPadding: EdgeInsets.symmetric(horizontal: 20, vertical: 15),
                          ),
                        ),
                        SizedBox(height: 16),
                        TextField(
                          controller: _passwordRepeatController,
                          obscureText: !_isPasswordVisible,
                          decoration: InputDecoration(
                            prefixIcon: Icon(Icons.lock, color: Colors.grey),
                            suffixIcon: IconButton(
                              icon: Icon(
                                _isPasswordVisible ? Icons.visibility : Icons.visibility_off,
                                color: Colors.grey,
                              ),
                              onPressed: () => setState(() => _isPasswordVisible = !_isPasswordVisible),
                            ),
                            hintText: localizations.repeatPassword,
                            filled: true,
                            fillColor: Colors.white.withOpacity(0.9),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(30),
                              borderSide: BorderSide.none,
                            ),
                            contentPadding: EdgeInsets.symmetric(horizontal: 20, vertical: 15),
                          ),
                        ),
                        SizedBox(height: 16),
                        TextField(
                          controller: _codeController,
                          keyboardType: TextInputType.number,  // Разрешаем ввод только цифр
                          maxLength: 5,  // Устанавливаем ограничение на 5 символов
                          inputFormatters: [
                            FilteringTextInputFormatter.digitsOnly,  // Только цифры
                            LengthLimitingTextInputFormatter(5),  // Лимит в 5 символов
                          ],
                          decoration: InputDecoration(
                            prefixIcon: Icon(Icons.verified, color: Colors.grey),
                            hintText: localizations.confirmationCode,
                            filled: true,
                            fillColor: Colors.white.withOpacity(0.9),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(30),
                              borderSide: BorderSide.none,
                            ),
                            contentPadding: EdgeInsets.symmetric(horizontal: 20, vertical: 15),
                            suffixIcon: _isTimerRunning
                                ? Padding(
                              padding: const EdgeInsets.all(15.0),
                              child: Text(
                                _formatTime(_remainingTime),
                                style: TextStyle(fontSize: 16, color: Colors.grey),
                              ),
                            )
                                : IconButton(
                              icon: Icon(Icons.timer, color: Colors.blue),
                              onPressed: _resendCode,
                            ),
                          ),
                        ),
                        SizedBox(height: 24),
                        ElevatedButton(
                          onPressed: () async {
                            FocusScope.of(context).unfocus();


                            bool success = await authViewModel.register(
                              _nameController.text,
                              _surnameController.text,
                              widget.email,
                              _passwordController.text,
                              _passwordRepeatController.text,
                              _selectedCountryCode + _phoneController.text,
                              _codeController.text,
                            );
                            if (success) {
                              ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Registration successful')));
                              Navigator.pushReplacement(
                                context,
                                MaterialPageRoute(builder: (context) => LoginView()),
                              );
                            } else {
                              ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(authViewModel.errorMessage ?? 'Registration failed')));
                            }
                          },
                          style: ElevatedButton.styleFrom(
                            primary: Colors.black,
                            padding: EdgeInsets.symmetric(horizontal: 10, vertical: 12),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(30),
                            ),
                            minimumSize: Size(double.infinity, 48),
                          ),
                          child: authViewModel.isLoading
                              ? CircularProgressIndicator(color: Colors.white)
                              : Text(localizations.register, style: TextStyle(fontSize: 16)),
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
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _showCountryPicker() {
    showModalBottomSheet(
      context: context,
      builder: (context) {
        return ListView(
          children: _countries.map((country) {
            return ListTile(
              leading: Text(country["flag"]!, style: TextStyle(fontSize: 20)),
              title: Text(country["code"]!),
              onTap: () {
                setState(() {
                  _selectedCountryCode = country["code"]!;
                  _selectedFlag = country["flag"]!;
                });
                Navigator.pop(context);
              },
            );
          }).toList(),
        );
      },
    );
  }
}
