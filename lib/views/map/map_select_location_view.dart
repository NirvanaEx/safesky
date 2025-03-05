import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:flutter_map_tile_caching/flutter_map_tile_caching.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import '../../viewmodels/map_select_location_viewmodel.dart';

class MapSelectLocationView extends StatefulWidget {
  final String routeType; // "circle", "polygon" или "line"
  final dynamic initialCoordinates;

  const MapSelectLocationView({
    Key? key,
    required this.routeType,
    this.initialCoordinates,
  }) : super(key: key);

  @override
  _MapSelectLocationViewState createState() => _MapSelectLocationViewState();
}

class _MapSelectLocationViewState extends State<MapSelectLocationView> {
  late final MapController _mapController;
  late final MapSelectLocationViewModel _viewModel;
  bool _actionsExpanded = false;

  static const double markerCircleSize = 10.0;

  @override
  void initState() {
    super.initState();
    _mapController = MapController();
    _viewModel = MapSelectLocationViewModel(
      routeType: widget.routeType,
      initialCoordinates: widget.initialCoordinates,
    );
    _viewModel.addListener(() {
      setState(() {});
    });
    if (widget.routeType == "polygon" && widget.initialCoordinates == null) {
      _viewModel.startPolygonDrawing();
    }
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (widget.routeType == "polygon" && _viewModel.polygonPoints.isNotEmpty) {
        double sumLat = 0, sumLng = 0;
        for (var point in _viewModel.polygonPoints) {
          sumLat += point.latitude;
          sumLng += point.longitude;
        }
        final center = LatLng(sumLat / _viewModel.polygonPoints.length, sumLng / _viewModel.polygonPoints.length);
        _animateMapMovement(center);
      } else if (widget.routeType == "line" && _viewModel.linePoints.isNotEmpty) {
        _animateMapMovement(_viewModel.linePoints.first);
      } else if (_viewModel.markerPosition != null) {
        _animateMapMovement(_viewModel.markerPosition);
      }
    });
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

  void _moveToMarker() {
    _mapController.rotate(0);
    if (widget.routeType == "polygon" && _viewModel.polygonPoints.isNotEmpty) {
      double sumLat = 0, sumLng = 0;
      for (var point in _viewModel.polygonPoints) {
        sumLat += point.latitude;
        sumLng += point.longitude;
      }
      final center = LatLng(sumLat / _viewModel.polygonPoints.length, sumLng / _viewModel.polygonPoints.length);
      _animateMapMovement(center);
    } else if (widget.routeType == "line" && _viewModel.linePoints.isNotEmpty) {
      _animateMapMovement(_viewModel.linePoints.first);
    } else {
      _animateMapMovement(_viewModel.markerPosition);
    }
  }

  // Теперь возвращаем FloatingActionButton для инструментальных кнопок
  Widget _buildToolButton(IconData icon, VoidCallback onPressed) {
    return FloatingActionButton(
      mini: false, // отключаем mini-режим для большего размера
      onPressed: onPressed,
      backgroundColor: Theme.of(context).floatingActionButtonTheme.backgroundColor,
      child: Icon(icon, color: Colors.white, size: 30), // увеличенный размер иконки
    );
  }

  Widget _buildTextField(TextEditingController controller, String hint) {
    return TextField(
      controller: controller,
      keyboardType: const TextInputType.numberWithOptions(decimal: true),
      inputFormatters: [
        FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d*')),
      ],
      decoration: InputDecoration(
        hintText: hint,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: Colors.grey),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: Colors.grey),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide(color: Theme.of(context).primaryColor),
        ),
        contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
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
        color: Theme.of(context).dialogTheme.backgroundColor,
        padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 16),
        child: Row(
          children: [
            Expanded(
              child: _buildTextField(_viewModel.latController, localizations.mapSelectLocationView_latitudeHint),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: _buildTextField(_viewModel.lngController, localizations.mapSelectLocationView_longitudeHint),
            ),
            const SizedBox(width: 8),
            ElevatedButton(
              onPressed: () {
                _viewModel.applyLatLng(context);
                _animateMapMovement(_viewModel.markerPosition);
              },
              style: ElevatedButton.styleFrom(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10), // квадратная кнопка со скруглением 10
                ),
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              ),
              child: Text(localizations.mapSelectLocationView_ok),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildManualLineInput() {
    final localizations = AppLocalizations.of(context)!;
    return Positioned(
      top: 0,
      left: 0,
      right: 0,
      child: Container(
        color: Theme.of(context).dialogTheme.backgroundColor,
        padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 16),
        child: Row(
          children: [
            Expanded(
              child: _buildTextField(_viewModel.latController, localizations.mapSelectLocationView_latitudeHint),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: _buildTextField(_viewModel.lngController, localizations.mapSelectLocationView_longitudeHint),
            ),
            const SizedBox(width: 8),
            ElevatedButton(
              onPressed: () {
                _viewModel.applyManualLinePoint(context);
                if (_viewModel.linePoints.isNotEmpty) {
                  _animateMapMovement(_viewModel.linePoints.last);
                }
              },
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              ),
              child: Text(localizations.mapSelectLocationView_add),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTempPolygonPointConfirmation() {
    final localizations = AppLocalizations.of(context)!;
    return Positioned(
      top: 80,
      left: 0,
      right: 0,
      child: Container(
        color: Theme.of(context).dialogTheme.backgroundColor?.withOpacity(0.7),
        padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 16),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (_viewModel.tempPolygonPoint != null)
              Text(
                '${localizations.mapSelectLocationView_latitudeHint}: ${_viewModel.tempPolygonPoint!.latitude.toStringAsFixed(5)}, '
                    '${localizations.mapSelectLocationView_longitudeHint}: ${_viewModel.tempPolygonPoint!.longitude.toStringAsFixed(5)}',
                style: const TextStyle(fontSize: 16),
              ),
            const SizedBox(width: 8),
            ElevatedButton(
              onPressed: () {
                _viewModel.confirmTempPolygonPoint();
              },
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              ),
              child: Text(localizations.mapSelectLocationView_ok,
                  style: const TextStyle(color: Colors.white)),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTempLinePointConfirmation() {
    final localizations = AppLocalizations.of(context)!;
    return Positioned(
      top: 120,
      left: 0,
      right: 0,
      child: Container(
        color: Theme.of(context).dialogTheme.backgroundColor?.withOpacity(0.7),
        padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 16),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (_viewModel.tempLinePoint != null)
              Text(
                '${localizations.mapSelectLocationView_latitudeHint}: ${_viewModel.tempLinePoint!.latitude.toStringAsFixed(5)}, '
                    '${localizations.mapSelectLocationView_longitudeHint}: ${_viewModel.tempLinePoint!.longitude.toStringAsFixed(5)}',
                style: const TextStyle(fontSize: 16),
              ),
            const SizedBox(width: 8),
            ElevatedButton(
              onPressed: () {
                _viewModel.confirmTempLinePoint();
                if (_viewModel.linePoints.isNotEmpty) {
                  _animateMapMovement(_viewModel.linePoints.last);
                }
              },
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              ),
              child: Text(localizations.mapSelectLocationView_ok,
                  style: const TextStyle(color: Colors.white)),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildManualPolygonInput() {
    final localizations = AppLocalizations.of(context)!;
    return Positioned(
      top: 0,
      left: 0,
      right: 0,
      child: Container(
        color: Theme.of(context).dialogTheme.backgroundColor,
        padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 16),
        child: Row(
          children: [
            Expanded(
              child: _buildTextField(_viewModel.latController, localizations.mapSelectLocationView_latitudeHint),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: _buildTextField(_viewModel.lngController, localizations.mapSelectLocationView_longitudeHint),
            ),
            const SizedBox(width: 8),
            ElevatedButton(
              onPressed: () {
                _viewModel.applyManualPolygonPoint(context);
                if (_viewModel.polygonPoints.isNotEmpty) {
                  _animateMapMovement(_viewModel.polygonPoints.last);
                }
              },
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              ),
              child: Text(localizations.mapSelectLocationView_add),
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
        color: Theme.of(context).dialogTheme.backgroundColor,
        padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 16),
        child: Row(
          children: [
            Expanded(
              child: _buildTextField(_viewModel.radiusController, localizations.mapSelectLocationView_radiusHint),
            ),
            const SizedBox(width: 8),
            ElevatedButton(
              onPressed: () {
                _viewModel.applyRadius(context);
              },
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              ),
              child: Text(localizations.mapSelectLocationView_ok),
            ),
          ],
        ),
      ),
    );
  }

  List<LatLng> _getClosedPolygonPoints(List<LatLng> points) {
    if (points.isEmpty) return points;
    final first = points.first;
    final last = points.last;
    if ((first.latitude - last.latitude).abs() > 1e-6 ||
        (first.longitude - last.longitude).abs() > 1e-6) {
      return List.from(points)..add(first);
    }
    return points;
  }

  @override
  Widget build(BuildContext context) {
    final localizations = AppLocalizations.of(context)!;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(localizations.mapSelectLocationView_appBarTitle),
        elevation: 0,
      ),
      body: Stack(
        children: [
          FlutterMap(
            mapController: _mapController,
            options: MapOptions(
              center: _viewModel.initialPosition,
              zoom: 13.0,
              rotation: 0.0,
              onLongPress: (tapPosition, latlng) {
                _viewModel.onMapLongPress(latlng);
                _animateMapMovement(latlng);
              },
            ),
            children: [
              TileLayer(
                urlTemplate: isDark
                    ? 'https://{s}.basemaps.cartocdn.com/dark_all/{z}/{x}/{y}{r}.png'
                    : 'https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png',
                subdomains: const ['a', 'b', 'c'],
                tileProvider: FMTC.instance('openstreetmap').getTileProvider(),
              ),
              MarkerLayer(
                markers: [
                  // Если routeType circle – метка в виде иконки, цвет зависит от темы
                  if (widget.routeType == "circle")
                    Marker(
                      width: 80.0,
                      height: 80.0,
                      point: _viewModel.markerPosition,
                      builder: (ctx) => Icon(
                        Icons.location_on,
                        color: isDark ? Colors.white : Colors.black,
                        size: 40,
                      ),
                    ),
                  // Для полигона – отрисовываем подтверждённые точки и временную точку
                  if (widget.routeType == "polygon" && _viewModel.isPolygonDrawing)
                    ...([
                      ..._viewModel.polygonPoints.map(
                            (point) => Marker(
                          width: markerCircleSize,
                          height: markerCircleSize,
                          point: point,
                          builder: (ctx) => Container(
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: isDark ? Colors.white : Colors.black,
                            ),
                          ),
                        ),
                      ),
                      if (_viewModel.tempPolygonPoint != null)
                        Marker(
                          width: 80.0,
                          height: 80.0,
                          point: _viewModel.tempPolygonPoint!,
                          builder: (ctx) => Icon(
                            Icons.location_on,
                            color: isDark ? Colors.white : Colors.black,
                            size: 40,
                          ),
                        ),
                    ]),
                  // Для линии аналогично: все точки – маленькие кружки, а последняя – иконка
                  if (widget.routeType == "line")
                    ..._viewModel.linePoints.asMap().entries.map((entry) {
                      int index = entry.key;
                      LatLng point = entry.value;
                      if (index == _viewModel.linePoints.length - 1) {
                        return Marker(
                          width: 80.0,
                          height: 80.0,
                          point: point,
                          builder: (ctx) => Icon(
                            Icons.location_on,
                            color: isDark ? Colors.white : Colors.black,
                            size: 40,
                          ),
                        );
                      } else {
                        return Marker(
                          width: markerCircleSize,
                          height: markerCircleSize,
                          point: point,
                          builder: (ctx) => Container(
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: isDark ? Colors.white : Colors.black,
                            ),
                          ),
                        );
                      }
                    }).toList(),
                ],
              ),
              if (_viewModel.radius != null && widget.routeType == "circle")
                CircleLayer(
                  circles: [
                    CircleMarker(
                      point: _viewModel.markerPosition,
                      color: Colors.blueAccent.withOpacity(0.2),
                      borderStrokeWidth: 2,
                      borderColor: Colors.blueAccent,
                      useRadiusInMeter: true,
                      radius: _viewModel.radius!,
                    ),
                  ],
                ),
              if (widget.routeType == "polygon" &&
                  _viewModel.isPolygonDrawing &&
                  _viewModel.polygonPoints.length >= 3)
                PolygonLayer(
                  polygons: [
                    Polygon(
                      points: _getClosedPolygonPoints(_viewModel.polygonPoints),
                      color: Colors.blueAccent.withOpacity(0.2),
                      borderColor: Colors.blueAccent,
                      borderStrokeWidth: 2,
                      isFilled: true,
                    ),
                  ],
                ),
              if (widget.routeType == "line" && _viewModel.linePoints.isNotEmpty)
                PolylineLayer(
                  polylineCulling: false,
                  polylines: [
                    Polyline(
                      points: _viewModel.linePoints,
                      strokeWidth: 2.0,
                      color: Colors.blueAccent,
                    ),
                  ],
                ),
            ],
          ),
          if (_viewModel.showLatLngInputs &&
              widget.routeType != "polygon" &&
              widget.routeType != "line")
            _buildCoordinateInput(),
          if (_viewModel.showRadiusInput && widget.routeType == "circle")
            _buildRadiusInput(),
          if (widget.routeType == "polygon" &&
              _viewModel.isPolygonDrawing &&
              _viewModel.tempPolygonPoint != null)
            _buildTempPolygonPointConfirmation(),
          if (widget.routeType == "line" && _viewModel.tempLinePoint != null)
            _buildTempLinePointConfirmation(),
          if (widget.routeType == "polygon" && _viewModel.showManualPolygonInput)
            _buildManualPolygonInput(),
          if (widget.routeType == "line" && _viewModel.showManualLineInput)
            _buildManualLineInput(),
          if (widget.routeType == "polygon" &&
              _viewModel.polygonPoints.isNotEmpty &&
              _actionsExpanded)
            Positioned(
              right: 10,
              bottom: 270,
              child: FloatingActionButton(
                onPressed: () {
                  _viewModel.removeLastPolygonPoint();
                },
                child: const Icon(Icons.remove, color: Colors.white),
              ),
            ),
          if (widget.routeType == "polygon" &&
              _viewModel.polygonPoints.isNotEmpty &&
              _actionsExpanded)
            Positioned(
              right: 10,
              bottom: 210,
              child: FloatingActionButton(
                onPressed: () {
                  _viewModel.clearPolygonPoints();
                },
                child: const Icon(Icons.delete, color: Colors.white),
              ),
            ),
          if (widget.routeType == "line" &&
              _viewModel.linePoints.isNotEmpty &&
              _actionsExpanded)
            Positioned(
              right: 10,
              bottom: 270,
              child: FloatingActionButton(
                onPressed: () {
                  _viewModel.removeLastLinePoint();
                },
                child: const Icon(Icons.remove, color: Colors.white),
              ),
            ),
          if (widget.routeType == "line" &&
              _viewModel.linePoints.isNotEmpty &&
              _actionsExpanded)
            Positioned(
              right: 10,
              bottom: 210,
              child: FloatingActionButton(
                onPressed: () {
                  _viewModel.clearLinePoints();
                },
                child: const Icon(Icons.delete, color: Colors.white),
              ),
            ),
          if (_actionsExpanded)
            Positioned(
              right: 10,
              bottom: 150,
              child: FloatingActionButton(
                onPressed: _moveToMarker,
                child: const Icon(Icons.my_location, color: Colors.white),
              ),
            ),
          Positioned(
            right: 10,
            bottom: 90,
            child: FloatingActionButton(
              onPressed: () {
                setState(() {
                  _actionsExpanded = !_actionsExpanded;
                });
              },
              child: Icon(
                _actionsExpanded ? Icons.expand_less : Icons.expand_more,
                color: Colors.white,
              ),
            ),
          ),
          Positioned(
            left: 10,
            bottom: 90,
            child: Column(
              children: [
                if (widget.routeType == "polygon")
                  _buildToolButton(Icons.edit, () {
                    _viewModel.toggleManualPolygonInput();
                  })
                else if (widget.routeType == "circle")
                  _buildToolButton(Icons.circle_outlined, () {
                    _viewModel.toggleRadiusInput();
                  })
                else if (widget.routeType == "line")
                    _buildToolButton(Icons.edit, () {
                      _viewModel.toggleManualLineInput();
                    }),
              ],
            ),
          ),
          Positioned(
            bottom: 20,
            left: 0,
            right: 0,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: widget.routeType == "polygon"
                  ? ElevatedButton(
                onPressed: () {
                  if (_viewModel.polygonPoints.length < 3) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(localizations.mapSelectLocationView_minimumPoints),
                      ),
                    );
                    return;
                  }
                  Navigator.pop(context, {'coordinates': _viewModel.polygonPoints});
                },
                style: ElevatedButton.styleFrom(
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
                child: Text(localizations.mapSelectLocationView_save,
                    style: const TextStyle(color: Colors.white, fontSize: 18)),
              )
                  : widget.routeType == "circle"
                  ? ElevatedButton(
                onPressed: () {
                  Navigator.pop(context, {
                    'coordinates': _viewModel.markerPosition,
                    'radius': _viewModel.radius,
                  });
                },
                style: ElevatedButton.styleFrom(
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
                child: Text(localizations.mapSelectLocationView_save,
                    style: const TextStyle(color: Colors.white, fontSize: 18)),
              )
                  : widget.routeType == "line"
                  ? ElevatedButton(
                onPressed: () {
                  if (_viewModel.linePoints.length < 2) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text(localizations.mapSelectLocationView_minimumLinePoints)),
                    );
                    return;
                  }
                  Navigator.pop(context, {'coordinates': _viewModel.linePoints});
                },
                style: ElevatedButton.styleFrom(
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
                child: Text(localizations.mapSelectLocationView_save,
                    style: const TextStyle(color: Colors.white, fontSize: 18)),
              )
                  : Container(),
            ),
          ),
        ],
      ),
    );
  }
}
