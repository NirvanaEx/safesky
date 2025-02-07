import 'dart:async';
import 'dart:convert';
import 'package:geolocator/geolocator.dart';
import 'package:latlong2/latlong.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

import '../config/api_routes.dart';
import '../config/config.dart';
import 'auth_service.dart';

class LocationShareService {
  bool _isSharingLocation = false;
  String? _currentUUID;
  LatLng? _lastLocation;
  StreamSubscription<Position>? _positionStreamSubscription;
  Timer? _timer;

  bool get isSharingLocation => _isSharingLocation;

  /// Возвращает токен из SharedPreferences.
  Future<String?> _getToken() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getString('auth_token');
  }

  /// Универсальная обёртка для запросов с авторизацией.
  /// Если получен ответ с кодом 401, пытаемся обновить токен через AuthService
  /// и повторяем запрос, проверяя, что новый токен не равен null.
  Future<http.Response> _makeAuthorizedRequest(
      Future<http.Response> Function(String token) requestFunc) async {
    String? token = await _getToken();
    if (token == null || token.isEmpty) {
      throw Exception('No authentication token found');
    }
    var response = await requestFunc(token);
    if (response.statusCode == 401) {
      // Пытаемся обновить токен через AuthService
      bool refreshed = await AuthService().tokenRefresh();
      if (!refreshed) {
        throw Exception('Unauthorized and failed to refresh token');
      }
      token = await _getToken();
      if (token == null || token.isEmpty) {
        throw Exception('Token is null after refresh');
      }
      response = await requestFunc(token);
    }
    return response;
  }

  /// Запуск процесса обмена местоположением.
  /// После установки флага _isSharingLocation делается первый запрос на сервер,
  /// чтобы проверить статус. Если статус не 200 – процесс прерывается.
  Future<void> startLocationSharing(String uuid) async {
    _isSharingLocation = true;
    _currentUUID = uuid;

    // Получаем начальную позицию
    Position initialPosition = await Geolocator.getCurrentPosition(
      desiredAccuracy: LocationAccuracy.high,
    );

    // Устанавливаем _lastLocation на начальную позицию
    _lastLocation = LatLng(initialPosition.latitude, initialPosition.longitude);

    final startResponse = await _updateLocation(
      _currentUUID!,
      initialPosition.accuracy,
    );

    if (startResponse['statusCode'] != 200) {
      _isSharingLocation = false;
      _currentUUID = null;
      await _positionStreamSubscription?.cancel();
      _timer?.cancel();

      throw Exception(
        'Не удалось начать передачу локации: ${startResponse['body']}',
      );
    }

    // Подписываемся на поток обновлений местоположения
    _positionStreamSubscription = Geolocator.getPositionStream(
      locationSettings: LocationSettings(
        accuracy: LocationAccuracy.high,
        distanceFilter: 5,
      ),
    ).listen((Position position) async {
      LatLng currentLatLng = LatLng(position.latitude, position.longitude);
      if (_lastLocation == null || _lastLocation != currentLatLng) {
        _lastLocation = currentLatLng;
        await _updateLocation(_currentUUID ?? '', position.accuracy);
      }
    });

    // Запускаем таймер для периодической отправки
    _timer = Timer.periodic(Duration(minutes: 1), (Timer t) async {
      if (_lastLocation != null) {
        Position position = await Geolocator.getCurrentPosition();
        await _updateLocation(_currentUUID ?? '', position.accuracy);
      }
    });

    print("Location sharing started with requestId: $_currentUUID");
  }

  /// Остановка процесса обмена местоположением (локально).
  /// Отключает таймер и поток без отправки запроса на сервер.
  Future<void> stopLocationSharing() async {
    _isSharingLocation = false;
    _currentUUID = null;

    await _positionStreamSubscription?.cancel();
    _timer?.cancel();

    print("Location sharing stopped (local).");
  }

  /// Метод для обновления местоположения на сервере.
  /// Возвращает Map со статусом и телом ответа.
  Future<Map<String, dynamic>> _updateLocation(String uuid, double accuracy) async {
    Map<String, dynamic> locationData = {
      "uuid": uuid,
      "latitude": _lastLocation?.latitude,
      "longitude": _lastLocation?.longitude,
      "accuracy": accuracy,
    };

    try {
      final response = await _makeAuthorizedRequest((token) async {
        return await http.post(
          Uri.parse(ApiRoutes.updateLocation),
          headers: {
            'Content-Type': 'application/json',
            'Authorization': 'Bearer $token',
          },
          body: jsonEncode(locationData),
        );
      });

      final decodedResponse = utf8.decode(response.bodyBytes);

      if (response.statusCode == 200) {
        print("Location successfully sent: ${jsonEncode(locationData)}");
      } else {
        print("Failed to send location. Status: ${response.statusCode}");
      }

      return {
        'statusCode': response.statusCode,
        'body': decodedResponse,
      };
    } catch (e) {
      print("Error sending location: $e");
      return {
        'statusCode': 500,
        'body': "Error: $e",
      };
    }
  }

  /// Приостановка обмена локацией (запрос к серверу).
  /// Возвращает Map со статусом и телом ответа.
  Future<Map<String, dynamic>> pauseLocationSharing(String uuid) async {
    try {
      final response = await _makeAuthorizedRequest((token) async {
        return await http.post(
          Uri.parse(ApiRoutes.pauseLocation),
          headers: {
            'Authorization': 'Bearer $token',
          },
          body: {"uuid": uuid},
        );
      });

      return {
        'statusCode': response.statusCode,
        'body': utf8.decode(response.bodyBytes),
      };
    } catch (e) {
      print("Error pausing location sharing: $e");
      return {
        'statusCode': 500,
        'body': "Error: $e",
      };
    }
  }

  /// Остановка обмена локацией (запрос к серверу).
  /// Возвращает Map со статусом и телом ответа.
  Future<Map<String, dynamic>> stopLocationSharingRequest(String uuid) async {
    try {
      final response = await _makeAuthorizedRequest((token) async {
        return await http.post(
          Uri.parse(ApiRoutes.stopLocation),
          headers: {
            'Authorization': 'Bearer $token',
          },
          body: {"uuid": uuid},
        );
      });

      return {
        'statusCode': response.statusCode,
        'body': utf8.decode(response.bodyBytes),
      };
    } catch (e) {
      print("Error stopping location sharing: $e");
      return {
        'statusCode': 500,
        'body': "Error: $e",
      };
    }
  }

  /// Получает текущее местоположение устройства (без отправки на сервер).
  Future<LatLng> getCurrentLocation() async {
    Position position = await Geolocator.getCurrentPosition(
      desiredAccuracy: LocationAccuracy.high,
    );
    return LatLng(position.latitude, position.longitude);
  }
}
