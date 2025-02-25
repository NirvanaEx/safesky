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

  // Флаг для ручного ввода координат для полигона
  bool showManualPolygonInput = false;

  // --- Поля для рисования линии ---
  List<LatLng> linePoints = [];

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

  void toggleManualPolygonInput() {
    showManualPolygonInput = !showManualPolygonInput;
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
          content: Text(localizations.mapSelectLocationView_invalidCoordinates),
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

  void applyManualPolygonPoint(BuildContext context) {
    final localizations = AppLocalizations.of(context)!;
    try {
      double lat = double.parse(latController.text.replaceAll(',', '.'));
      double lng = double.parse(lngController.text.replaceAll(',', '.'));

      if (lat < -90 || lat > 90 || lng < -180 || lng > 180) {
        throw const FormatException("Incorrect coordinates");
      }

      if (polygonPointsCount != null &&
          polygonPoints.length >= polygonPointsCount!) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Достигнут лимит точек")),
        );
        return;
      }

      polygonPoints.add(LatLng(lat, lng));
      // Очистить поля ввода
      latController.clear();
      lngController.clear();
      showManualPolygonInput = false;
      notifyListeners();
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(localizations.mapSelectLocationView_invalidCoordinates),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  void onMapLongPress(LatLng latlng) {
    if (routeType == "polygon" && isPolygonDrawing) {
      // Если достигнут лимит точек, новые точки не добавляются
      if (polygonPointsCount != null &&
          polygonPoints.length >= polygonPointsCount!) {
        return;
      }
      tempPolygonPoint = latlng;
    } else if (routeType == "line") {
      linePoints.add(latlng);
    } else {
      markerPosition = latlng;
    }
    notifyListeners();
  }

  void handleLineAction() {
    if (linePoints.isNotEmpty) {
      linePoints.clear();
      notifyListeners();
    }
  }

  // --- Методы для работы с полигоном ---
  void startPolygonDrawing(int pointsCount) {
    if (pointsCount < 3) return;
    isPolygonDrawing = true;
    polygonPointsCount = pointsCount;
    polygonPoints.clear();
    tempPolygonPoint = null;
    notifyListeners();
  }

  void confirmTempPolygonPoint() {
    if (tempPolygonPoint != null) {
      polygonPoints.add(tempPolygonPoint!);
      tempPolygonPoint = null;
      notifyListeners();
    }
  }

  void cancelPolygonDrawing() {
    isPolygonDrawing = false;
    polygonPointsCount = null;
    polygonPoints.clear();
    tempPolygonPoint = null;
    notifyListeners();
  }
}
