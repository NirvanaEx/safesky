import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:flutter/services.dart';
import 'package:flutter_map_tile_caching/flutter_map_tile_caching.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';


class MapSelectLocationView extends StatefulWidget {
  @override
  _MapSelectLocationViewState createState() => _MapSelectLocationViewState();
}

class _MapSelectLocationViewState extends State<MapSelectLocationView> {

  final LatLng initialPosition = LatLng(41.311081, 69.240562); // Координаты для Ташкента
  late MapController _mapController;
  bool _showLatLngInputs = false;
  bool _showRadiusInput = false;
  final TextEditingController _latController = TextEditingController();
  final TextEditingController _lngController = TextEditingController();
  final TextEditingController _radiusController = TextEditingController();
  LatLng _markerPosition = LatLng(41.311081, 69.240562); // Позиция для метки
  double? _radius; // Радиус круга вокруг метки

  @override
  void initState() {
    super.initState();
    _mapController = MapController();
  }

  void _moveToMarker() {
    _mapController.rotate(0);
    _animateMapMovement(_markerPosition);
  }

  void _toggleLatLngInputs() {
    setState(() {
      _showLatLngInputs = !_showLatLngInputs;
    });
  }

  void _toggleRadiusInput() {
    setState(() {
      _showRadiusInput = !_showRadiusInput;
    });
  }

