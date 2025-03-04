import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:provider/provider.dart';
import '../../viewmodels/auth_viewmodel.dart';
import 'package:safe_sky/views/home/profile_view.dart';
import 'package:safe_sky/views/home/scan_view.dart';
import '../auth/login_view.dart';
import '../notification_view.dart';
import '../side_menu/about_app_view.dart';
import '../side_menu/settings_view.dart';
import '../side_menu/support_view.dart';
import 'add_request_view.dart';
import 'request_list_view.dart';

class MainView extends StatefulWidget {
  @override
  _MainViewState createState() => _MainViewState();
}

class _MainViewState extends State<MainView> {
  int _currentIndex = 0;
  List<Widget?> _screens = List.filled(4, null, growable: false);

  Widget _buildScreen(int index) {
    switch (index) {
      case 0:
        return RequestListView();
      case 1:
        return AddRequestView();
      case 3:
        return ProfileView();
      default:
        return SizedBox.shrink();
    }
  }

  void _onTabTapped(int index) {
    if (index == 2) {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => ScanView()),
      );
    } else {
      setState(() {
        _currentIndex = index;
        if (_screens[index] == null) {
          _screens[index] = _buildScreen(index);
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final localizations = AppLocalizations.of(context)!;

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).appBarTheme.backgroundColor,
        elevation: 1,
        leading: Builder(
          builder: (BuildContext context) {
            return IconButton(
              icon: Icon(Icons.menu, color: Theme.of(context).iconTheme.color),
              onPressed: () {
                Scaffold.of(context).openDrawer();
              },
            );
          },
        ),
        title: Center(
          child: SvgPicture.asset(
            'assets/svg/logo.svg',
            height: 40,
            color: Theme.of(context).iconTheme.color,
          ),
        ),
        actions: [
          Container(width: 48),
        ],
      ),
      drawer: _buildDrawer(localizations),
      body: _screens[_currentIndex] ?? _buildScreen(_currentIndex),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: _onTabTapped,
        type: BottomNavigationBarType.fixed,
        selectedItemColor:
        Theme.of(context).bottomNavigationBarTheme.selectedItemColor,
        unselectedItemColor:
        Theme.of(context).bottomNavigationBarTheme.unselectedItemColor,
        items: [
          BottomNavigationBarItem(
            icon: Icon(Icons.list),
            label: localizations.mainView_requests,
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.add),
            label: localizations.mainView_add,
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.qr_code_scanner),
            label: localizations.mainView_scan,
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person),
            label: localizations.mainView_profile,
          ),
        ],
      ),
    );
  }

  Widget _buildDrawer(AppLocalizations localizations) {
    final authViewModel = Provider.of<AuthViewModel>(context);

    return FractionallySizedBox(
      widthFactor: 0.6,
      child: Drawer(
        child: SafeArea(
          child: Column(
            children: [
              Align(
                alignment: Alignment.topLeft,
                child: IconButton(
                  icon: Icon(Icons.close, color: Theme.of(context).iconTheme.color),
                  onPressed: () {
                    Navigator.pop(context);
                  },
                ),
              ),
              Expanded(
                child: SingleChildScrollView(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Замените этот участок в _buildDrawer:
                        Consumer<AuthViewModel>(
                          builder: (context, authViewModel, child) {
                            return Text(
                              '${localizations.mainView_hi}, ${authViewModel.user?.surname ?? 'John'} '
                                  '${authViewModel.user?.name ?? 'Doe'} '
                                  '${authViewModel.user?.patronymic ?? ''}',
                              style: Theme.of(context).textTheme.headline6,
                            );
                          },
                        ),
                        Divider(),
                        ListTile(
                          leading: Icon(Icons.settings, color: Theme.of(context).iconTheme.color),
                          title: Text(localizations.mainView_settings,
                              style: Theme.of(context).textTheme.bodyText1),
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(builder: (context) => SettingsView()),
                            );
                          },
                        ),
                        ListTile(
                          leading: Icon(Icons.info_outline, color: Theme.of(context).iconTheme.color),
                          title: Text(localizations.mainView_aboutApp,
                              style: Theme.of(context).textTheme.bodyText1),
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(builder: (context) => AboutAppView()),
                            );
                          },
                        ),
                        ListTile(
                          leading: Icon(Icons.logout, color: Theme.of(context).iconTheme.color),
                          title: Text(localizations.mainView_logout,
                              style: Theme.of(context).textTheme.bodyText1),
                          onTap: () async {
                            final authViewModel = Provider.of<AuthViewModel>(context, listen: false);
                            await authViewModel.logout();
                            Navigator.pushAndRemoveUntil(
                              context,
                              MaterialPageRoute(builder: (context) => LoginView()),
                                  (route) => false,
                            );
                          },
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Container(
                  decoration: BoxDecoration(
                    color: Theme.of(context).inputDecorationTheme.fillColor,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  padding: const EdgeInsets.all(12),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // Первый номер
                      Row(
                        children: [
                          Icon(Icons.phone, color: Theme.of(context).iconTheme.color),
                          const SizedBox(width: 8),
                          Text(
                            '(78) 140-27-78',
                            style: Theme.of(context).textTheme.bodyText1?.copyWith(fontWeight: FontWeight.bold),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      // Второй номер
                      Row(
                        children: [
                          Icon(Icons.phone, color: Theme.of(context).iconTheme.color),
                          const SizedBox(width: 8),
                          Text(
                            '(78) 140-38-41',
                            style: Theme.of(context).textTheme.bodyText1?.copyWith(fontWeight: FontWeight.bold),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      // Третий номер
                      Row(
                        children: [
                          Icon(Icons.phone, color: Theme.of(context).iconTheme.color),
                          const SizedBox(width: 8),
                          Text(
                            '(78) 140-38-42',
                            style: Theme.of(context).textTheme.bodyText1?.copyWith(fontWeight: FontWeight.bold),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      // Под номерами отображается один текст
                      Text(
                        localizations.mainView_available24,
                        style: Theme.of(context).textTheme.caption,
                      ),
                    ],
                  ),
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}

class EmptyView extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return SizedBox.shrink();
  }
}
