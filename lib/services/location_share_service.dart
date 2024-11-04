import 'dart:async';
import 'dart:convert';
import 'package:geolocator/geolocator.dart';
import 'package:latlong2/latlong.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../config/api_routes.dart';
import '../config/config.dart';
import '../models/location_model.dart';
import '../models/location_share_model.dart';

class LocationShareService {
  bool _isSharingLocation = false;
  String? _currentRequestId;
  LatLng? _lastLocation;
  StreamSubscription<Position>? _positionStreamSubscription;
  Timer? _timer;

  bool get isSharingLocation => _isSharingLocation;

  /// Запуск процесса обмена местоположением
  Future<void> startLocationSharing(String requestId) async {
    _isSharingLocation = true;
    _currentRequestId = requestId;

    // Инициализация подписки на поток изменений местоположения
    _positionStreamSubscription = Geolocator.getPositionStream(
      locationSettings: LocationSettings(accuracy: LocationAccuracy.high, distanceFilter: 5),
    ).listen((Position position) async {
      LatLng currentLatLng = LatLng(position.latitude, position.longitude);
      if (_lastLocation == null || _lastLocation != currentLatLng) {
        _lastLocation = currentLatLng;
        await _updateLocation(requestId);
      }
    });

    // Установка таймера для отправки данных хотя бы раз в минуту
    _timer = Timer.periodic(Duration(minutes: 1), (Timer t) async {
      if (_lastLocation != null) {
        await _updateLocation(requestId);
      }
    });

    print("Location sharing started with requestId: $_currentRequestId");
  }

  /// Остановка процесса обмена местоположением
  Future<void> stopLocationSharing() async {
    _isSharingLocation = false;
    _currentRequestId = null;

    // Отписываемся от потока и останавливаем таймер
    await _positionStreamSubscription?.cancel();
    _timer?.cancel();

    print("Location sharing stopped.");
  }

  /// Метод для обновления местоположения на сервере
  Future<void> _updateLocation(String clientId) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? token = prefs.getString('auth_token');

    // Создаем модель для текущего местоположения
    LocationShareModel locationShareModel = LocationShareModel(
      client: token ?? '',
      location: LocationModel(
        id: _currentRequestId,
        latitude: _lastLocation!.latitude,
        longitude: _lastLocation!.longitude,
      ),
    );

    // Отправка данных на сервер
    try {
      final response = await http.post(
        Uri.parse(ApiRoutes.updateLocation),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': Config.basicAuth,
        },
        body: jsonEncode(locationShareModel.toJson()),
      );

      if (response.statusCode == 200) {
        print("Location successfully sent: ${locationShareModel.toJson()}");
      } else {
        print("Failed to send location. Status: ${response.statusCode}");
      }
    } catch (e) {
      print("Error sending location: $e");
    }
  }

  /// Получает текущее местоположение устройства
  Future<LatLng> getCurrentLocation() async {
    Position position = await Geolocator.getCurrentPosition(desiredAccuracy: LocationAccuracy.high);
    return LatLng(position.latitude, position.longitude);
  }
}
