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

    // После рендеринга сразу устанавливаем центр карты на точку плана
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final planCenter = _getPlanCenter(widget.detailModel);
      if (planCenter != null) {
        _mapController.move(planCenter, 13.0); // Сразу перемещаем карту без анимации
      }
    });
  }

  /// Преобразование координаты вида "411751N" в double.
  double _parseCoordinate(String? coord) {
    if (coord == null) return 0.0;
    final match = RegExp(r'^(\d{2,3})(\d{2})(\d{2})([NSEW])$').firstMatch(coord);
    if (match == null) return 0.0;
    final deg = int.parse(match.group(1)!);
    final min = int.parse(match.group(2)!);
    final sec = int.parse(match.group(3)!);
    final dir = match.group(4)!;

    double result = deg + (min / 60) + (sec / 3600);
    if (dir == 'S' || dir == 'W') result = -result;
    return result;
  }

  /// Вычисление центра плана.
  LatLng? _getPlanCenter(PlanDetailModel? detail) {
    if (detail == null || detail.coordList == null || detail.coordList!.isEmpty) return null;

    if (detail.zoneTypeId == 2) {
      double sumLat = 0.0;
      double sumLng = 0.0;
      int count = 0;
      for (final c in detail.coordList!) {
        sumLat += _parseCoordinate(c.latitude);
        sumLng += _parseCoordinate(c.longitude);
        count++;
      }
      return LatLng(sumLat / count, sumLng / count);
    } else {
      final c = detail.coordList!.first;
      return LatLng(_parseCoordinate(c.latitude), _parseCoordinate(c.longitude));
    }
  }

  /// Плавная анимация перемещения к указанной точке.
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

  /// В зависимости от типа зоны (круг, полигон, линия) строим соответствующий слой.
  List<Widget> buildZones(PlanDetailModel? detail) {
    if (detail == null) return [];
    if (detail.zoneTypeId == 1) {
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
      if (detail.coordList != null && detail.coordList!.isNotEmpty) {
        List<LatLng> points = detail.coordList!
            .map((c) => LatLng(_parseCoordinate(c.latitude), _parseCoordinate(c.longitude)))
            .toList();
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
                color: Colors.blueAccent.withOpacity(0.3),
                borderColor: Colors.green,
                borderStrokeWidth: 2,
                isFilled: true,
              ),
            ],
          ),
        ];
      }
    } else if (detail.zoneTypeId == 3) {
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
                color: Colors.green,
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
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final localizations = AppLocalizations.of(context);

    // Выбор URL тайлов в зависимости от темы: dark или light.
    final tileUrlTemplate = isDark
        ? 'https://{s}.basemaps.cartocdn.com/dark_all/{z}/{x}/{y}{r}.png'
        : 'https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png';
    final subdomains = isDark ? ['a', 'b', 'c', 'd'] : ['a', 'b', 'c'];

    return Scaffold(
      appBar: AppBar(
        backgroundColor: theme.appBarTheme.backgroundColor ?? theme.primaryColor,
        elevation: 0,
        centerTitle: true,
      ),
      body: Stack(
        children: [
          FlutterMap(
            mapController: _mapController,
            options: MapOptions(
              center: LatLng(41.0, 69.0),
              zoom: 13.0,
              rotation: 0.0,
            ),
            children: [
              TileLayer(
                urlTemplate: tileUrlTemplate,
                subdomains: subdomains,
                tileProvider: FMTC.instance('openstreetmap').getTileProvider(),
              ),
              ...buildZones(widget.detailModel),
            ],
          ),
          // Кнопка для возвращения к центру зоны
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
              backgroundColor: theme.floatingActionButtonTheme.backgroundColor ?? Colors.black,
              child: Icon(Icons.my_location, color: Colors.white),
            ),
          ),
        ],
      ),
    );
  }
}
