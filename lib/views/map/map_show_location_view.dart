import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:flutter_map_tile_caching/flutter_map_tile_caching.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import '../../models/area_point_location_model.dart';
import '../../models/request_model.dart';
import '../../utils/enums.dart';

class MapShowLocationView extends StatefulWidget {
  final RequestModel? requestModel;

  const MapShowLocationView({
    Key? key,
    required this.requestModel,
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

    // Перемещение к первой зеленой зоне при инициализации
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final firstAuthorizedZone = widget.requestModel?.area
          ?.firstWhere((zone) => zone.tag == AreaType.authorizedZone, orElse: () => AreaPointLocationModel());
      if (firstAuthorizedZone != null) {
        final zoneCenter = _getZoneCenter(firstAuthorizedZone);
        if (zoneCenter != null) {
          _animateToMarkerLocation(zoneCenter);
        }
      }
    });
  }

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

  Color _getZoneColor(String? tag) {
    if (tag == AreaType.authorizedZone) {
      return Colors.green;
    } else if (tag == AreaType.noFlyZone) {
      return Colors.red;
    }
    return Colors.blue; // цвет по умолчанию для нераспознанных зон
  }

  LatLng? _getZoneCenter(AreaPointLocationModel zone) {
    if (zone.radius != null && zone.latitude != null && zone.longitude != null) {
      // Если это круг, возвращаем его центр
      return LatLng(zone.latitude!, zone.longitude!);
    } else if (zone.coordinates != null && zone.coordinates!.isNotEmpty) {
      // Если это многоугольник, вычисляем средние координаты
      double avgLatitude = zone.coordinates!.map((coord) => coord.latitude).reduce((a, b) => a + b) / zone.coordinates!.length;
      double avgLongitude = zone.coordinates!.map((coord) => coord.longitude).reduce((a, b) => a + b) / zone.coordinates!.length;
      return LatLng(avgLatitude, avgLongitude);
    }
    return null;
  }

  List<Widget> buildZones(List<AreaPointLocationModel> areas) {
    return [
      PolygonLayer(
        polygons: areas
            .where((zone) => zone.coordinates != null && zone.coordinates!.isNotEmpty)
            .map((zone) {
          List<LatLng> polygonPoints = zone.coordinates!
              .map((coord) => LatLng(coord.latitude, coord.longitude))
              .toList();
          if (polygonPoints.isNotEmpty && polygonPoints.first != polygonPoints.last) {
            polygonPoints.add(polygonPoints.first);
          }
          return Polygon(
            points: polygonPoints,
            color: _getZoneColor(zone.tag).withOpacity(0.4),
            borderColor: _getZoneColor(zone.tag),
            borderStrokeWidth: 2.0,
            isFilled: true,
          );
        }).toList(),
      ),
      CircleLayer(
        circles: areas
            .where((zone) => zone.latitude != null && zone.longitude != null && zone.radius != null)
            .map((zone) => CircleMarker(
          point: LatLng(zone.latitude!, zone.longitude!),
          color: _getZoneColor(zone.tag).withOpacity(0.3),
          borderColor: _getZoneColor(zone.tag),
          borderStrokeWidth: 2,
          useRadiusInMeter: true,
          radius: zone.radius!,
        )).toList(),
      ),
    ];
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
              center: LatLng(41.0, 69.0),
              zoom: 13.0,
              rotation: 0.0,
            ),
            children: [
              TileLayer(
                urlTemplate: 'https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png',
                subdomains: ['a', 'b', 'c'],
                tileProvider: FMTC.instance('openstreetmap').getTileProvider(),
              ),
              ...buildZones(widget.requestModel?.area ?? []),
            ],
          ),

          Positioned(
            right: 20,
            bottom: 40,
            child: FloatingActionButton(
              onPressed: () {
                final firstAuthorizedZone = widget.requestModel?.area
                    ?.firstWhere((zone) => zone.tag == AreaType.authorizedZone, orElse: () => AreaPointLocationModel());
                if (firstAuthorizedZone != null) {
                  final zoneCenter = _getZoneCenter(firstAuthorizedZone);
                  if (zoneCenter != null) {
                    _animateToMarkerLocation(zoneCenter);
                  }
                }
              },
              backgroundColor: Colors.black,
              child: Icon(Icons.my_location, color: Colors.white),
            ),
          ),
        ],
      ),
    );
  }
}
