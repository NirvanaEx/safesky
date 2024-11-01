import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:flutter_map_tile_caching/flutter_map_tile_caching.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart'; // Импорт локализации

class MapShowLocationView extends StatefulWidget {
  final double latitude;
  final double longitude;
  final double radius; // Радиус в метрах

  const MapShowLocationView({
    Key? key,
    required this.latitude,
    required this.longitude,
    required this.radius,
  }) : super(key: key);

  @override
  _MapShowLocationViewState createState() => _MapShowLocationViewState();
}

class _MapShowLocationViewState extends State<MapShowLocationView> {
  late MapController _mapController;
  LatLng get _markerPosition => LatLng(widget.latitude, widget.longitude);

  @override
  void initState() {
    super.initState();
    _mapController = MapController();
    initializeMapCaching();
  }

  Future<void> initializeMapCaching() async {
    await FlutterMapTileCaching.initialise();
    FMTC.instance('openstreetmap').manage.createAsync();
  }

  String _formatCoordinate(double value) {
    return value.toStringAsFixed(5); // Округляем до 5 знаков после запятой
  }

  Future<void> _animateToMarkerLocation() async {
    LatLng startLocation = _mapController.center;
    double startZoom = _mapController.zoom;
    double startRotation = _mapController.rotation;
    LatLng targetLocation = _markerPosition;
    double targetZoom = 13.0;
    double targetRotation = 0.0;

    const int steps = 30;
    const int delayMilliseconds = 16;

    for (int i = 0; i <= steps; i++) {
      final double lat = startLocation.latitude +
          (targetLocation.latitude - startLocation.latitude) * (i / steps);
      final double lng = startLocation.longitude +
          (targetLocation.longitude - startLocation.longitude) * (i / steps);
      final double zoom = startZoom + (targetZoom - startZoom) * (i / steps);
      final double rotation = startRotation +
          (targetRotation - startRotation) * (i / steps);

      _mapController.moveAndRotate(LatLng(lat, lng), zoom, rotation);
      await Future.delayed(Duration(milliseconds: delayMilliseconds));
    }
  }

  @override
  Widget build(BuildContext context) {
    final localizations = AppLocalizations.of(context); // Доступ к локализации

    return Scaffold(
      appBar: AppBar(
        title: Text('${_formatCoordinate(widget.latitude)}, ${_formatCoordinate(widget.longitude)}'),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 0,
        centerTitle: true,
      ),
      body: Stack(
        children: [
          // Карта с кэшированием тайлов
          FlutterMap(
            mapController: _mapController,
            options: MapOptions(
              center: _markerPosition,
              zoom: 13.0,
              rotation: 0.0,
            ),
            children: [
              TileLayer(
                urlTemplate: 'https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png',
                subdomains: ['a', 'b', 'c'],
                tileProvider: FMTC.instance('openstreetmap').getTileProvider(), // Кэширование
              ),
              // Круглый маркер с фиксированным радиусом и темными цветами
              CircleLayer(
                circles: [
                  CircleMarker(
                    point: _markerPosition,
                    color: Colors.black.withOpacity(0.2), // Темный цвет заливки
                    borderStrokeWidth: 2,
                    borderColor: Colors.black, // Темный цвет границы
                    useRadiusInMeter: true,
                    radius: widget.radius,
                  ),
                  // Маленький круг в центре
                  CircleMarker(
                    point: _markerPosition,
                    color: Colors.black, // Яркий цвет для выделения
                    borderStrokeWidth: 1,
                    borderColor: Colors.black12, // Цвет границы маленького круга
                    useRadiusInMeter: false, // Радиус в пикселях
                    radius: 5, // Маленький радиус для центрального круга
                  ),
                ],
              ),
              // Маркер с текстом радиуса, чтобы он оставался зафиксированным
              // Маркер с текстом радиуса
              MarkerLayer(
                markers: [
                  Marker(
                    width: 120,
                    height: 60, // Увеличиваем высоту для смещения текста
                    point: _markerPosition,
                    builder: (ctx) => Transform.translate(
                      offset: Offset(15, 15), // Смещаем текст вниз на 20 пикселей
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.arrow_back, color: Colors.white, size: 16), // Левая стрелка
                          SizedBox(width: 4),
                          Text(
                            "${widget.radius.toInt()} ${localizations?.m ?? 'm'}",
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              shadows: [
                                Shadow(
                                  blurRadius: 4,
                                  color: Colors.black,
                                  offset: Offset(2, 2),
                                ),
                              ],
                            ),
                          ),
                          SizedBox(width: 4),
                          Icon(Icons.arrow_forward, color: Colors.white, size: 16), // Правая стрелка
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
          // Кнопка для выравнивания карты на метке
          Positioned(
            right: 20,
            bottom: 40,
            child: FloatingActionButton(
              onPressed: _animateToMarkerLocation, // Плавная анимация к метке
              backgroundColor: Colors.black,
              child: Icon(Icons.my_location, color: Colors.white),
            ),
          ),
        ],
      ),
    );
  }
}
