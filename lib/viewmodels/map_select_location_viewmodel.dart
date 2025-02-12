import 'package:flutter/material.dart';
import 'package:latlong2/latlong.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class MapSelectLocationViewModel extends ChangeNotifier {
  final String routeType; // "circle", "polygon" или "line"
  final LatLng initialPosition = LatLng(41.311081, 69.240562);
  LatLng markerPosition;
  double? radius;
  bool showLatLngInputs = false;
  bool showRadiusInput = false;

  // --- Поля для рисования полигона ---
  bool isPolygonDrawing = false;
  int? polygonPointsCount; // заданное количество точек (минимум 3)
  List<LatLng> polygonPoints = [];
  LatLng? tempPolygonPoint; // временная точка (устанавливается при долгом нажатии)

  final TextEditingController latController = TextEditingController();
  final TextEditingController lngController = TextEditingController();
  final TextEditingController radiusController = TextEditingController();

  MapSelectLocationViewModel({required this.routeType})
      : markerPosition = LatLng(41.311081, 69.240562);

  void toggleLatLngInputs() {
    showLatLngInputs = !showLatLngInputs;
    notifyListeners();
  }

  void toggleRadiusInput() {
    showRadiusInput = !showRadiusInput;
    notifyListeners();
  }

  void applyLatLng(BuildContext context) {
    final localizations = AppLocalizations.of(context)!;
    try {
      double lat = double.parse(latController.text.replaceAll(',', '.'));
      double lng = double.parse(lngController.text.replaceAll(',', '.'));

      if (lat < -90 || lat > 90 || lng < -180 || lng > 180) {
        throw const FormatException("Incorrect coordinates");
      }

      markerPosition = LatLng(lat, lng);
      showLatLngInputs = false;
      notifyListeners();
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content:
          Text(localizations.mapSelectLocationView_invalidCoordinates),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  void applyRadius(BuildContext context) {
    final localizations = AppLocalizations.of(context)!;
    try {
      double parsedRadius = double.parse(radiusController.text);
      radius = parsedRadius;
      showRadiusInput = false;
      notifyListeners();
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(localizations.mapSelectLocationView_invalidRadius),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  void onMapLongPress(LatLng latlng) {
    // Если включен режим рисования полигона, обновляем временную точку
    if (routeType == "polygon" && isPolygonDrawing) {
      tempPolygonPoint = latlng;
      notifyListeners();
    } else {
      // Иначе обновляем обычную позицию метки
      markerPosition = latlng;
      notifyListeners();
    }
  }

  void handleLineAction() {
    // TODO: Реализовать обработку для линии
    print("Line action triggered");
  }

  // --- Методы для работы с полигоном ---

  /// Запускает режим рисования полигона с заданным количеством точек
  void startPolygonDrawing(int pointsCount) {
    if (pointsCount < 3) return; // минимальное значение – 3
    isPolygonDrawing = true;
    polygonPointsCount = pointsCount;
    polygonPoints.clear();
    tempPolygonPoint = null;
    notifyListeners();
  }

  /// Фиксирует временную точку, добавляя её в список зафиксированных точек
  void confirmTempPolygonPoint() {
    if (tempPolygonPoint != null) {
      polygonPoints.add(tempPolygonPoint!);
      tempPolygonPoint = null;
      notifyListeners();
    }
  }

  /// Сбрасывает режим рисования полигона (для кнопки "Очистить")
  void cancelPolygonDrawing() {
    isPolygonDrawing = false;
    polygonPointsCount = null;
    polygonPoints.clear();
    tempPolygonPoint = null;
    notifyListeners();
  }
}
