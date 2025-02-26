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
  List<LatLng> polygonPoints = [];
  LatLng? tempPolygonPoint; // временная точка для полигона

  // Флаг для ручного ввода координат для полигона
  bool showManualPolygonInput = false;

  // --- Поля для рисования линии ---
  List<LatLng> linePoints = [];
  LatLng? tempLinePoint; // временная точка для линии

  // Флаг для ручного ввода координат для линии
  bool showManualLineInput = false;

  final TextEditingController latController = TextEditingController();
  final TextEditingController lngController = TextEditingController();
  final TextEditingController radiusController = TextEditingController();


  MapSelectLocationViewModel({
    required this.routeType,
    dynamic initialCoordinates,
  }) : markerPosition = (routeType == "circle" && initialCoordinates is Map && initialCoordinates['coordinates'] is LatLng)
      ? initialCoordinates['coordinates']
      : (initialCoordinates is LatLng)
      ? initialCoordinates
      : LatLng(41.311081, 69.240562) {
    if (routeType == "polygon" && initialCoordinates is List<LatLng>) {
      polygonPoints = List.from(initialCoordinates);
      isPolygonDrawing = true; // Устанавливаем флаг, чтобы полигон сразу отображался
    } else if (routeType == "line" && initialCoordinates is List<LatLng>) {
      linePoints = List.from(initialCoordinates);
    } else if (routeType == "circle" && initialCoordinates is Map) {
      // Для круга ожидаем Map с 'coordinates' и 'radius'
      markerPosition = initialCoordinates['coordinates'];
      radius = initialCoordinates['radius'];
    }
  }


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

  void toggleManualLineInput() {
    showManualLineInput = !showManualLineInput;
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
      polygonPoints.add(LatLng(lat, lng));
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

  void applyManualLinePoint(BuildContext context) {
    final localizations = AppLocalizations.of(context)!;
    try {
      double lat = double.parse(latController.text.replaceAll(',', '.'));
      double lng = double.parse(lngController.text.replaceAll(',', '.'));
      if (lat < -90 || lat > 90 || lng < -180 || lng > 180) {
        throw const FormatException("Incorrect coordinates");
      }
      linePoints.add(LatLng(lat, lng));
      latController.clear();
      lngController.clear();
      showManualLineInput = false;
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
      tempPolygonPoint = latlng;
    } else if (routeType == "line") {
      // Для линии сразу добавляем точку (она отображается как location_on)
      // и сохраняем её в tempLinePoint для показа флажка с координатами
      tempLinePoint = latlng;
      linePoints.add(latlng);
    } else {
      markerPosition = latlng;
    }
    notifyListeners();
  }

  void confirmTempPolygonPoint() {
    if (tempPolygonPoint != null) {
      polygonPoints.add(tempPolygonPoint!);
      tempPolygonPoint = null;
      notifyListeners();
    }
  }

  void confirmTempLinePoint() {
    tempLinePoint = null;
    notifyListeners();
  }

  void clearLinePoints() {
    linePoints.clear();
    notifyListeners();
  }

  // --- Методы для работы с полигоном ---
  void startPolygonDrawing() {
    isPolygonDrawing = true;
    polygonPoints.clear();
    tempPolygonPoint = null;
    notifyListeners();
  }

  void cancelPolygonDrawing() {
    isPolygonDrawing = false;
    polygonPoints.clear();
    tempPolygonPoint = null;
    notifyListeners();
  }

  void clearPolygonPoints() {
    polygonPoints.clear();
    tempPolygonPoint = null;
    notifyListeners();
  }
}
