import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:safe_sky/services/auth_service.dart';
import 'package:safe_sky/viewmodels/add_request_viewmodel.dart';
import '../../viewmodels/auth_viewmodel.dart';
import 'package:provider/provider.dart';
import '../auth/login_view.dart';

class ProfileView extends StatefulWidget {
  @override
  _ProfileViewState createState() => _ProfileViewState();
}

class _ProfileViewState extends State<ProfileView> {
  final _nameController = TextEditingController(text: "John");
  final _surnameController = TextEditingController(text: "Doe");
  final _phoneController = TextEditingController(text: "");

  String selectedCountryCode = "+998";
  bool isLoading = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final authViewModel = Provider.of<AuthViewModel>(context, listen: false);
      _nameController.text = authViewModel.user?.name ?? '';
      _surnameController.text = authViewModel.user?.surname ?? '';
      _phoneController.text =
          formatPhoneNumber(authViewModel.user?.phoneNumber ?? '');
    });
  }

  String formatPhoneNumber(String phoneNumber) {
    const countryCode = '+998';
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
        padding:
        const EdgeInsets.symmetric(horizontal: 16.0, vertical: 40.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Text(
                localizations.profileView_profile,
                style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            const SizedBox(height: 30),
            _buildLabel(localizations.profileView_name),
            _buildTextField(_nameController,
                hintText: localizations.profileView_name),
            const SizedBox(height: 16),
            _buildLabel(localizations.profileView_surname),
            _buildTextField(_surnameController,
                hintText: localizations.profileView_surname),
            const SizedBox(height: 16),
            _buildLabel(localizations.profileView_phone),
            _buildPhoneField(),
            const SizedBox(height: 16),
            _buildLabel(localizations.profileView_password),
            _buildPasswordField(),
            const SizedBox(height: 20),
            TextButton(
              onPressed: () => _showChangePasswordDialog(context),
              child: Text(
                localizations.profileView_changePassword,
                style: Theme.of(context)
                    .textTheme
                    .bodyLarge
                    ?.copyWith(color: Colors.blue, fontSize: 16),
              ),
            ),
            const SizedBox(height: 20),
            // Кнопка Save на всю ширину
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                style: Theme.of(context).elevatedButtonTheme.style,
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
                      SnackBar(
                          content: Text(
                              localizations.profileView_profileUpdated)),
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

                child: isLoading
                    ? SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    valueColor:
                    AlwaysStoppedAnimation<Color>(Colors.white),
                  ),
                )
                    : Text(
                  localizations.profileView_save,

                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLabel(String label) {
    return Text(
      label,
      style: Theme.of(context).textTheme.bodyLarge?.copyWith(
        fontSize: 16,
        fontWeight: FontWeight.bold,
      ),
    );
  }

  Widget _buildTextField(TextEditingController controller,
      {required String hintText}) {
    return TextField(
      controller: controller,
      style: Theme.of(context).textTheme.bodyLarge,
      decoration: InputDecoration(
        hintText: hintText,
      ),
    );
  }

  Widget _buildPhoneField() {
    final List<Map<String, String>> countries = [
      {"code": "+998", "flag": "🇺🇿"},
      // Добавьте при необходимости другие коды
    ];

    return TextField(
      controller: _phoneController,
      keyboardType: TextInputType.phone,
      style: Theme.of(context).textTheme.bodyLarge,
      decoration: InputDecoration(
        hintText: '991234567',
        prefixIcon: Padding(
          padding: const EdgeInsets.only(left: 25, bottom: 1),
          child: DropdownButtonHideUnderline(
            child: DropdownButton<String>(
              value: selectedCountryCode,
              items: countries.map((country) {
                return DropdownMenuItem<String>(
                  value: country['code'],
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(country['flag'] ?? ''),
                      const SizedBox(width: 6),
                      Text(country['code'] ?? ''),
                    ],
                  ),
                );
              }).toList(),
              onChanged: (value) {
                setState(() {
                  selectedCountryCode = value!;
                });
              },
            ),
          ),
        ),
        prefixIconConstraints: const BoxConstraints(
          minWidth: 0,
          minHeight: 0,
        ),
      ),
    );
  }

  Widget _buildPasswordField() {
    return TextField(
      obscureText: true,
      enableSuggestions: false,
      autocorrect: false,
      readOnly: true,
      style: Theme.of(context).textTheme.bodyLarge,
      decoration: InputDecoration(
        hintText: "**********",
        filled: true,
        fillColor: Theme.of(context).inputDecorationTheme.fillColor,
        prefixIcon: Padding(
          padding: const EdgeInsets.only(left: 25, right: 10, bottom: 5),
          child: Icon(Icons.lock, color: Theme.of(context).iconTheme.color),
        ),
      ),
    );
  }

  void _showChangePasswordDialog(BuildContext context) {
    final localizations = AppLocalizations.of(context)!;
    final authViewModel = Provider.of<AuthViewModel>(context, listen: false);

    showDialog(
      context: context,
      builder: (BuildContext context) {
        final oldPasswordController = TextEditingController();
        final newPasswordController = TextEditingController();
        final confirmPasswordController = TextEditingController();
        bool isOldPasswordVisible = false;
        bool isNewPasswordVisible = false;
        bool isConfirmPasswordVisible = false;

        return StatefulBuilder(
          builder: (context, setState) {
            return Theme(
              data: Theme.of(context),
              child: AlertDialog(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                ),
                contentPadding: const EdgeInsets.all(20),
                content: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      localizations.profileView_changePassword,
                      style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 20),
                    TextField(
                      controller: oldPasswordController,
                      obscureText: !isOldPasswordVisible,
                      style: Theme.of(context).textTheme.bodyLarge,
                      decoration: InputDecoration(
                        hintText: localizations.profileView_oldPassword,
                        // Если убрать явное указание filled/ fillColor,
                        // то InputDecorationTheme будет применён автоматически.
                        // Если нужно оставить их, можно использовать:
                        filled: true,
                        fillColor: Theme.of(context).inputDecorationTheme.fillColor,
                        prefixIcon: Icon(Icons.lock,
                            color: Theme.of(context).iconTheme.color),
                        suffixIcon: IconButton(
                          icon: Icon(
                            isOldPasswordVisible
                                ? Icons.visibility
                                : Icons.visibility_off,
                            color: Theme.of(context).iconTheme.color,
                          ),
                          onPressed: () {
                            setState(() {
                              isOldPasswordVisible = !isOldPasswordVisible;
                            });
                          },
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    TextField(
                      controller: newPasswordController,
                      obscureText: !isNewPasswordVisible,
                      style: Theme.of(context).textTheme.bodyLarge,
                      decoration: InputDecoration(
                        hintText: localizations.profileView_newPassword,
                        filled: true,
                        fillColor: Theme.of(context).inputDecorationTheme.fillColor,
                        prefixIcon: Icon(Icons.lock,
                            color: Theme.of(context).iconTheme.color),
                        suffixIcon: IconButton(
                          icon: Icon(
                            isNewPasswordVisible
                                ? Icons.visibility
                                : Icons.visibility_off,
                            color: Theme.of(context).iconTheme.color,
                          ),
                          onPressed: () {
                            setState(() {
                              isNewPasswordVisible = !isNewPasswordVisible;
                            });
                          },
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    TextField(
                      controller: confirmPasswordController,
                      obscureText: !isConfirmPasswordVisible,
                      style: Theme.of(context).textTheme.bodyLarge,
                      decoration: InputDecoration(
                        hintText: localizations.profileView_confirmPassword,
                        filled: true,
                        fillColor: Theme.of(context).inputDecorationTheme.fillColor,
                        prefixIcon: Icon(Icons.lock,
                            color: Theme.of(context).iconTheme.color),
                        suffixIcon: IconButton(
                          icon: Icon(
                            isConfirmPasswordVisible
                                ? Icons.visibility
                                : Icons.visibility_off,
                            color: Theme.of(context).iconTheme.color,
                          ),
                          onPressed: () {
                            setState(() {
                              isConfirmPasswordVisible =
                              !isConfirmPasswordVisible;
                            });
                          },
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),
                    // Кнопка Change на всю ширину
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        style: Theme.of(context).elevatedButtonTheme.style,
                        onPressed: () async {
                          final isSuccess = await authViewModel.changePassword(
                            oldPasswordController.text,
                            newPasswordController.text,
                            confirmPasswordController.text,
                          );
                          if (isSuccess) {
                            Navigator.pop(context);
                            Navigator.pushAndRemoveUntil(
                              context,
                              MaterialPageRoute(builder: (context) => LoginView()),
                                  (route) => false,
                            );
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                  content: Text(localizations
                                      .profileView_successChangedPassword)),
                            );
                          } else {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                  content: Text(authViewModel.errorMessage ??
                                      'Error changing password')),
                            );
                          }
                        },
                        child: Text(
                          localizations.profileView_change
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

}
