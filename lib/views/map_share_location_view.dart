import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:slide_to_act/slide_to_act.dart';
import 'package:geolocator/geolocator.dart';
import 'package:flutter_map_tile_caching/flutter_map_tile_caching.dart';
import 'package:lottie/lottie.dart';

class MapShareLocationView extends StatefulWidget {
  @override
  _MapShareLocationViewState createState() => _MapShareLocationViewState();
}

class _MapShareLocationViewState extends State<MapShareLocationView> {
  bool _isSharingLocation = false; // Статус трансляции
  bool _isPaused = false; // Статус паузы трансляции
  late MapController _mapController;


  @override
  void initState() {
    super.initState();
    _mapController = MapController();
  }

  Future<void> _animateToUserLocation() async {
    Position position = await Geolocator.getCurrentPosition(desiredAccuracy: LocationAccuracy.high);
    LatLng userLocation = LatLng(position.latitude, position.longitude);
    LatLng startLocation = _mapController.center;

    // Плавное перемещение от текущей позиции карты к позиции пользователя
    const int steps = 25;
    for (int i = 0; i <= steps; i++) {
      final double lat = startLocation.latitude + (userLocation.latitude - startLocation.latitude) * (i / steps);
      final double lng = startLocation.longitude + (userLocation.longitude - startLocation.longitude) * (i / steps);
      _mapController.move(LatLng(lat, lng), _mapController.zoom);
      await Future.delayed(Duration(milliseconds: 5));
    }
  }

  @override
  Widget build(BuildContext context) {
    final localizations = AppLocalizations.of(context)!;

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Stack(
        children: [
          // OpenStreetMap с использованием flutter_map и кэширования
          FlutterMap(
            mapController: _mapController,
            options: MapOptions(
              center: LatLng(41.2995, 69.2401), // Центр карты, например, Ташкент
              zoom: 13.0,
            ),
            children: [
              TileLayer(
                urlTemplate: "https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png",
                subdomains: ['a', 'b', 'c'],
                tileProvider: FMTC.instance('openstreetmap').getTileProvider(), // Подключаем кэш для тайлов
              ),
            ],
          ),

          // Иконка для поиска моего местоположения, поднятая вверх
          Positioned(
            bottom: _isSharingLocation ? 180 : 120, // Изменено положение при включении трансляции
            right: 20,
            child: FloatingActionButton(
              onPressed: _animateToUserLocation,
              mini: true,
              backgroundColor: Colors.white,
              child: Icon(Icons.my_location, color: Colors.black),
            ),
          ),

          // Нижнее меню
          Positioned(
            bottom: 30,
            left: 20,
            right: 20,
            child: _isSharingLocation ? _buildSharingMenu(localizations) : _buildSlideToStart(localizations),
          ),
        ],
      ),
    );
  }

  // Слайдер для начала трансляции
  Widget _buildSlideToStart(AppLocalizations localizations) {
    return SlideAction(
      text: localizations.startLocationSharing,
      textStyle: TextStyle(
        fontSize: 18,
        color: Colors.black,
      ),
      innerColor: Colors.black,
      outerColor: Colors.white,
      onSubmit: () {
        setState(() {
          _isSharingLocation = true;
          _isPaused = false;
        });
        _startLocationSharing();
      },
      sliderButtonIcon: Icon(
        Icons.play_arrow,
        color: Colors.white,
      ),
      borderRadius: 30,
    );
  }

  // Нижнее меню с кнопками "Завершить" и "Пауза"
  Widget _buildSharingMenu(AppLocalizations localizations) {
    return Column(
      children: [
        // Полупрозрачный контейнер с индикатором "Идет трансляция" и анимацией
        Container(
          height: 55,
          padding: EdgeInsets.symmetric(horizontal: 20, vertical: 12),
          margin: EdgeInsets.only(bottom: 12), // Отступ снизу для разделения
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.85),
            borderRadius: BorderRadius.circular(30),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              if (!_isPaused) // Условие для отображения анимации только при активной трансляции
                SizedBox(
                  width: 35,
                  height: 35,
                  child: Lottie.asset(
                    'assets/json/live.json', // Путь к анимации
                    repeat: true,
                    fit: BoxFit.contain,
                  ),
                ),
              if (_isPaused)
                Icon(
                  Icons.pause, // Иконка паузы
                  color: Colors.red,
                  size: 24,
                ),
              Text(
                _isPaused ? localizations.paused : localizations.sharingLocation,
                style: TextStyle(color: Colors.red, fontSize: 18),
              ),
            ],
          ),
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(
              child: ElevatedButton.icon(
                onPressed: _stopLocationSharing,
                style: ElevatedButton.styleFrom(
                  padding: EdgeInsets.symmetric(vertical: 14),
                  backgroundColor: Colors.black,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30),
                  ),
                ),
                icon: Icon(Icons.stop, color: Colors.white, size: 28),
                label: Text(
                  localizations.stop,
                  style: TextStyle(color: Colors.white, fontSize: 16),
                ),
              ),
            ),
            SizedBox(width: 12),
            Expanded(
              child: ElevatedButton.icon(
                onPressed: _togglePause, // Вызов функции _togglePause
                style: ElevatedButton.styleFrom(
                  padding: EdgeInsets.symmetric(vertical: 14),
                  backgroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30),
                  ),
                ),
                icon: Icon(
                  _isPaused ? Icons.play_arrow : Icons.pause,
                  color: Colors.black,
                  size: 28,
                ),
                label: Text(
                  _isPaused ? localizations.resume : localizations.pause,
                  style: TextStyle(color: Colors.black, fontSize: 16),
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  // Функция для переключения паузы
  void _togglePause() {
    setState(() {
      _isPaused = !_isPaused;
    });
  }

  void _startLocationSharing() {
    print("Location sharing started");
  }

  void _stopLocationSharing() {
    setState(() {
      _isSharingLocation = false;
    });
    print("Location sharing stopped");
  }
}
