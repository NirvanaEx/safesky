import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:latlong2/latlong.dart';
import 'package:workmanager/workmanager.dart';
import 'package:flutter_map/flutter_map.dart';
import '../services/notification_service.dart';
import '../services/location_share_service.dart';

class MapShareLocationViewModel extends ChangeNotifier {
  final LocationShareService _locationShareService = LocationShareService();
  bool _isSharingLocation = false;
  bool _isPaused = false;
  bool _isLoadingLocation = true;
  LatLng? _currentLocation;
  String? _currentRequestId;
  final double defaultZoom = 13.0;

  bool get isSharingLocation => _isSharingLocation;
  bool get isPaused => _isPaused;
  bool get isLoadingLocation => _isLoadingLocation;
  LatLng? get currentLocation => _currentLocation;

  void setSharingLocation(bool isSharing) {
    _isSharingLocation = isSharing;
    notifyListeners();
  }

  String? get currentRequestId => _currentRequestId;

  void resetLocationSharing() {
    _isSharingLocation = false;
    _currentRequestId = null;
    notifyListeners();
  }

  /// Запуск процесса обмена местоположением
  Future<void> startLocationSharing(String requestId) async {
    _isSharingLocation = true;
    _isPaused = false;

    _currentRequestId = requestId;  // Устанавливаем _currentRequestId из переданного requestId
    notifyListeners();

    // Используем `LocationShareService` для запуска обмена местоположением
    await _locationShareService.startLocationSharing(_currentRequestId!);

    // Убедимся, что статус обмена местоположением обновлен после вызова сервиса
    if (!_locationShareService.isSharingLocation) {
      _isSharingLocation = false;
      _currentRequestId = null;
    }

    notifyListeners();
    print("Location sharing started with requestId: $_currentRequestId");
  }

  /// Остановка процесса обмена местоположением
  Future<void> stopLocationSharing() async {
    if (_currentRequestId != null) {
      _isSharingLocation = false;
      notifyListeners();

      await _locationShareService.stopLocationSharing();
      print("Location sharing stopped for requestId: $_currentRequestId");

      _currentRequestId = null;
    }
  }

  /// Загрузка текущего местоположения
  Future<void> loadCurrentLocation() async {
    _isLoadingLocation = true;
    notifyListeners();

    _currentLocation = await _locationShareService.getCurrentLocation();
    _isLoadingLocation = false;
    notifyListeners();
  }

  /// Анимация перемещения к указанному местоположению на карте
  Future<void> animateToLocation(MapController mapController, LatLng targetLocation) async {
    const int steps = 25;
    LatLng startLocation = mapController.center;
    for (int i = 0; i <= steps; i++) {
      final double lat = startLocation.latitude + (targetLocation.latitude - startLocation.latitude) * (i / steps);
      final double lng = startLocation.longitude + (targetLocation.longitude - startLocation.longitude) * (i / steps);
      mapController.move(LatLng(lat, lng), mapController.zoom);
      await Future.delayed(Duration(milliseconds: 5));
    }
  }

  /// Переключение режима паузы для обмена местоположением
  void togglePause() {
    _isPaused = !_isPaused;
    notifyListeners();
  }
}
