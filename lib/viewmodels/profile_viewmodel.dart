import 'package:flutter/material.dart';
import 'package:safe_sky/services/auth_service.dart';
import 'package:safe_sky/viewmodels/auth_viewmodel.dart';
import 'package:provider/provider.dart';

import '../views/auth/login_view.dart';

class ProfileViewModel extends ChangeNotifier {
  bool isLoading = false;
  final AuthService _authService = AuthService();

  /// Сохраняет обновлённые данные профиля.
  /// Параметр [context] используется для получения [AuthViewModel] и отображения SnackBar.
  Future<void> saveProfileData({
    required String name,
    required String surname,
    required String patronymic,
    required String phone,
    required BuildContext context,
  }) async {
    isLoading = true;
    notifyListeners();

    try {
      await _authService.changeProfileData(name, surname, patronymic, phone);

      // Обновляем данные пользователя в AuthViewModel
      final authViewModel = Provider.of<AuthViewModel>(context, listen: false);
      authViewModel.updateUser(
        name: name,
        surname: surname,
        patronymic: patronymic,
        phoneNumber: phone,
      );

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Profile updated successfully')),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(e.toString())),
      );
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  Future<void> deleteAccount(BuildContext context) async {
    isLoading = true;
    notifyListeners();
    try {
      await _authService.deleteAccount();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Аккаунт успешно удалён')),
      );
      // После удаления перенаправляем на экран логина
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (_) => LoginView()),
            (route) => false,
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(e.toString())),
      );
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

}
