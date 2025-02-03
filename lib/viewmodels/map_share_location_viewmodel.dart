import 'package:flutter/material.dart';
import 'package:latlong2/latlong.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/plan_detail_model.dart';
import '../services/location_share_service.dart';
import 'package:flutter_map/flutter_map.dart';

import '../services/notification_service.dart';

class MapShareLocationViewModel extends ChangeNotifier {
  final LocationShareService _locationShareService = LocationShareService();
  PlanDetailModel? _planDetailModel;

  bool _isSharingLocation = false;
  bool _isPaused = false;
  bool _isLoadingLocation = true;
  LatLng? _currentLocation;
  String? _currentUUID;
  final double defaultZoom = 13.0;

  bool get isSharingLocation => _isSharingLocation;
  bool get isPaused => _isPaused;
  bool get isLoadingLocation => _isLoadingLocation;
  LatLng? get currentLocation => _currentLocation;

  PlanDetailModel? get planDetailModel => _planDetailModel;

  void setPlanDetail(PlanDetailModel plan) {
    _planDetailModel = plan;
    notifyListeners();
  }

  void setSharingLocation(bool isSharing) {
    _isSharingLocation = isSharing;
    notifyListeners();
  }

  String? get currentRequestId => _currentUUID;

  void resetLocationSharing() {
    _isSharingLocation = false;
    _currentUUID = null;
    notifyListeners();
  }

  /// Запуск обмена локацией
  ///
  /// КЛЮЧЕВОЕ ИЗМЕНЕНИЕ: используем try-catch, так как сервис может бросить
  /// исключение (если сервер вернёт не 200 при первой отправке).
  Future<void> startLocationSharing(String uuid, BuildContext context) async {
    // Если уже есть активная трансляция, предлагаем её отключить
    if (_isSharingLocation && _currentUUID != null) {
      _showSnackbar(context, "У вас уже запущена трансляция. Остановите её, чтобы начать новую.");
      return;
    }

    _isSharingLocation = true;
    _isPaused = false;
    _currentUUID = uuid;
    notifyListeners();

    try {
      await _locationShareService.startLocationSharing(_currentUUID!);


      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool('is_sharing_location', true);
      await prefs.setString('current_uuid', uuid);
      // Если метод не упал — значит статус 200, всё ок:
      // Вызываем уведомление:
      NotificationService.showLocationSharingNotification(context);

      _showSnackbar(context, "Location sharing started successfully");
    } catch (e) {
      // Если тут ловим ошибку, значит сервер вернул не 200.
      _isSharingLocation = false;
      _currentUUID = null;
      _showSnackbar(context, "Ошибка при старте: $e");
    }

    notifyListeners();
  }

  /// Остановка обмена локацией (серверный вызов + локально)
  ///
  /// КЛЮЧЕВОЕ ИЗМЕНЕНИЕ: сначала отправляем на сервер запрос,
  /// если всё ок (statusCode == 200), тогда локально останавливаем сервис.
  Future<void> stopLocationSharing(BuildContext context) async {
    if (_currentUUID != null) {
      final res = await _locationShareService.stopLocationSharingRequest(_currentUUID!);
      if (res['statusCode'] == 200) {
        // Если сервер вернул 200, останавливаем локальный сервис
        await _locationShareService.stopLocationSharing();
        _isSharingLocation = false;
        _currentUUID = null;

        // Сброс в SharedPreferences
        final prefs = await SharedPreferences.getInstance();
        await prefs.setBool('is_sharing_location', false);
        await prefs.remove('current_uuid');

        // Отменяем уведомление
        NotificationService.cancelNotification();

        _showSnackbar(context, "Location sharing stopped");
      } else {
        // Иначе показываем ошибку, локально не выключаем
        // _showSnackbar(context, "Failed to stop location sharing: ${res['body']}");
        _showSnackbar(context, "Failed to stop location sharing");

      }
      notifyListeners();
    }
  }

  /// Пауза обмена локацией
  ///
  /// КЛЮЧЕВОЕ ИЗМЕНЕНИЕ: если статус != 200, показываем ошибку.
  Future<void> pauseLocationSharing(BuildContext context) async {
    if (_currentUUID != null) {
      final res = await _locationShareService.pauseLocationSharing(_currentUUID!);
      if (res['statusCode'] == 200) {
        _isPaused = true;
        // Отключаем уведомление при паузе:
        NotificationService.cancelNotification();
        _showSnackbar(context, "Location sharing paused");
      } else {
        _showSnackbar(context, "Failed to pause location sharing");
      }
      notifyListeners();
    }
  }

  /// Загрузить текущее местоположение (без отправки на сервер),
  /// чтобы отобразить на карте.
  Future<void> loadCurrentLocation(BuildContext context) async {
    _isLoadingLocation = true;
    notifyListeners();

    _currentLocation = await _locationShareService.getCurrentLocation();
    _isLoadingLocation = false;
    notifyListeners();
  }

  Future<void> animateToLocation(MapController mapController, LatLng targetLocation) async {
    const int steps = 25;
    LatLng startLocation = mapController.center;
    for (int i = 0; i <= steps; i++) {
      final double lat = startLocation.latitude +
          (targetLocation.latitude - startLocation.latitude) * (i / steps);
      final double lng = startLocation.longitude +
          (targetLocation.longitude - startLocation.longitude) * (i / steps);
      mapController.move(LatLng(lat, lng), mapController.zoom);
      await Future.delayed(Duration(milliseconds: 5));
    }
  }

  /// Простой переключатель для демонстрации (пауза / возобновление)
  void togglePause(BuildContext context) {
    _isPaused = !_isPaused;
    notifyListeners();
    _showSnackbar(context, _isPaused ? "Location sharing paused" : "Location sharing resumed");
  }

  void _showSnackbar(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        duration: Duration(seconds: 2),
      ),
    );
  }
}
