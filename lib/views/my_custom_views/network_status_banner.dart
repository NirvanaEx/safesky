import 'dart:async';
import 'package:flutter/material.dart';
import 'package:connectivity_plus/connectivity_plus.dart';

class NetworkStatusBanner extends StatefulWidget {
  @override
  _NetworkStatusBannerState createState() => _NetworkStatusBannerState();
}

class _NetworkStatusBannerState extends State<NetworkStatusBanner> {
  ConnectivityResult _connectionStatus = ConnectivityResult.none;
  late StreamSubscription<ConnectivityResult> _subscription;
  bool _showGreenBanner = false;

  @override
  void initState() {
    super.initState();
    // Узнаём первоначальное состояние подключения
    Connectivity().checkConnectivity().then((result) {
      setState(() {
        _connectionStatus = result;
      });
    });
    // Подписываемся на изменения подключения
    _subscription = Connectivity().onConnectivityChanged.listen((result) {
      if (result == ConnectivityResult.none) {
        // Нет подключения: показываем красный баннер
        setState(() {
          _connectionStatus = result;
          _showGreenBanner = false;
        });
      } else {
        // Подключение восстановлено: показываем зелёный баннер на 2 секунды
        setState(() {
          _connectionStatus = result;
          _showGreenBanner = true;
        });
        Future.delayed(Duration(seconds: 2), () {
          if (mounted && _connectionStatus != ConnectivityResult.none) {
            setState(() {
              _showGreenBanner = false;
            });
          }
        });
      }
    });
  }

  @override
  void dispose() {
    _subscription.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_connectionStatus == ConnectivityResult.none) {
      return Container(
        width: double.infinity,
        color: Colors.red,
        padding: EdgeInsets.symmetric(vertical: 8),
        child: SafeArea(
          bottom: false,
          child: Center(
            child: Text(
              "Нет подключения к сети",
              style: TextStyle(color: Colors.white),
            ),
          ),
        ),
      );
    } else if (_showGreenBanner) {
      return Container(
        width: double.infinity,
        color: Colors.green,
        padding: EdgeInsets.symmetric(vertical: 8),
        child: SafeArea(
          bottom: false,
          child: Center(
            child: Text(
              "Сеть доступна",
              style: TextStyle(color: Colors.white),
            ),
          ),
        ),
      );
    } else {
      return SizedBox.shrink();
    }
  }
}
