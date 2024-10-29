import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:latlong2/latlong.dart';
import 'package:workmanager/workmanager.dart';
import 'package:flutter_map/flutter_map.dart';
import '../services/notification_service.dart';

class LocationViewModel extends ChangeNotifier {
  bool _isSharingLocation = false;
  bool _isPaused = false;
  bool _isLoadingLocation = true;
  LatLng? _currentLocation;
  final double defaultZoom = 13.0; // Уровень зума по умолчанию

  bool get isSharingLocation => _isSharingLocation;
  bool get isPaused => _isPaused;
  bool get isLoadingLocation => _isLoadingLocation;
  LatLng? get currentLocation => _currentLocation;

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

  Future<void> startLocationSharing() async {
    _isSharingLocation = true;
    _isPaused = false;
    notifyListeners();

    NotificationService.showLocationSharingNotification();
    Workmanager().registerPeriodicTask(
      "1",
      "locationSharingTask",
      frequency: Duration(minutes: 15),
    );
    print("Location sharing started");
  }

  Future<void> stopLocationSharing() async {
    _isSharingLocation = false;
    notifyListeners();

    NotificationService.cancelNotification();
    Workmanager().cancelByUniqueName("locationSharingTask");
    print("Location sharing stopped");
  }
}
