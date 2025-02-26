import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:provider/provider.dart'; // Импорт Provider
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
        backgroundColor: Colors.white,
        elevation: 1,
        leading: Builder(
          builder: (BuildContext context) {
            return IconButton(
              icon: Icon(Icons.menu, color: Colors.black),
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
            color: Color(0xFF323955),
          ),
        ),
        actions: [
          // Если уведомления временно скрыты, добавляем заглушку:
          Container(
            width: 48, // ширину можно подогнать под размер иконки уведомлений
          ),

          // Если понадобится вернуть уведомления, можно использовать следующий код:
          // IconButton(
          //   icon: Icon(Icons.notifications, color: Colors.black),
          //   onPressed: () {
          //     Navigator.push(
          //       context,
          //       MaterialPageRoute(builder: (context) => NotificationView()),
          //     );
          //   },
          // ),
        ],
      ),
      drawer: _buildDrawer(localizations),
      body: _screens[_currentIndex] ?? _buildScreen(_currentIndex),

      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: _onTabTapped,
        type: BottomNavigationBarType.fixed,
        selectedItemColor: Colors.blue,
        unselectedItemColor: Colors.grey,
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
                  icon: Icon(Icons.close),
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
                        Text(
                          '${localizations.mainView_hi}, ${authViewModel.user?.surname ?? 'John'} ${authViewModel.user?.name ?? 'Doe'}',
                          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                        ),
                        Divider(),
                        // ListTile(
                        //   leading: Icon(Icons.support_agent, color: Colors.black),
                        //   title: Text(localizations.support),
                        //   onTap: () {
                        //     Navigator.push(
                        //       context,
                        //       MaterialPageRoute(builder: (context) => SupportView()),
                        //     );
                        //   },
                        // ),
                        ListTile(
                          leading: Icon(Icons.settings, color: Colors.black),
                          title: Text(localizations.mainView_settings),
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(builder: (context) => SettingsView()),
                            );
                          },
                        ),
                        ListTile(
                          leading: Icon(Icons.info_outline, color: Colors.black),
                          title: Text(localizations.mainView_aboutApp),
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(builder: (context) => AboutAppView()),
                            );
                          },
                        ),
                        ListTile(
                          leading: Icon(Icons.logout, color: Colors.black),
                          title: Text(localizations.mainView_logout),
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
                    color: Colors.grey[200],
                    borderRadius: BorderRadius.circular(12),
                  ),
                  padding: EdgeInsets.all(12),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Row(
                        children: [
                          Icon(Icons.phone, color: Colors.black),
                          SizedBox(width: 8),
                          Text(
                            '(78) 140-27-78',
                            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                          ),
                        ],
                      ),
                      SizedBox(height: 4),
                      Text(
                        localizations.mainView_available24,
                        style: TextStyle(fontSize: 12, color: Colors.grey),
                      ),
                    ],
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

// Пустой виджет для третьей вкладки
class EmptyView extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return SizedBox.shrink();
  }
}
