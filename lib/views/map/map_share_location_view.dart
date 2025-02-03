import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:safe_sky/models/plan_detail_model.dart';
import 'package:safe_sky/utils/enums.dart';
import 'package:slide_to_act/slide_to_act.dart';
import 'package:lottie/lottie.dart';
import 'package:provider/provider.dart';
import '../../viewmodels/map_share_location_viewmodel.dart';
import 'package:flutter_map_tile_caching/flutter_map_tile_caching.dart';
import 'package:flutter_map/flutter_map.dart' as flutter_map;

class MapShareLocationView extends StatefulWidget {
  final PlanDetailModel? planDetailModel;

  const MapShareLocationView({Key? key, this.planDetailModel}) : super(key: key);

  @override
  _MapShareLocationViewState createState() => _MapShareLocationViewState();
}

class _MapShareLocationViewState extends State<MapShareLocationView> {
  late MapController _mapController;

  @override
  void initState() {
    super.initState();
    _mapController = MapController();

    final locationVM = Provider.of<MapShareLocationViewModel>(context, listen: false);
    // Передача модели в ViewModel при инициализации
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<MapShareLocationViewModel>(context, listen: false)
          .setPlanDetail(widget.planDetailModel!);
    });

    // Откладываем вызов loadCurrentLocation() до момента,
    // когда билд уже завершится
    WidgetsBinding.instance.addPostFrameCallback((_) {
      locationVM.loadCurrentLocation(context);
    });

    locationVM.addListener(() {
      if (locationVM.currentLocation != null && !locationVM.isLoadingLocation) {
        _animateToUserLocation();
      }
    });
  }

  /// Парсим строку вида "411751N" или "0691534E" в double.
  /// Пример: "411751N" -> 41°17'51" N -> 41.2975 (double).
  double _parseCoordinate(String? coord) {
    if (coord == null) return 0.0;
    // Подходит для формата DDMMSS + (N|S|E|W).
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

  /// Плавная анимация карты к текущей локации пользователя.
  Future<void> _animateToUserLocation() async {
    final locationVM =
    Provider.of<MapShareLocationViewModel>(context, listen: false);
    if (locationVM.currentLocation == null) return;

    LatLng startLocation = _mapController.center;
    double startZoom = _mapController.zoom;
    double startRotation = _mapController.rotation;
    LatLng targetLocation = locationVM.currentLocation!;
    double targetZoom = locationVM.defaultZoom;
    double targetRotation = 0.0;

    const int steps = 30;
    const int delayMilliseconds = 16;

    for (int i = 0; i <= steps; i++) {
      final double lat = startLocation.latitude +
          (targetLocation.latitude - startLocation.latitude) * (i / steps);
      final double lng = startLocation.longitude +
          (targetLocation.longitude - startLocation.longitude) * (i / steps);
      final double zoom = startZoom + (targetZoom - startZoom) * (i / steps);
      final double rotation =
          startRotation + (targetRotation - startRotation) * (i / steps);

      _mapController.moveAndRotate(LatLng(lat, lng), zoom, rotation);
      await Future.delayed(Duration(milliseconds: delayMilliseconds));
    }
  }

  /// Рисуем зоны полёта (круг/полигон) на основе PlanDetailModel.
  Widget _drawArea() {
    final detail = widget.planDetailModel;
    if (detail == null) return const SizedBox();

    // Если zoneTypeId = 1 -> круг (радиус от точки)
    if (detail.zoneTypeId == 1) {
      if (detail.coordList != null && detail.coordList!.isNotEmpty) {
        final c = detail.coordList!.first;
        final lat = _parseCoordinate(c.latitude);
        final lng = _parseCoordinate(c.longitude);

        return Stack(
          children: [
            // Отрисовка круга
            flutter_map.CircleLayer(
              circles: [
                flutter_map.CircleMarker(
                  point: LatLng(lat, lng),
                  color: Colors.green.withOpacity(0.3),
                  borderColor: Colors.green,
                  borderStrokeWidth: 2.0,
                  radius: (c.radius ?? 0).toDouble(),
                  useRadiusInMeter: true,
                ),
              ],
            ),
          ],
        );
      }
    }

    // Если в будущем zoneTypeId == 2 — полигон
    // можно будет добавить логику PolygonLayer и проход по всем точкам в coordList.

    // Если данных нет, возвращаем пустой виджет
    return const SizedBox();
  }

  @override
  Widget build(BuildContext context) {
    final locationVM = Provider.of<MapShareLocationViewModel>(context);
    final localizations = AppLocalizations.of(context)!;

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Stack(
        children: [
          // Карта
          FlutterMap(
            mapController: _mapController,
            options: MapOptions(
              center: locationVM.currentLocation ?? LatLng(41.2995, 69.2401),
              zoom: 13.0,
            ),
            children: [
              // Подложка OSM
              TileLayer(
                urlTemplate: "https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png",
                subdomains: ['a', 'b', 'c'],
                tileProvider: FMTC.instance('openstreetmap').getTileProvider(),
              ),
              // Маркер текущей локации пользователя (если доступен)
              if (locationVM.currentLocation != null)
                flutter_map.MarkerLayer(
                  markers: [
                    flutter_map.Marker(
                      width: 25,
                      height: 25,
                      point: locationVM.currentLocation!,
                      builder: (ctx) => Lottie.asset(
                        'assets/json/my_position.json',
                        width: 20,
                        height: 20,
                      ),
                    ),
                  ],
                ),

              // Рисуем круг (или в будущем полигон) из PlanDetailModel
              _drawArea(),
            ],
          ),

          // Прогресс-бар, если геолокация ещё загружается
          if (locationVM.isLoadingLocation)
            Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const CircularProgressIndicator(),
                  const SizedBox(height: 10),
                  Text(
                    localizations.mapShareLocationView_searchingYourLocation,
                    style: const TextStyle(fontSize: 16, color: Colors.grey),
                  ),
                ],
              ),
            ),

          // Кнопка быстрого перехода к текущей позиции
          Positioned(
            bottom: locationVM.isSharingLocation ? 180 : 120,
            right: 20,
            child: FloatingActionButton(
              onPressed: _animateToUserLocation,
              mini: true,
              backgroundColor: Colors.white,
              child: const Icon(Icons.my_location, color: Colors.black),
            ),
          ),

          // В зависимости от состояния sharing показываем SlideAction или меню управления
          Positioned(
            bottom: 30,
            left: 20,
            right: 20,
            child: locationVM.isSharingLocation
                ? _buildSharingMenu(localizations, locationVM)
                : _buildSlideToStart(localizations, locationVM),
          ),
        ],
      ),
    );
  }

  /// Кнопка "Свайпнуть чтобы начать"
  Widget _buildSlideToStart(
      AppLocalizations localizations, MapShareLocationViewModel locationVM) {
    return SlideAction(
      text: localizations.mapShareLocationView_startLocationSharing,
      textStyle: const TextStyle(fontSize: 18, color: Colors.black),
      innerColor: Colors.black,
      outerColor: Colors.white,
      onSubmit: () {
        // Получаем ID плана
        final planId = widget.planDetailModel?.planId;
        if (planId != null) {
          locationVM.startLocationSharing(widget.planDetailModel?.uuid ?? '', context);
        } else {
          print("Plan ID is missing. Cannot start location sharing.");
        }
      },
      sliderButtonIcon: const Icon(Icons.play_arrow, color: Colors.white),
      borderRadius: 30,
    );
  }

  /// Если уже идёт sharing, показываем меню (стоп/пауза)
  Widget _buildSharingMenu(
      AppLocalizations localizations, MapShareLocationViewModel locationVM) {
    return Column(
      children: [
        Container(
          height: 55,
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
          margin: const EdgeInsets.only(bottom: 12),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.85),
            borderRadius: BorderRadius.circular(30),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              if (!locationVM.isPaused)
                SizedBox(
                  width: 35,
                  height: 35,
                  child: Lottie.asset(
                    'assets/json/live.json',
                    repeat: true,
                    fit: BoxFit.contain,
                  ),
                ),
              if (locationVM.isPaused)
                const Icon(Icons.pause, color: Colors.red, size: 24),
              Text(
                locationVM.isPaused
                    ? localizations.mapShareLocationView_paused
                    : localizations.mapShareLocationView_sharingLocation,
                style: const TextStyle(color: Colors.red, fontSize: 18),
              ),
            ],
          ),
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            // Стоп
            Expanded(
              child: ElevatedButton.icon(
                onPressed: () => locationVM.stopLocationSharing(context),
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  backgroundColor: Colors.black,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30),
                  ),
                ),
                icon: const Icon(Icons.stop, color: Colors.white, size: 28),
                label: Text(
                  localizations.mapShareLocationView_stop,
                  style: const TextStyle(color: Colors.white, fontSize: 16),
                ),
              ),
            ),
            const SizedBox(width: 12),
            // Пауза / Возобновить
            Expanded(
              child: ElevatedButton.icon(
                onPressed: () => locationVM.togglePause(context),
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  backgroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30),
                  ),
                ),
                icon: Icon(
                  locationVM.isPaused ? Icons.play_arrow : Icons.pause,
                  color: Colors.black,
                  size: 28,
                ),
                label: Text(
                  locationVM.isPaused
                      ? localizations.mapShareLocationView_resume
                      : localizations.mapShareLocationView_pause,
                  style: const TextStyle(color: Colors.black, fontSize: 16),
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }
}
