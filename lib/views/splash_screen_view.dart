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
  @override
  void initState() {
    super.initState();
    _checkAuth();
  }

  void _checkAuth() async {
    final authViewModel = Provider.of<AuthViewModel>(context, listen: false);

    // Искусственная задержка на 3 секунды для проигрывания анимации
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
