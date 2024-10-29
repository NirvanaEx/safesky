import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:workmanager/workmanager.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';

import '../services/notification_service.dart';

class LocationViewModel extends ChangeNotifier {
  bool _isSharingLocation = false;
  bool _isPaused = false;

  bool get isSharingLocation => _isSharingLocation;
  bool get isPaused => _isPaused;

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

  Future<void> animateToUserLocation(MapController mapController) async {
    Position position = await Geolocator.getCurrentPosition(desiredAccuracy: LocationAccuracy.high);
    LatLng userLocation = LatLng(position.latitude, position.longitude);
    LatLng startLocation = mapController.center;

    const int steps = 25;
    for (int i = 0; i <= steps; i++) {
      final double lat = startLocation.latitude + (userLocation.latitude - startLocation.latitude) * (i / steps);
      final double lng = startLocation.longitude + (userLocation.longitude - startLocation.longitude) * (i / steps);
      mapController.move(LatLng(lat, lng), mapController.zoom);
      await Future.delayed(Duration(milliseconds: 5));
    }
  }
}
