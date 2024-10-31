import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:latlong2/latlong.dart';
import 'package:workmanager/workmanager.dart';
import 'package:flutter_map/flutter_map.dart';
import '../services/notification_service.dart';

class MapShareLocationViewModel extends ChangeNotifier {
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

  Future<void> startLocationSharing() async {
    _isSharingLocation = true;
    _isPaused = false;

    // Инициализируем requestId для отслеживания задачи
    _currentRequestId = 'unique_location_sharing_task';

    notifyListeners();

    NotificationService.showLocationSharingNotification();
    Workmanager().registerPeriodicTask(
      _currentRequestId!, // Используем _currentRequestId для отслеживания
      "locationSharingTask",
      frequency: Duration(minutes: 15),
    );
    print("Location sharing started with requestId: $_currentRequestId");
  }

  Future<void> stopLocationSharing() async {
    if (_currentRequestId != null) {
      _isSharingLocation = false; // Устанавливаем в false при остановке
      notifyListeners();

      NotificationService.cancelNotification();
      Workmanager().cancelByUniqueName(_currentRequestId!);
      print("Location sharing stopped for requestId: $_currentRequestId");

      _currentRequestId = null;
    }
  }

  Future<void> loadCurrentLocation() async {
    _isLoadingLocation = true;
    notifyListeners();

    Position position = await Geolocator.getCurrentPosition(desiredAccuracy: LocationAccuracy.high);
    _currentLocation = LatLng(position.latitude, position.longitude);

    _isLoadingLocation = false;
    notifyListeners();
  }

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

  void togglePause() {
    _isPaused = !_isPaused;
    notifyListeners();
  }
}