import 'dart:async';
import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import 'package:provider/provider.dart';
import '../../viewmodels/auth_viewmodel.dart';

import 'auth/login_view.dart';
import 'home/main_view.dart';

class SplashScreenView extends StatefulWidget {
  @override
  _SplashScreenViewState createState() => _SplashScreenViewState();
}

class _SplashScreenViewState extends State<SplashScreenView> {
  Timer? _authCheckTimer;

  @override
  void initState() {
    super.initState();
    _checkAuth();
    _startAuthCheckTimer();
  }

  void _checkAuth() async {
    final authViewModel = Provider.of<AuthViewModel>(context, listen: false);

    // Искусственная задержка на 2 секунды для проигрывания анимации
    await Future.delayed(Duration(seconds: 2));

    // Проверяем авторизацию
    bool isAuthenticated = await authViewModel.isAuthenticated();

    // Переход на нужный экран
    if (isAuthenticated) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => MainView()),
      );
    } else {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => LoginView()),
      );
    }
  }

  void _startAuthCheckTimer() {
    _authCheckTimer = Timer.periodic(Duration(seconds: 5), (_) async {
      final authViewModel = Provider.of<AuthViewModel>(context, listen: false);

      // Проверка токена
      bool isAuthenticated = await authViewModel.isAuthenticated();

      // Если токен недействителен, переходим на экран логина
      if (!isAuthenticated) {
        _authCheckTimer?.cancel(); // Останавливаем таймер перед переходом
        if (mounted) {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => LoginView()),
          );
        }
      }
    });
  }

  @override
  void dispose() {
    _authCheckTimer?.cancel(); // Очищаем таймер при уничтожении виджета
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        child: Stack(
          alignment: Alignment.center,
          children: [
            Container(
              width: 400,
              height: 400,
              child: Lottie.asset(
                'assets/json/drone_loading.json',
                fit: BoxFit.contain,
              ),
            ),
            Positioned(
              bottom: 70,
              child: Text(
                'Loading...',
                style: TextStyle(
                  color: Colors.black,
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 1.2,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
