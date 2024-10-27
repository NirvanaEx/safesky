import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:provider/provider.dart';
import '../../../viewmodels/auth_viewmodel.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import '../../home/main_view.dart';
import '../../../models/user_model.dart';

class InfoView extends StatefulWidget {
  @override
  _InfoViewState createState() => _InfoViewState();
}

class _InfoViewState extends State<InfoView> {
  final _nameController = TextEditingController();
  final _surnameController = TextEditingController();
  final _passwordController = TextEditingController();
  final _phoneController = TextEditingController();
  bool _isPasswordVisible = false;
  String _selectedCountryCode = "+998";
  String _selectedFlag = "🇺🇿";

  final List<Map<String, String>> _countries = [
    {"code": "+998", "flag": "🇺🇿"},
    {"code": "+1", "flag": "🇺🇸"},
    {"code": "+44", "flag": "🇬🇧"},
    {"code": "+7", "flag": "🇷🇺"},
    {"code": "+997", "flag": "🇰🇿"},
  ];

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
                          hintText: localizations.password,
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
                        onPressed: () async {
                          FocusScope.of(context).unfocus();

                          UserModel? user = await authViewModel.register(
                            _nameController.text,
                            _passwordController.text,
                          );

                          user = new UserModel(id: 1, email: 'my@mail.com', name: 'Dias', token: 'GDX');
                          if (user != null) {
                            Navigator.pushReplacement(
                              context,
                              MaterialPageRoute(builder: (context) => MainView()),
                            );
                          } else {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(content: Text(authViewModel.errorMessage ?? 'Ошибка при регистрации')),
                            );
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
