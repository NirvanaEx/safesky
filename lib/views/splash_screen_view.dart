import 'dart:async';
import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import 'package:provider/provider.dart';
import '../../viewmodels/auth_viewmodel.dart';

import 'auth/login_view.dart';
import 'home/main_view.dart';

class SplashScreenView extends StatefulWidget {
  const SplashScreenView({Key? key}) : super(key: key);

  @override
  _SplashScreenViewState createState() => _SplashScreenViewState();
}

class _SplashScreenViewState extends State<SplashScreenView> {
  Timer? _authCheckTimer;

  @override
  void initState() {
    super.initState();
    _initializeAuth();
  }

  Future<void> _initializeAuth() async {
    // Искусственная задержка для проигрывания анимации (2 секунды)
    await Future.delayed(const Duration(seconds: 2));
    _checkAuth();
    _startAuthCheckTimer();
  }

  Future<void> _checkAuth() async {
    final authViewModel = Provider.of<AuthViewModel>(context, listen: false);
    bool isAuthenticated = await authViewModel.isAuthenticated();

    if (isAuthenticated) {
      _navigateTo(MainView());
    } else {
      _navigateTo(LoginView());
    }
  }

  void _startAuthCheckTimer() {
    _authCheckTimer = Timer.periodic(const Duration(seconds: 5), (_) async {
      final authViewModel = Provider.of<AuthViewModel>(context, listen: false);
      bool isAuthenticated = await authViewModel.isAuthenticated();

      // Если токен недействителен, переходим на экран логина и отменяем таймер
      if (!isAuthenticated) {
        _authCheckTimer?.cancel();
        if (mounted) {
          _navigateTo(LoginView());
        }
      }
    });
  }

  void _navigateTo(Widget destination) {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => destination),
    );
  }

  @override
  void dispose() {
    _authCheckTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    // Размер контейнера с анимацией адаптивен к ширине экрана
    final double containerSize = MediaQuery.of(context).size.width * 0.7;

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      body: SafeArea(
        child: Center(
          child: Stack(
            alignment: Alignment.center,
            children: [
              SizedBox(
                width: 400,
                height: 400,
                child: Lottie.asset(
                  'assets/json/drone_loading.json',
                  fit: BoxFit.contain,
                ),
              ),
              Positioned(
                bottom: containerSize * 0.15,
                child: Text(
                  'Loading...',
                  style: theme.textTheme.bodyLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                    letterSpacing: 1.2,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
