import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:flutter_map_tile_caching/flutter_map_tile_caching.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:safe_sky/models/plan_detail_model.dart';


class MapShowLocationView extends StatefulWidget {
  final PlanDetailModel? detailModel;

  const MapShowLocationView({
    Key? key,
    required this.detailModel,
  }) : super(key: key);

  @override
  _MapShowLocationViewState createState() => _MapShowLocationViewState();
}

class _MapShowLocationViewState extends State<MapShowLocationView> {
  late MapController _mapController;

  @override
  void initState() {
    super.initState();
    _mapController = MapController();

    // После рендеринга переходим к центру плана
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final planCenter = _getPlanCenter(widget.detailModel);
      if (planCenter != null) {
        _animateToMarkerLocation(planCenter);
      }
    });
  }

  /// Перевод координат вида 411751N или 0691534E в double
  /// Пример: "411751N" -> 41°17'51" N -> 41.2975 (double)
  double _parseCoordinate(String? coord) {
    if (coord == null) return 0.0;
    final match = RegExp(r'^(\d{2,3})(\d{2})(\d{2})([NSEW])$').firstMatch(coord);
    if (match == null) {
      return 0.0;
    }
    final deg = int.parse(match.group(1)!);
    final min = int.parse(match.group(2)!);
    final sec = int.parse(match.group(3)!);
    final dir = match.group(4)!;

    double result = deg + (min / 60) + (sec / 3600);
    if (dir == 'S' || dir == 'W') {
      result = -result;
    }

    return result;
  }

  /// Определяем центр полёта.
  /// Если zoneTypeId = 1 (круг), берём первую точку.
  /// При появлении полигона можно расширить логику.
  LatLng? _getPlanCenter(PlanDetailModel? detail) {
    if (detail == null || detail.coordList == null || detail.coordList!.isEmpty) return null;

    // Для полигона вычисляем центр как среднее значение всех точек
    if (detail.zoneTypeId == 2) {
      double sumLat = 0.0;
      double sumLng = 0.0;
      int count = 0;
      for (final c in detail.coordList!) {
        double lat = _parseCoordinate(c.latitude);
        double lng = _parseCoordinate(c.longitude);
        sumLat += lat;
        sumLng += lng;
        count++;
      }
      return LatLng(sumLat / count, sumLng / count);
    }
    // Для линии используем первую точку
    else if (detail.zoneTypeId == 3) {
      final c = detail.coordList!.first;
      double lat = _parseCoordinate(c.latitude);
      double lng = _parseCoordinate(c.longitude);
      return LatLng(lat, lng);
    }
    // Для круга (и других типов) используем первую точку
    else {
      final c = detail.coordList!.first;
      double lat = _parseCoordinate(c.latitude);
      double lng = _parseCoordinate(c.longitude);
      return LatLng(lat, lng);
    }
  }

  /// Анимация плавного перемещения
  Future<void> _animateToMarkerLocation(LatLng targetLocation) async {
    LatLng startLocation = _mapController.center;
    double startZoom = _mapController.zoom;
    double startRotation = _mapController.rotation;
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

  /// В зависимости от zoneTypeId строим нужные слои (круг, полигон и т.д.)
  List<Widget> buildZones(PlanDetailModel? detail) {
    if (detail == null) return [];

    if (detail.zoneTypeId == 1) {
      // Если зона – круг
      if (detail.coordList != null && detail.coordList!.isNotEmpty) {
        final c = detail.coordList!.first;
        final lat = _parseCoordinate(c.latitude);
        final lng = _parseCoordinate(c.longitude);

        return [
          CircleLayer(
            circles: [
              CircleMarker(
                point: LatLng(lat, lng),
                color: Colors.green.withOpacity(0.3),
                borderColor: Colors.green,
                borderStrokeWidth: 2,
                useRadiusInMeter: true,
                radius: (c.radius ?? 0).toDouble(),
              ),
            ],
          ),
        ];
      }
    } else if (detail.zoneTypeId == 2) {
      // Если зона – полигон
      if (detail.coordList != null && detail.coordList!.isNotEmpty) {
        List<LatLng> points = detail.coordList!
            .map((c) => LatLng(_parseCoordinate(c.latitude), _parseCoordinate(c.longitude)))
            .toList();
        // Если полигон не замкнут, добавляем первую точку в конец
        if (points.isNotEmpty) {
          final first = points.first;
          final last = points.last;
          if (first.latitude != last.latitude || first.longitude != last.longitude) {
            points.add(first);
          }
        }
        return [
          PolygonLayer(
            polygons: [
              Polygon(
                points: points,
                color: Colors.blueAccent.withOpacity(0.2),
                borderColor: Colors.blueAccent,
                borderStrokeWidth: 2,
              ),
            ],
          ),
        ];
      }
    } else if (detail.zoneTypeId == 3) {
      // Если зона – линия
      if (detail.coordList != null && detail.coordList!.isNotEmpty) {
        List<LatLng> points = detail.coordList!
            .map((c) => LatLng(_parseCoordinate(c.latitude), _parseCoordinate(c.longitude)))
            .toList();
        return [
          PolylineLayer(
            polylines: [
              Polyline(
                points: points,
                strokeWidth: 2.0,
                color: Colors.blueAccent,
              ),
            ],
          ),
        ];
      }
    }
    return [];
  }

  @override
  Widget build(BuildContext context) {
    final localizations = AppLocalizations.of(context);

    return Scaffold(
      appBar: AppBar(
        title: Text('Map'),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 0,
        centerTitle: true,
      ),
      body: Stack(
        children: [
          FlutterMap(
            mapController: _mapController,
            options: MapOptions(
              center: LatLng(41.0, 69.0), // Можно ставить любую точку по умолчанию
              zoom: 13.0,
              rotation: 0.0,
            ),
            children: [
              TileLayer(
                urlTemplate: 'https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png',
                subdomains: ['a', 'b', 'c'],
                tileProvider: FMTC.instance('openstreetmap').getTileProvider(),
              ),
              ...buildZones(widget.detailModel),
            ],
          ),

          // Кнопка, чтобы вернуться к центру зоны
          Positioned(
            right: 20,
            bottom: 40,
            child: FloatingActionButton(
              onPressed: () {
                final planCenter = _getPlanCenter(widget.detailModel);
                if (planCenter != null) {
                  _animateToMarkerLocation(planCenter);
                }
              },
              backgroundColor: Colors.black,
              child: const Icon(Icons.my_location, color: Colors.white),
            ),
          ),
        ],
      ),
    );
  }
}