  void _applyLatLng() {
    final localizations = AppLocalizations.of(context)!;

    try {
      double lat = double.parse(_latController.text.replaceAll(',', '.'));
      double lng = double.parse(_lngController.text.replaceAll(',', '.'));

      if (lat < -90 || lat > 90 || lng < -180 || lng > 180) {
        throw const FormatException("Incorrect coordinates");
      }

      setState(() {
        _markerPosition = LatLng(lat, lng);
        _showLatLngInputs = false;
      });

      _animateMapMovement(_markerPosition);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(localizations.mapSelectLocationView_invalidCoordinates),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  void _applyRadius() {
    final localizations = AppLocalizations.of(context)!;

    try {
      double radius = double.parse(_radiusController.text);
      setState(() {
        _radius = radius;
        _showRadiusInput = false;
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(localizations.mapSelectLocationView_invalidRadius),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  void _onMapLongPress(TapPosition tapPosition, LatLng latlng) {
    setState(() {
      _markerPosition = latlng;
    });
    _animateMapMovement(latlng);
  }

  void _animateMapMovement(LatLng targetPosition) {
    const duration = Duration(milliseconds: 500);
    final startLat = _mapController.center.latitude;
    final startLng = _mapController.center.longitude;
    final deltaLat = targetPosition.latitude - startLat;
    final deltaLng = targetPosition.longitude - startLng;
    const steps = 60;
    final stepDuration = duration.inMilliseconds ~/ steps;
    int currentStep = 0;

    Timer.periodic(Duration(milliseconds: stepDuration), (timer) {
      if (currentStep >= steps) {
        timer.cancel();
        return;
      }
      currentStep++;
      double newLat = startLat + (deltaLat * (currentStep / steps));
      double newLng = startLng + (deltaLng * (currentStep / steps));
      _mapController.move(LatLng(newLat, newLng), _mapController.zoom);
    });
  }

  Widget _buildToolButton(IconData icon, VoidCallback onPressed) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 8.0),
      decoration: BoxDecoration(
        color: Colors.black,
        shape: BoxShape.circle,
      ),
      child: IconButton(
        icon: Icon(icon, color: Colors.white),
        onPressed: onPressed,
      ),
    );
  }

  Widget _buildCoordinateInput() {
    final localizations = AppLocalizations.of(context)!;

    return Positioned(
      top: 0,
      left: 0,
      right: 0,
      child: Container(
        color: Colors.white,
        padding: EdgeInsets.symmetric(vertical: 10, horizontal: 16),
        child: Row(
          children: [
            Expanded(
              child: _buildTextField(_latController, localizations.mapSelectLocationView_latitudeHint),
            ),
            SizedBox(width: 8),
            Expanded(
              child: _buildTextField(_lngController, localizations.mapSelectLocationView_longitudeHint),
            ),
            SizedBox(width: 8),
            ElevatedButton(
              onPressed: _applyLatLng,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.black,
                padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              ),
              child: Text(localizations.mapSelectLocationView_ok),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRadiusInput() {
    final localizations = AppLocalizations.of(context)!;

    return Positioned(
      top: 0,
      left: 0,
      right: 0,
      child: Container(
        color: Colors.white,
        padding: EdgeInsets.symmetric(vertical: 10, horizontal: 16),
        child: Row(
          children: [
            Expanded(
              child: _buildTextField(_radiusController, localizations.mapSelectLocationView_radiusHint),
            ),
            SizedBox(width: 8),
            ElevatedButton(
              onPressed: _applyRadius,
              child: Text("ОК"),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.black,
                padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTextField(TextEditingController controller, String hint) {
    return TextField(
      controller: controller,
      keyboardType: TextInputType.numberWithOptions(decimal: true),
      inputFormatters: [
        FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d*')),
      ],
      decoration: InputDecoration(
        hintText: hint,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
        ),
        contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final localizations = AppLocalizations.of(context)!;

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(localizations.mapSelectLocationView_appBarTitle),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 0,
      ),
      body: Stack(
        children: [
          // Карта с кэшированием тайлов
          FlutterMap(
            mapController: _mapController,
            options: MapOptions(
              center: initialPosition,
              zoom: 13.0,
              rotation: 0.0,
              onLongPress: _onMapLongPress,
            ),
            children: [
              TileLayer(
                urlTemplate: 'https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png',
                subdomains: ['a', 'b', 'c'],
                tileProvider: FMTC.instance('openstreetmap').getTileProvider(), // Используем кэширование
              ),
              MarkerLayer(
                markers: [
                  Marker(
                    width: 80.0,
                    height: 80.0,
                    point: _markerPosition,
                    builder: (ctx) => Icon(Icons.location_on, color: Colors.black, size: 40),
                  ),
                ],
              ),
              if (_radius != null) // Рисуем круг только если радиус задан
                CircleLayer(
                  circles: [
                    CircleMarker(
                      point: _markerPosition,
                      color: Colors.blueAccent.withOpacity(0.2), // Устанавливаем цвет
                      borderStrokeWidth: 2,
                      borderColor: Colors.blueAccent,
                      useRadiusInMeter: true,
                      radius: _radius!,
                    ),
                  ],
                ),
            ],
          ),
          if (_showLatLngInputs) _buildCoordinateInput(),
          if (_showRadiusInput) _buildRadiusInput(),
          // Панель инструментов внизу слева
          Positioned(
            left: 10,
            bottom: 90,
            child: Column(
              children: [
                _buildToolButton(Icons.edit, _toggleLatLngInputs),
                _buildToolButton(Icons.circle_outlined, _toggleRadiusInput),
              ],
            ),
          ),
          // Кнопка выравнивания на текущей позиции метки
          Positioned(
            right: 10,
            bottom: 90,
            child: FloatingActionButton(
              onPressed: _moveToMarker,
              backgroundColor: Colors.black,
              child: Icon(Icons.my_location, color: Colors.white),
            ),
          ),
          // Кнопка "Сохранить" внизу
          Positioned(
            bottom: 20,
            left: 0,
            right: 0,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: ElevatedButton(
                onPressed: () {
                  Navigator.pop(context, {
                    'coordinates': _markerPosition,
                    'radius': _radius,
                  });
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.black,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
                  padding: EdgeInsets.symmetric(vertical: 16),
                ),
                child: Text(
                  localizations.mapSelectLocationView_save,
                  style: TextStyle(color: Colors.white, fontSize: 18),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
