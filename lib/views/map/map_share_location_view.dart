import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:safe_sky/models/plan_detail_model.dart';
import 'package:slide_to_act/slide_to_act.dart';
import 'package:lottie/lottie.dart';
import 'package:provider/provider.dart';
import '../../viewmodels/map_share_location_viewmodel.dart';
import 'package:flutter_map_tile_caching/flutter_map_tile_caching.dart';
import 'package:flutter_map/flutter_map.dart' as flutter_map;
import '../my_custom_views/my_custom_dialog.dart';

class MapShareLocationView extends StatefulWidget {
  final PlanDetailModel? planDetailModel;

  const MapShareLocationView({Key? key, this.planDetailModel})
      : super(key: key);

  @override
  _MapShareLocationViewState createState() => _MapShareLocationViewState();
}

class _MapShareLocationViewState extends State<MapShareLocationView> {
  late MapController _mapController;

  @override
  void initState() {
    super.initState();
    _mapController = MapController();
    final locationVM =
    Provider.of<MapShareLocationViewModel>(context, listen: false);

    // Передаём модель в ViewModel после первого кадра
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<MapShareLocationViewModel>(context, listen: false)
          .setPlanDetail(widget.planDetailModel!);
    });

    // Загружаем текущую локацию пользователя после построения
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
  double _parseCoordinate(String? coord) {
    if (coord == null) return 0.0;
    final match =
    RegExp(r'^(\d{2,3})(\d{2})(\d{2})([NSEW])$').firstMatch(coord);
    if (match == null) return 0.0;
    final deg = int.parse(match.group(1)!);
    final min = int.parse(match.group(2)!);
    final sec = int.parse(match.group(3)!);
    final dir = match.group(4)!;
    double result = deg + (min / 60) + (sec / 3600);
    if (dir == 'S' || dir == 'W') result = -result;
    return result;
  }

  /// Вычисляем центр плана.
  LatLng? _getPlanCenter() {
    final detail = widget.planDetailModel;
    if (detail == null || detail.coordList == null || detail.coordList!.isEmpty)
      return null;
    if (detail.zoneTypeId == 2) {
      double sumLat = 0, sumLng = 0;
      for (var c in detail.coordList!) {
        sumLat += _parseCoordinate(c.latitude);
        sumLng += _parseCoordinate(c.longitude);
      }
      int count = detail.coordList!.length;
      return LatLng(sumLat / count, sumLng / count);
    } else {
      final c = detail.coordList!.first;
      return LatLng(_parseCoordinate(c.latitude), _parseCoordinate(c.longitude));
    }
  }

  /// Анимация плавного перемещения карты к центру плана.
  Future<void> _animateToPlanCenter(LatLng targetLocation) async {
    LatLng startLocation = _mapController.center;
    double startZoom = _mapController.zoom;
    double targetZoom = 13.0;
    const int steps = 30;
    const int delayMilliseconds = 16;
    for (int i = 0; i <= steps; i++) {
      final double lat = startLocation.latitude +
          (targetLocation.latitude - startLocation.latitude) * (i / steps);
      final double lng = startLocation.longitude +
          (targetLocation.longitude - startLocation.longitude) * (i / steps);
      final double zoom = startZoom + (targetZoom - startZoom) * (i / steps);
      _mapController.moveAndRotate(LatLng(lat, lng), zoom, 0.0);
      await Future.delayed(Duration(milliseconds: delayMilliseconds));
    }
  }

  /// Плавная анимация перемещения карты к текущей локации пользователя.
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

  /// Рисуем область плана (круг, полигон, линия) с использованием значений темы.
  Widget _drawArea() {
    final detail = widget.planDetailModel;
    final theme = Theme.of(context);
    if (detail == null) return const SizedBox();
    if (detail.zoneTypeId == 1) {
      if (detail.coordList != null && detail.coordList!.isNotEmpty) {
        final c = detail.coordList!.first;
        final lat = _parseCoordinate(c.latitude);
        final lng = _parseCoordinate(c.longitude);
        return flutter_map.CircleLayer(
          circles: [
            flutter_map.CircleMarker(
              point: LatLng(lat, lng),
              color: theme.colorScheme.secondary.withOpacity(0.3),
              borderColor: theme.colorScheme.secondary,
              borderStrokeWidth: 2.0,
              radius: (c.radius ?? 0).toDouble(),
              useRadiusInMeter: true,
            )
          ],
        );
      }
    } else if (detail.zoneTypeId == 2) {
      if (detail.coordList != null && detail.coordList!.isNotEmpty) {
        List<LatLng> points = detail.coordList!
            .map((c) =>
            LatLng(_parseCoordinate(c.latitude), _parseCoordinate(c.longitude)))
            .toList();
        if (points.isNotEmpty) {
          final first = points.first;
          final last = points.last;
          if (first.latitude != last.latitude || first.longitude != last.longitude) {
            points.add(first);
          }
        }
        return flutter_map.PolygonLayer(
          polygons: [
            flutter_map.Polygon(
              points: points,
              color: theme.colorScheme.primary.withOpacity(0.3),
              borderColor: theme.colorScheme.primary,
              borderStrokeWidth: 2.0,
              isFilled: true,
            ),
          ],
        );
      }
    } else if (detail.zoneTypeId == 3) {
      if (detail.coordList != null && detail.coordList!.isNotEmpty) {
        List<LatLng> points = detail.coordList!
            .map((c) =>
            LatLng(_parseCoordinate(c.latitude), _parseCoordinate(c.longitude)))
            .toList();
        return flutter_map.PolylineLayer(
          polylines: [
            flutter_map.Polyline(
              points: points,
              strokeWidth: 2.0,
              color: theme.colorScheme.primary,
            ),
          ],
        );
      }
    }
    return const SizedBox();
  }

  /// Кнопка "Свайпнуть чтобы начать" с использованием значений темы.
  Widget _buildSlideToStart(

      AppLocalizations localizations, MapShareLocationViewModel locationVM) {
    final theme = Theme.of(context);

    return SlideAction(
      text: localizations.mapShareLocationView_startLocationSharing,
      textStyle: theme.textTheme.headline6?.copyWith(color: theme.iconTheme.color),
      innerColor: theme.floatingActionButtonTheme.backgroundColor ?? Colors.black,
      outerColor: theme.scaffoldBackgroundColor,
      onSubmit: () {
        final planId = widget.planDetailModel?.planId;
        if (planId != null) {
          locationVM.startLocationSharing(widget.planDetailModel?.uuid ?? '', context);
        } else {
          print("Plan ID is missing. Cannot start location sharing.");
        }
      },
      sliderButtonIcon: Icon(Icons.play_arrow, color: Colors.white),
      borderRadius: 30,
    );
  }

  /// Меню управления sharing с кнопками "Стоп" и "Пауза/Возобновить".
  Widget _buildSharingMenu(
      AppLocalizations localizations, MapShareLocationViewModel locationVM) {
    final theme = Theme.of(context);

    return Column(
      children: [
        Container(
          height: 55,
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
          margin: const EdgeInsets.only(bottom: 12),
          decoration: BoxDecoration(
            color: theme.cardColor.withOpacity(0.85),
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
                Icon(Icons.pause, color: Colors.red, size: 24),
              Text(
                locationVM.isPaused
                    ? localizations.mapShareLocationView_paused
                    : localizations.mapShareLocationView_sharingLocation,
                style: theme.textTheme.headline6?.copyWith(color: Colors.red),
              ),
            ],
          ),
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            // Кнопка "Стоп"
            Expanded(
              child: ElevatedButton.icon(
                onPressed: () async {
                  final confirm = await MyCustomDialog.showOkCancelNotificationDialog(
                    context,
                    localizations.mapShareLocationView_confirmStopLocationSharingTitle,
                    localizations.mapShareLocationView_confirmStopLocationSharingMessage,
                    cancelText: localizations.mapShareLocationView_confirmStopLocationSharingNo,
                    okText: localizations.mapShareLocationView_confirmStopLocationSharingYes,
                  );
                  if (confirm == true) {
                    locationVM.stopLocationSharing(context);
                  }
                },
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  backgroundColor: theme.brightness == Brightness.light
                      ? Colors.black
                      : theme.floatingActionButtonTheme.backgroundColor,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30),
                  ),
                ),
                icon: Icon(Icons.stop, color: Colors.white, size: 28),
                label: Text(
                  localizations.mapShareLocationView_stop,
                  style: theme.textTheme.bodyText1
                      ?.copyWith(color: Colors.white, fontSize: 16),
                ),
              ),
            ),
            const SizedBox(width: 12),
            // Кнопка "Пауза / Возобновить"
            Expanded(
              child: ElevatedButton.icon(
                onPressed: () => locationVM.togglePause(context),
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  backgroundColor: theme.scaffoldBackgroundColor,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30),
                  ),
                ),
                icon: Icon(
                  locationVM.isPaused ? Icons.play_arrow : Icons.pause,
                  color: theme.iconTheme.color,
                  size: 28,
                ),
                label: Text(
                  locationVM.isPaused
                      ? localizations.mapShareLocationView_resume
                      : localizations.mapShareLocationView_pause,
                  style: theme.textTheme.bodyText1
                      ?.copyWith(color: theme.iconTheme.color, fontSize: 16),
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final locationVM = Provider.of<MapShareLocationViewModel>(context);
    final localizations = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final lottieColor = isDark ? Colors.white : Colors.black;

    return Scaffold(
      appBar: AppBar(
        backgroundColor: theme.appBarTheme.backgroundColor ?? theme.primaryColor,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: theme.iconTheme.color),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Stack(
        children: [
          // Карта с динамическим выбором плиток
          FlutterMap(
            mapController: _mapController,
            options: MapOptions(
              center: locationVM.currentLocation ?? LatLng(41.2995, 69.2401),
              zoom: 13.0,
            ),
            children: [
              TileLayer(
                urlTemplate: isDark
                    ? 'https://{s}.basemaps.cartocdn.com/dark_all/{z}/{x}/{y}{r}.png'
                    : 'https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png',
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
                        delegates: LottieDelegates(
                          values: [
                            ValueDelegate.color(['**'], value: lottieColor),
                          ],
                        ),
                      )
                    ),
                  ],
                ),
              // Рисуем зону плана (круг, полигон или линия)
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
                    style: theme.textTheme.bodyText1
                        ?.copyWith(fontSize: 16, color: theme.hintColor),
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
              backgroundColor: isDark ? Colors.blue : Colors.white,
              child: Icon(Icons.my_location,
                  color: isDark ? Colors.white : Colors.black),
            ),
          ),
          // Кнопка для перемещения карты к центру плана
          Positioned(
            bottom: locationVM.isSharingLocation ? 180 : 120,
            left: 20,
            child: FloatingActionButton(
              onPressed: () {
                final planCenter = _getPlanCenter();
                if (planCenter != null) {
                  _animateToPlanCenter(planCenter);
                }
              },
              mini: true,
              backgroundColor: isDark ? Colors.blue : Colors.white,
              child: Icon(Icons.map,
                  color: isDark ? Colors.white : Colors.black),
            ),
          ),
          // Свайп для начала sharing или меню управления
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
}
