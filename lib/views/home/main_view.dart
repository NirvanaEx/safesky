import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart'; // Импорт локализации
import 'package:safe_sky/views/home/profile_view.dart';
import 'package:safe_sky/views/home/scan_view.dart';
import 'add_request_view.dart';
import 'requests_view.dart';

class MainView extends StatefulWidget {
  @override
  _MainViewState createState() => _MainViewState();
}

class _MainViewState extends State<MainView> {
  int _currentIndex = 0;

  final List<Widget> _screens = [
    RequestsView(),
    AddRequestView(),
    EmptyView(),  // Пустой виджет, который не будет интерактивным
    ProfileView(),
  ];

  void _onTabTapped(int index) {
    if (index == 2) {
      // Открываем ScanView как отдельное окно
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => ScanView()),
      );
    } else {
      // Переключаем вкладку
      setState(() {
        _currentIndex = index;
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
          IconButton(
            icon: Icon(Icons.notifications, color: Colors.black),
            onPressed: () {},
          ),
        ],
      ),
      drawer: _buildDrawer(localizations),
      body: IndexedStack(
        index: _currentIndex,
        children: _screens,
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: _onTabTapped,
        type: BottomNavigationBarType.fixed,
        selectedItemColor: Colors.blue,
        unselectedItemColor: Colors.grey,
        items: [
          BottomNavigationBarItem(
            icon: Icon(Icons.list),
            label: localizations.requests,
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.add),
            label: localizations.add,
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.qr_code_scanner),
            label: localizations.scan,
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person),
            label: localizations.profile,
          ),
        ],
      ),
    );
  }

  Widget _buildDrawer(AppLocalizations localizations) {
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
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '${localizations.hi}, John Doe',
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                    Divider(),
                    ListTile(
                      leading: Icon(Icons.support_agent, color: Colors.black),
                      title: Text(localizations.support),
                      onTap: () {},
                    ),
                    ListTile(
                      leading: Icon(Icons.settings, color: Colors.black),
                      title: Text(localizations.settings),
                      onTap: () {},
                    ),
                    ListTile(
                      leading: Icon(Icons.logout, color: Colors.black),
                      title: Text(localizations.logout),
                      onTap: () {},
                    ),
                  ],
                ),
              ),
              Spacer(),
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
                        localizations.available24,
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
    return SizedBox.shrink();  // Пустое отображение
  }
}
