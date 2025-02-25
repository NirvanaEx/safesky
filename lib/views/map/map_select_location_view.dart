import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:flutter/services.dart';
import 'package:flutter_map_tile_caching/flutter_map_tile_caching.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import '../../viewmodels/map_select_location_viewmodel.dart';

class MapSelectLocationView extends StatefulWidget {
  final String routeType; // "circle", "polygon" или "line"

  const MapSelectLocationView({Key? key, required this.routeType})
      : super(key: key);

  @override
  _MapSelectLocationViewState createState() => _MapSelectLocationViewState();
}

class _MapSelectLocationViewState extends State<MapSelectLocationView> {
  late final MapController _mapController;
  late final MapSelectLocationViewModel _viewModel;

  @override
  void initState() {
    super.initState();
    _mapController = MapController();
    _viewModel = MapSelectLocationViewModel(routeType: widget.routeType);
    _viewModel.addListener(() {
      setState(() {});
    });
    // Если режим полигона и количество точек ещё не выбрано, сразу показываем диалог
    if (widget.routeType == "polygon" && _viewModel.polygonPointsCount == null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _showPolygonPointsDialog();
      });
    }
  }

  /// Анимированное перемещение карты к целевой позиции
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

  /// При нажатии на местоположение перемещаемся к первой точке (если в режиме полигона и точки есть), иначе к стандартной метке
  void _moveToMarker() {
    _mapController.rotate(0);
    if (widget.routeType == "polygon" && _viewModel.polygonPoints.isNotEmpty) {
      _animateMapMovement(_viewModel.polygonPoints.first);
    } else {
      _animateMapMovement(_viewModel.markerPosition);
    }
  }

  Widget _buildToolButton(IconData icon, VoidCallback onPressed) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 8.0),
      decoration: const BoxDecoration(
        color: Colors.black,
        shape: BoxShape.circle,
      ),
      child: IconButton(
        icon: Icon(icon, color: Colors.white),
        onPressed: onPressed,
      ),
    );
  }

  Widget _buildTextField(
      TextEditingController controller, String hint) {
    return TextField(
      controller: controller,
      keyboardType:
      const TextInputType.numberWithOptions(decimal: true),
      inputFormatters: [
        FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d*')),
      ],
      decoration: InputDecoration(
        hintText: hint,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
        ),
        contentPadding:
        const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      ),
    );
  }

  /// Виджет для ввода координат (используется в режиме circle или для маркера)
  Widget _buildCoordinateInput() {
    final localizations = AppLocalizations.of(context)!;
    return Positioned(
      top: 0,
      left: 0,
      right: 0,
      child: Container(
        color: Colors.white,
        padding:
        const EdgeInsets.symmetric(vertical: 10, horizontal: 16),
        child: Row(
          children: [
            Expanded(
              child: _buildTextField(
                  _viewModel.latController,
                  localizations.mapSelectLocationView_latitudeHint),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: _buildTextField(
                  _viewModel.lngController,
                  localizations.mapSelectLocationView_longitudeHint),
            ),
            const SizedBox(width: 8),
            ElevatedButton(
              onPressed: () {
                _viewModel.applyLatLng(context);
                _animateMapMovement(_viewModel.markerPosition);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.black,
                padding: const EdgeInsets.symmetric(
                    horizontal: 16, vertical: 12),
              ),
              child: Text(localizations.mapSelectLocationView_ok),
            ),
          ],
        ),
      ),
    );
  }

  /// Виджет для ручного ввода точки для полигона
  Widget _buildManualPolygonInput() {
    final localizations = AppLocalizations.of(context)!;
    return Positioned(
      top: 0,
      left: 0,
      right: 0,
      child: Container(
        color: Colors.white,
        padding:
        const EdgeInsets.symmetric(vertical: 10, horizontal: 16),
        child: Row(
          children: [
            Expanded(
              child: _buildTextField(
                  _viewModel.latController,
                  localizations.mapSelectLocationView_latitudeHint),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: _buildTextField(
                  _viewModel.lngController,
                  localizations.mapSelectLocationView_longitudeHint),
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
                backgroundColor: Colors.black,
                padding: const EdgeInsets.symmetric(
                    horizontal: 16, vertical: 12),
              ),
              child: const Text("Добавить"),
            ),
          ],
        ),
      ),
    );
  }

  /// Виджет для подтверждения временной точки полигона (при долгом нажатии)
  Widget _buildTempPolygonPointConfirmation() {
    return Positioned(
      top: 80,
      left: 0,
      right: 0,
      child: Container(
        color: Colors.white70,
        padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 16),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (_viewModel.tempPolygonPoint != null)
              Text(
                'Координата: ${_viewModel.tempPolygonPoint!.latitude.toStringAsFixed(5)}, ${_viewModel.tempPolygonPoint!.longitude.toStringAsFixed(5)}',
                style: const TextStyle(fontSize: 16),
              ),
            const SizedBox(width: 8),
            ElevatedButton(
              onPressed: () {
                _viewModel.confirmTempPolygonPoint();
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.black,
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              ),
              child: const Text('Ok', style: TextStyle(color: Colors.white)),
            ),
          ],
        ),
      ),
    );
  }

  /// Диалог выбора количества точек для полигона
  Future<void> _showPolygonPointsDialog() async {
    int pointsCount = 3; // значение по умолчанию

    await showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Выбор количества точек'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text('Введите количество точек (минимум 3):'),
              const SizedBox(height: 8),
              TextField(
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                  hintText: 'Количество точек',
                ),
                onChanged: (value) {
                  pointsCount = int.tryParse(value) ?? 3;
                },
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                // Если нажали "Отмена" - закрываем диалог и возвращаемся назад
                Navigator.of(context).pop();
                Navigator.of(context).pop();
              },
              child: const Text('Отмена'),
            ),
            ElevatedButton(
              onPressed: () {
                if (pointsCount < 3) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Минимум 3 точки')),
                  );
                  return;
                }
                Navigator.of(context).pop();
                _viewModel.startPolygonDrawing(pointsCount);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Зажимайте на экран чтобы нарисовать область'),
                  ),
                );
              },
              child: const Text('Ok'),
            ),
          ],
        );
      },
    );
  }

  /// Возвращает список точек для полигона, добавляя первую точку в конец (для замыкания), если это необходимо
  List<LatLng> _getClosedPolygonPoints(List<LatLng> points) {
    if (points.isNotEmpty && points.first != points.last) {
      return List.from(points)..add(points.first);
    }
    return points;
  }

  /// Построение нижней кнопки сохранения для всех режимов
  Widget _buildBottomButton() {
    final localizations = AppLocalizations.of(context)!;
    if (widget.routeType == "polygon") {
      return ElevatedButton(
        onPressed: () {
          if (_viewModel.polygonPointsCount == null ||
              _viewModel.polygonPoints.length != _viewModel.polygonPointsCount) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text("Не все точки выбраны")),
            );
            return;
          }
          Navigator.pop(context, {
            'coordinates': _viewModel.polygonPoints,
          });
        },
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.black,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
          padding: const EdgeInsets.symmetric(vertical: 16),
        ),
        child: Text(
          localizations.mapSelectLocationView_save,
          style: const TextStyle(color: Colors.white, fontSize: 18),
        ),
      );
    } else if (widget.routeType == "circle") {
      return ElevatedButton(
        onPressed: () {
          Navigator.pop(context, {
            'coordinates': _viewModel.markerPosition,
            'radius': _viewModel.radius,
          });
        },
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.black,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
          padding: const EdgeInsets.symmetric(vertical: 16),
        ),
        child: Text(
          localizations.mapSelectLocationView_save,
          style: const TextStyle(color: Colors.white, fontSize: 18),
        ),
      );
    } else if (widget.routeType == "line") {
      return ElevatedButton(
        onPressed: () {
          Navigator.pop(context, {
            'coordinates': _viewModel.linePoints,
          });
        },
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.black,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
          padding: const EdgeInsets.symmetric(vertical: 16),
        ),
        child: Text(
          localizations.mapSelectLocationView_save,
          style: const TextStyle(color: Colors.white, fontSize: 18),
        ),
      );
    } else {
      return Container();
    }
  }

  Widget _buildRadiusInput() {
    final localizations = AppLocalizations.of(context)!;

    return Positioned(
      top: 0,
      left: 0,
      right: 0,
      child: Container(
        color: Colors.white,
        padding:
        const EdgeInsets.symmetric(vertical: 10, horizontal: 16),
        child: Row(
          children: [
            Expanded(
              child: _buildTextField(
                  _viewModel.radiusController,
                  localizations.mapSelectLocationView_radiusHint),
            ),
            const SizedBox(width: 8),
            ElevatedButton(
              onPressed: () {
                _viewModel.applyRadius(context);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.black,
                padding: const EdgeInsets.symmetric(
                    horizontal: 16, vertical: 12),
              ),
              child: Text(localizations.mapSelectLocationView_ok),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final localizations = AppLocalizations.of(context)!;
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
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
                urlTemplate: 'https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png',
                subdomains: const ['a', 'b', 'c'],
                tileProvider: FMTC.instance('openstreetmap').getTileProvider(),
              ),
              MarkerLayer(
                markers: [
                  // Для circle: отображаем стандартную метку
                  if (widget.routeType == "circle")
                    Marker(
                      width: 80.0,
                      height: 80.0,
                      point: _viewModel.markerPosition,
                      builder: (ctx) => const Icon(
                        Icons.location_on,
                        color: Colors.black,
                        size: 40,
                      ),
                    ),
                  // Для полигона: формируем список эффективных точек (подтверждённых + временная)
                  if (widget.routeType == "polygon" && _viewModel.isPolygonDrawing)
                    ...(() {
                      // Копируем подтверждённые точки
                      List<LatLng> effectivePoints = List.from(_viewModel.polygonPoints);
                      // Если установлена временная точка, добавляем её
                      if (_viewModel.tempPolygonPoint != null) {
                        effectivePoints.add(_viewModel.tempPolygonPoint!);
                      }
                      // Если число точек достигло лимита, считаем фигуру завершённой
                      bool complete = _viewModel.polygonPointsCount != null &&
                          effectivePoints.length == _viewModel.polygonPointsCount;
                      // Размер кругов (настраиваемый)
                      const double circleSize = 12.0;
                      return List.generate(effectivePoints.length, (index) {
                        final point = effectivePoints[index];
                        // Если фигура не завершена и это последний элемент – показываем location_on
                        if (!complete && index == effectivePoints.length - 1) {
                          return Marker(
                            width: 80.0,
                            height: 80.0,
                            point: point,
                            builder: (ctx) => const Icon(
                              Icons.location_on,
                              color: Colors.black,
                              size: 40,
                            ),
                          );
                        } else {
                          // Иначе отрисовываем круг
                          return Marker(
                            width: circleSize,
                            height: circleSize,
                            point: point,
                            builder: (ctx) => Container(
                              decoration: const BoxDecoration(
                                shape: BoxShape.circle,
                                color: Colors.black,
                              ),
                            ),
                          );
                        }
                      });
                    }()),
                  // Для линии: отображаем добавленные точки
                  if (widget.routeType == "line")
                    ..._viewModel.linePoints.map(
                          (point) => Marker(
                        width: 80.0,
                        height: 80.0,
                        point: point,
                        builder: (ctx) => const Icon(
                          Icons.location_on,
                          color: Colors.black,
                          size: 40,
                        ),
                      ),
                    ),
                ],
              ),
              // Отрисовка круга (для circle режима)
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
              // Если фигура завершена (все точки выбраны) – отрисовываем залитый многоугольник
              if (widget.routeType == "polygon" &&
                  _viewModel.isPolygonDrawing &&
                  _viewModel.polygonPointsCount != null &&
                  _viewModel.polygonPoints.length == _viewModel.polygonPointsCount)
                PolygonLayer(
                  polygons: [
                    Polygon(
                      points: _getClosedPolygonPoints(_viewModel.polygonPoints),
                      color: Colors.blueAccent.withOpacity(0.2),
                      borderColor: Colors.blueAccent,
                      borderStrokeWidth: 2,
                    ),
                  ],
                ),
              // Отрисовка линии (для line режима)
              if (widget.routeType == "line" && _viewModel.linePoints.isNotEmpty)
                PolylineLayer(
                  polylineCulling: false,
                  polylines: [
                    Polyline(
                      points: _viewModel.linePoints,
                      strokeWidth: 4.0,
                      color: Colors.blueAccent,
                    ),
                  ],
                ),
            ],
          ),
          if (_viewModel.showLatLngInputs && widget.routeType != "polygon")
            _buildCoordinateInput(),
          if (_viewModel.showRadiusInput && widget.routeType == "circle")
            _buildRadiusInput(),
          // Если идёт рисование полигона и установлена временная точка – показываем подтверждение
          if (widget.routeType == "polygon" &&
              _viewModel.isPolygonDrawing &&
              _viewModel.tempPolygonPoint != null)
            _buildTempPolygonPointConfirmation(),
          // Если включен ручной ввод для полигона, показываем соответствующий виджет
          if (widget.routeType == "polygon" && _viewModel.showManualPolygonInput)
            _buildManualPolygonInput(),
          // Кнопка "Очистить" для полигона как FloatingActionButton (иконка корзины)
          if (widget.routeType == "polygon" && _viewModel.polygonPoints.isNotEmpty)
            Positioned(
              right: 10,
              bottom: 150,
              child: FloatingActionButton(
                backgroundColor: Colors.black,
                onPressed: () {
                  _viewModel.cancelPolygonDrawing();
                  _showPolygonPointsDialog();
                },
                child: const Icon(Icons.delete, color: Colors.white),
              ),
            ),
          // Левое боковое меню с инструментами
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
                    _buildToolButton(Icons.linear_scale, () {
                      _viewModel.handleLineAction();
                    }),
              ],
            ),
          ),
          // Кнопка выравнивания метки: при нажатии перемещаемся к первой точке (если в режиме полигона)
          Positioned(
            right: 10,
            bottom: 90,
            child: FloatingActionButton(
              onPressed: _moveToMarker,
              backgroundColor: Colors.black,
              child: const Icon(Icons.my_location, color: Colors.white),
            ),
          ),
          // Нижняя кнопка сохранения (для всех режимов)
          Positioned(
            bottom: 20,
            left: 0,
            right: 0,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: _buildBottomButton(),
            ),
          ),
        ],
      ),
    );
  }
}
