import 'package:flutter/material.dart';
import 'email_view.dart';
import 'verify_view.dart';
import 'info_view.dart';

class RegistrationView extends StatefulWidget {
  @override
  _RegistrationViewState createState() => _RegistrationViewState();
}

class _RegistrationViewState extends State<RegistrationView> {
  final PageController _pageController = PageController();
  int _currentPage = 0;
  String _email = ''; // Переменная для хранения email

  void _nextPage(String email) {
    setState(() {
      _email = email; // Сохраняем email
      if (_currentPage < 2) {
        _currentPage++;
        _pageController.animateToPage(
          _currentPage,
          duration: Duration(milliseconds: 300),
          curve: Curves.easeInOut,
        );
      }
    });
  }

  void _previousPage() {
    if (_currentPage > 0) {
      setState(() => _currentPage--);
      _pageController.animateToPage(
        _currentPage,
        duration: Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    }
  }

  Future<bool> _onWillPop() async {
    if (_currentPage > 0) {
      _previousPage();
      return false; // Не закрывать экран
    }
    return true; // Закрыть экран, если на первой странице
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: _onWillPop,
      child: Scaffold(
        body: PageView(
          controller: _pageController,
          physics: NeverScrollableScrollPhysics(),
          children: [
            EmailView(onNext: _nextPage),
            VerifyView(onNext: () => _nextPage(_email), email: _email), // Передаем email в VerifyView
            InfoView(),
          ],
        ),
      ),
    );
  }
}
