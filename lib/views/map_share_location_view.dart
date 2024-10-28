import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:slide_to_act/slide_to_act.dart';
import 'package:geolocator/geolocator.dart';
import 'package:flutter_map_tile_caching/flutter_map_tile_caching.dart';

class MapShareLocationView extends StatefulWidget {
  @override
  _MapShareLocationViewState createState() => _MapShareLocationViewState();
}

class _MapShareLocationViewState extends State<MapShareLocationView> with SingleTickerProviderStateMixin {
  bool _isSharingLocation = false; // Статус трансляции
  bool _isPaused = false; // Статус паузы трансляции
  late AnimationController _rippleController;
  late MapController _mapController;

  @override
  void initState() {
    super.initState();
    _rippleController = AnimationController(
      vsync: this,
      duration: Duration(seconds: 2),
    )..repeat(); // Повторяющаяся анимация для ряби

    _mapController = MapController();
  }

  @override
  void dispose() {
    _rippleController.dispose();
    super.dispose();
  }

  void _togglePause() {
    setState(() {
      _isPaused = !_isPaused;
      if (_isPaused) {
        _rippleController.stop();
      } else {
        _rippleController.repeat();
      }
    });
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
          _isPaused = false; // Снимаем паузу, если она была включена
        });
        _rippleController.repeat();
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
        // Полупрозрачный контейнер с индикатором "Идет трансляция" и анимацией ряби
        Container(
          padding: EdgeInsets.symmetric(horizontal: 20, vertical: 12),
          margin: EdgeInsets.only(bottom: 12), // Отступ снизу для разделения
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.85), // Полупрозрачный фон
            borderRadius: BorderRadius.circular(30),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Stack(
                alignment: Alignment.center,
                children: [
                  // Первая волна ряби с использованием Fixed OverflowBox
                  Positioned.fill(
                    child: AnimatedBuilder(
                      animation: _rippleController,
                      builder: (context, child) {
                        return Container(
                          width: 50,
                          height: 50,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: Colors.red.withOpacity(0.5 * (1 - _rippleController.value)),
                          ),
                          child: Transform.scale(
                            scale: 1 + _rippleController.value * 0.8,
                            child: Container(
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: Colors.red.withOpacity(0.2),
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                  Icon(Icons.fiber_manual_record, color: Colors.red, size: 18), // Основная красная точка
                ],
              ),
              SizedBox(width: 10),
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
            // Кнопка "Завершить" с белым фоном и красным текстом
            Expanded(
              child: ElevatedButton.icon(
                onPressed: _stopLocationSharing,
                style: ElevatedButton.styleFrom(
                  padding: EdgeInsets.symmetric(vertical: 14), // Увеличен отступ по вертикали
                  backgroundColor: Colors.black,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30),
                  ),
                ),
                icon: Icon(Icons.stop, color: Colors.white, size: 28), // Увеличен размер иконки
                label: Text(
                  localizations.stop,
                  style: TextStyle(color: Colors.white, fontSize: 16),
                ),
              ),
            ),
            SizedBox(width: 12), // Увеличен промежуток между кнопками
            // Кнопка "Пауза" / "Продолжить" с черной иконкой и без границ
            Expanded(
              child: ElevatedButton.icon(
                onPressed: _togglePause,
                style: ElevatedButton.styleFrom(
                  padding: EdgeInsets.symmetric(vertical: 14), // Увеличен отступ по вертикали
                  backgroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30),
                  ),
                ),
                icon: Icon(
                  _isPaused ? Icons.play_arrow : Icons.pause, // Иконка "Pause" или "Play"
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

  void _startLocationSharing() {
    // Логика для начала трансляции геолокации
    print("Location sharing started");
  }

  void _stopLocationSharing() {
    // Логика для остановки трансляции геолокации
    setState(() {
      _isSharingLocation = false;
      _rippleController.stop();
    });
    print("Location sharing stopped");
  }
}
