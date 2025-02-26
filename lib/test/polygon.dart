import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';

class TestPolygonView extends StatelessWidget {
  const TestPolygonView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Тестовые координаты для полигона (прямоугольник)
    final List<LatLng> polygonPoints = [
      LatLng(41.2975, 69.2560),
      LatLng(41.3075, 69.2560),
      LatLng(41.3075, 69.2660),
      LatLng(41.2975, 69.2660),
    ];

    return Scaffold(
      appBar: AppBar(
        title: const Text('Test Polygon View'),
      ),
      body: FlutterMap(
        options: MapOptions(
          center: LatLng(41.3025, 69.2610),
          zoom: 15.0,
        ),
        children: [
          TileLayer(
            urlTemplate: 'https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png',
            subdomains: const ['a', 'b', 'c'],
          ),
          PolygonLayer(
            polygons: [
              Polygon(
                points: polygonPoints,
                color: Colors.blueAccent.withOpacity(0.2), // внутреннее заполнение
                borderColor: Colors.blueAccent,
                borderStrokeWidth: 2.0,
                isFilled: true
              ),
            ],
          ),
        ],
      ),
    );
  }
}
