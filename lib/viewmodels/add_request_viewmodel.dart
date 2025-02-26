import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:latlong2/latlong.dart';
import 'package:safe_sky/models/prepare_model.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../models/district_model.dart';
import '../models/plan_detail_model.dart';
import '../models/region_model.dart';
import '../models/request.dart';

import '../services/request_service.dart';

import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class AddRequestViewModel extends ChangeNotifier {
  final RequestService requestService = RequestService();
  late BuildContext _buildContext;

  bool isLoading = false;  // Флаг загрузки данных
  bool coordinatesExpanded = false;

  // Текстовые контроллеры для полей ввода
  final TextEditingController requesterNameController = TextEditingController();
  final TextEditingController operatorPhoneController = TextEditingController();
  final TextEditingController applicationNumController = TextEditingController();

  final TextEditingController emailController = TextEditingController();
  final TextEditingController noteController = TextEditingController();
  final TextEditingController latLngController = TextEditingController();
  final TextEditingController radiusController = TextEditingController();
  final TextEditingController flightHeightController = TextEditingController(); // Контроллер для высоты полета
  final TextEditingController startDateController = TextEditingController(); // Контроллер для даты начала
  final TextEditingController flightStartDateControllerTime = TextEditingController(); // Контроллер для времени начала полета
  final TextEditingController flightEndDateTimeController = TextEditingController(); // Контроллер для времени окончания полета
  final TextEditingController permitNumberController = TextEditingController();
  final TextEditingController contractNumberController = TextEditingController();

  final TextEditingController landmarkController = TextEditingController();
  final TextEditingController customPurposeController = TextEditingController();

  // Добавьте в начало класса
  List<TextEditingController> operatorPhoneControllers = [];
  List<TextEditingController> manualPhoneControllers = [];


  List<String> routeTypeOptions = [
    "circle",
    "polygon",
    "line"
  ];
  String selectedRouteType = "circle";

  List<Bpla> bplaList = [];
  List<String> purposeList = [];


  ///NEW
  List<Operator> operatorList = [];
  List<Permission> permissionList = [];
  List<String> agreementList = [];
  // Списки для регионов и районов
  List<RegionModel> regionList = [];
  List<DistrictModel> districtList = [];

  // Переменные для работы с датами
  DateTime? startDate;
  DateTime? endDate;
  DateTime? flightStartDateTime;
  DateTime? flightEndDateTime;
  DateTime? permitDate;
  DateTime? contractDate;

  // Поля для выпадающих списков
  List<Bpla> selectedBplas = [];
  String? selectedPurpose;
  List<Operator> selectedOperators = [];
  // Выбранные регион и район
  RegionModel? selectedRegion;
  DistrictModel? selectedDistrict;

  String selectedCountryCode = "+998";


  PrepareData? prepareData;

  // Доступные страны
  final List<Map<String, String>> countries = [
    {"code": "+998", "flag": "🇺🇿"},
    // {"code": "+1", "flag": "🇺🇸"},
    // {"code": "+44", "flag": "🇬🇧"},
    // {"code": "+7", "flag": "🇷🇺"},
    // {"code": "+997", "flag": "🇰🇿"},
  ];

  String? errorMessage;

  // Функция для преобразования координаты из DMS в десятичное число
  double dmsToDecimal(String dms) {
    final direction = dms[dms.length - 1];
    final numericPart = dms.substring(0, dms.length - 1);
    int degrees;
    int minutes;
    double seconds;

    if (direction == 'N' || direction == 'S') {
      // Ожидается формат: ddmmss(.sss)?
      degrees = int.parse(numericPart.substring(0, 2));
      minutes = int.parse(numericPart.substring(2, 4));
      seconds = double.parse(numericPart.substring(4));
    } else {
      // Для долготы ожидается формат: dddmmss(.sss)?
      degrees = int.parse(numericPart.substring(0, 3));
      minutes = int.parse(numericPart.substring(3, 5));
      seconds = double.parse(numericPart.substring(5));
    }
    double decimal = degrees + minutes / 60 + seconds / 3600;
    if (direction == 'S' || direction == 'W') {
      decimal = -decimal;
    }
    return decimal;
  }

  Future<void> autoFillWithPlanDetail(PlanDetailModel planDetail, BuildContext context) async {
    final localizations = AppLocalizations.of(context)!;

    // Обновляем дату начала
    updateStartDate(context, DateTime.now().add(Duration(days: 1)));

    // Заполнение текстовых полей
    requesterNameController.text = planDetail.applicant ?? '';
    emailController.text = planDetail.email ?? '';
    noteController.text = planDetail.notes ?? '';
    landmarkController.text = planDetail.flightArea ?? '';

    // Заполнение полей разрешения и договора
    permitNumberController.text = planDetail.permission != null
        ? "${planDetail.permission!.orgName} ${planDetail.permission!.docNum} ${planDetail.permission!.docDate != null ? DateFormat('dd.MM.yyyy').format(planDetail.permission!.docDate!) : ''}"
        : '';
    contractNumberController.text = planDetail.agreement != null
        ? "${planDetail.agreement!.docNum} ${planDetail.agreement!.docDate != null ? DateFormat('dd.MM.yyyy').format(planDetail.agreement!.docDate!) : ''}"
        : '';

    // Установка времени полёта (если есть)
    if (planDetail.timeFrom != null) {
      DateTime now = DateTime.now();
      try {
        final parts = planDetail.timeFrom!.split(":");
        flightStartDateTime = DateTime(now.year, now.month, now.day, int.parse(parts[0]), int.parse(parts[1]));
        flightStartDateControllerTime.text = DateFormat('dd.MM.yyyy HH:mm').format(flightStartDateTime!);
      } catch (_) {}
    }
    if (planDetail.timeTo != null) {
      DateTime now = DateTime.now();
      try {
        final parts = planDetail.timeTo!.split(":");
        flightEndDateTime = DateTime(now.year, now.month, now.day, int.parse(parts[0]), int.parse(parts[1]));
        flightEndDateTimeController.text = DateFormat('dd.MM.yyyy HH:mm').format(flightEndDateTime!);
      } catch (_) {}
    }

    // Установка выбранного региона и загрузка списка районов
    if (planDetail.regionCode != null && regionList.isNotEmpty) {
      try {
        final region = regionList.firstWhere((region) => region.code == planDetail.regionCode);
        selectedRegion = region;
        notifyListeners();
        // Ждём загрузки списка районов для выбранной области
        await loadDistricts(region.code);
      } catch (e) {
        // Если регион не найден, сбрасываем регион и район
        selectedRegion = null;
        districtList = [];
        selectedDistrict = null;
      }
    } else {
      // Если regionCode отсутствует или список регионов пуст
      selectedRegion = null;
      districtList = [];
      selectedDistrict = null;
    }

    // Установка выбранного района после загрузки списка районов
    if (planDetail.districtCode != null && districtList.isNotEmpty) {
      try {
        selectedDistrict = districtList.firstWhere((district) => district.code == planDetail.districtCode);
      } catch (e) {
        selectedDistrict = null;
      }
    } else {
      selectedDistrict = null;
    }

    // Заполнение координат и радиуса с учетом типа маршрута
    if (planDetail.coordList.isNotEmpty) {
      if (planDetail.zoneTypeId == 1) {
        // Для круга
        selectedRouteType = "circle";
        final coord = planDetail.coordList.first;
        if (coord.latitude != null && coord.longitude != null) {
          final latStr = coord.latitude!;
          final lngStr = coord.longitude!;
          double latitude = (latStr.endsWith('N') || latStr.endsWith('S'))
              ? dmsToDecimal(latStr)
              : double.tryParse(latStr) ?? 0.0;
          double longitude = (lngStr.endsWith('E') || lngStr.endsWith('W'))
              ? dmsToDecimal(lngStr)
              : double.tryParse(lngStr) ?? 0.0;
          latLngController.text = "${latitude.toStringAsFixed(5)} ${longitude.toStringAsFixed(5)}";
        }
        if (coord.radius != null) {
          radiusController.text = coord.radius.toString();
        }
      } else if (planDetail.zoneTypeId == 2 || planDetail.zoneTypeId == 3) {
        // Для полигона (zoneTypeId == 2) или линии (zoneTypeId == 3)
        selectedRouteType = planDetail.zoneTypeId == 2 ? "polygon" : "line";
        String formatted = planDetail.coordList.map((coord) {
          double latitude = (coord.latitude != null &&
              (coord.latitude!.endsWith('N') || coord.latitude!.endsWith('S')))
              ? dmsToDecimal(coord.latitude!)
              : double.tryParse(coord.latitude ?? '') ?? 0.0;
          double longitude = (coord.longitude != null &&
              (coord.longitude!.endsWith('E') || coord.longitude!.endsWith('W')))
              ? dmsToDecimal(coord.longitude!)
              : double.tryParse(coord.longitude ?? '') ?? 0.0;
          return '${latitude.toStringAsFixed(5)} ${longitude.toStringAsFixed(5)}';
        }).join(";\n");
        latLngController.text = formatted;
        // Для полигона и линии поле радиуса не используется
        radiusController.clear();
      }
    }

    // Заполнение высоты полёта
    if (planDetail.mAltitude != null) {
      flightHeightController.text = planDetail.mAltitude.toString();
    }

    // Автовыбор БПЛА
    selectedBplas = bplaList.where((bpla) =>
        planDetail.bplaList.any((b) => b.id == bpla.id)
    ).toList();
    setBpla(selectedBplas);

    // Автовыбор операторов
    selectedOperators = operatorList.where((op) =>
        planDetail.operatorList.any((pOp) => pOp.id == op.id)
    ).toList();
    setOperators(selectedOperators);

    // Заполнение цели полёта с проверкой наличия в списке
    if (purposeList.contains(planDetail.purpose)) {
      selectedPurpose = planDetail.purpose;
      customPurposeController.clear();
    } else {
      selectedPurpose = localizations.addRequestView_other;
      customPurposeController.text = planDetail.purpose ?? '';
      if (!purposeList.contains(localizations.addRequestView_other)) {
        purposeList.add(localizations.addRequestView_other);
      }
    }

    notifyListeners();
  }




  Future<void> initializeData(BuildContext context, String planDate) async {
    final localizations = AppLocalizations.of(context)!;

    await Future.delayed(const Duration(milliseconds: 500));  // Симуляция загрузки данных
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? applicant = prefs.getString('applicant');

    await loadPrepare(planDate);
    requesterNameController.text = applicant ?? '';
    // applicationNumController.text = prepareData?.applicationNum.toString() ?? '-';
    emailController.text = prepareData?.email ?? '';
    bplaList = prepareData!.bplaList;
    operatorList = prepareData!.operatorList;
    purposeList = prepareData!.purposeList;
    if (!purposeList.contains(localizations.addRequestView_other)) {
      purposeList.add(localizations.addRequestView_other);
    }
    permitNumberController.text = "${prepareData?.permission?.orgName} ${prepareData!.permission?.docNum} ${prepareData!.permission?.docDate}";
    contractNumberController.text = "${prepareData!.agreement?.docNum} ${prepareData!.agreement?.docDate}";
    notifyListeners();
  }

  dynamic getCurrentCoordinates() {
    if (selectedRouteType == "circle") {
      if (latLngController.text.trim().isEmpty || radiusController.text.trim().isEmpty) return null;
      final parts = latLngController.text.trim().split(" ");
      if (parts.length != 2) return null;
      double? lat = double.tryParse(parts[0]);
      double? lng = double.tryParse(parts[1]);
      double? rad = double.tryParse(radiusController.text.trim());
      if (lat != null && lng != null && rad != null) {
        return {
          'coordinates': LatLng(lat, lng),
          'radius': rad,
        };
      }
    } else if (selectedRouteType == "polygon" || selectedRouteType == "line") {
      if (latLngController.text.trim().isEmpty) return null;
      List<LatLng> points = [];
      List<String> pointStrings = latLngController.text
          .trim()
          .split(";")
          .where((s) => s.trim().isNotEmpty)
          .toList();
      for (String point in pointStrings) {
        List<String> parts =
        point.trim().split(" ").where((s) => s.trim().isNotEmpty).toList();
        if (parts.length != 2) continue;
        double? lat = double.tryParse(parts[0]);
        double? lng = double.tryParse(parts[1]);
        if (lat != null && lng != null) {
          points.add(LatLng(lat, lng));
        }
      }
      return points;
    }
    return null;
  }


  // Метод загрузки списка регионов
  Future<void> loadRegions() async {
    try {
      regionList = await requestService.fetchRegions();
      notifyListeners();
    } catch (e) {
      print("Error fetching regions: $e");
      errorMessage = "Ошибка при получении регионов";
      notifyListeners();
    }
  }

  // Метод загрузки списка районов по коду региона
  Future<void> loadDistricts(String regionCode) async {
    try {
      districtList = await requestService.fetchDistricts(regionCode);
      notifyListeners();
    } catch (e) {
      print("Error fetching districts: $e");
      errorMessage = "Ошибка при получении районов";
      notifyListeners();
    }
  }

  //  Метод для обновления выбранного типа маршрута
  void setSelectedRouteType(String routeType) {
    selectedRouteType = routeType;
    latLngController.clear();
    radiusController.clear();
    notifyListeners();
  }

  // Установка выбранного региона (и автоматическая загрузка районов для него)
  void setSelectedRegion(RegionModel region) {
    selectedRegion = region;
    loadDistricts(region.code);
    // Сброс выбранного района, чтобы избежать конфликта, если район отсутствует для нового региона
    selectedDistrict = null;
    notifyListeners();
  }

  // Установка выбранного района
  void setSelectedDistrict(DistrictModel district) {
    selectedDistrict = district;
    notifyListeners();
  }

  Future<void> loadPrepare(String planDate) async {
    prepareData = await requestService.fetchPrepareData(planDate);
    await loadRegions();
    notifyListeners();
  }

  // Методы обновления даты
  Future<void> updateStartDate(BuildContext context, DateTime date) async {
    _buildContext = context;
    startDate = date;
    isLoading = true;
    errorMessage = null;  // Очистка предыдущих ошибок
    notifyListeners();  // Уведомляем UI об изменении состояния

    try {
      // Форматируем дату в нужный формат (yyyy-MM-dd)
      String formattedDate = DateFormat('yyyy-MM-dd').format(date);

      await initializeData(context, formattedDate);
    } catch (e) {
      errorMessage = "Ошибка загрузки данных: ${e.toString()}";
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(errorMessage!),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      isLoading = false;
      notifyListeners();  // Обновляем UI
    }

    startDateController.text = DateFormat('dd.MM.yyyy').format(date);
  }




  String formatPhoneNumber(String phoneNumber) {
    final countryCode = '+998';
    if (phoneNumber.startsWith(countryCode)) {
      return phoneNumber.replaceFirst(countryCode, '').trim();
    }
    return phoneNumber;
  }



  void updateDateField(DateTime date, TextEditingController controller) {
    // Устанавливаем отформатированную дату в контроллер
    controller.text = DateFormat('dd.MM.yyyy').format(date);
    notifyListeners(); // Обновляем интерфейс
  }

// В add_request_viewmodel.dart, измените метод updateCoordinatesAndRadius:
  void updateCoordinatesAndRadius(dynamic coordinates, double? radius) {
    if (selectedRouteType == "circle") {
      latLngController.text = '${(coordinates as LatLng).latitude.toStringAsFixed(5)} ${(coordinates as LatLng).longitude.toStringAsFixed(5)}';
      radiusController.text = radius != null ? radius.toStringAsFixed(0) : '';
    } else if (selectedRouteType == "polygon" || selectedRouteType == "line") {
      List<LatLng> points = coordinates as List<LatLng>;
      String formatted = points
          .map((point) => '${point.latitude.toStringAsFixed(5)} ${point.longitude.toStringAsFixed(5)};')
          .join('\n');
      latLngController.text = formatted;
    }
    notifyListeners();
  }



  void updateFlightStartDateTime(DateTime date) {
    flightStartDateTime = date;
    flightStartDateControllerTime.text = DateFormat('dd.MM.yyyy HH:mm').format(date);
    notifyListeners();
  }

  void updateFlightEndDateTime(DateTime date) {
    flightEndDateTime = date;
    flightEndDateTimeController.text = DateFormat('dd.MM.yyyy HH:mm').format(date);
    notifyListeners();
  }



  void setBpla(List<Bpla> bplas) {
    selectedBplas = bplas;
    notifyListeners();
  }



  void setPurpose(String purpose) {
    selectedPurpose = purpose;
    if (purpose != "Другое") {
      customPurposeController.clear();
    }
    notifyListeners();
  }

  void setOperators(List<Operator> operators) {
    selectedOperators = operators;
    // Пересобираем контроллеры для номеров телефонов от выбранных операторов
    operatorPhoneControllers.clear();
    for (var op in selectedOperators) {
      operatorPhoneControllers.add(TextEditingController(text: op.phone));
    }
    notifyListeners();
  }

  // Метод для добавления/удаления оператора по одиночному выбору
  void toggleOperatorSelection(Operator operator) {
    if (selectedOperators.contains(operator)) {
      selectedOperators.remove(operator);
    } else {
      selectedOperators.add(operator);
    }
    notifyListeners();
  }

  // Получение списка ID операторов
  List<int> get selectedOperatorIds =>
      selectedOperators
          .map((operator) => operator.id)
          .whereType<int>() // Исключаем null значения
          .toList();


  // Метод для получения списка ID из списка Bpla
  List<int> get selectedBplaIds =>
      selectedBplas.map((bpla) => bpla.id).whereType<int>().toList();


  Future<Map<String, String>?> submitRequest(BuildContext context) async {
    final localizations = AppLocalizations.of(context);

    // Проверка даты начала
    if (startDate == null) {
      return {'status': 'error', 'message': localizations?.addRequestView_invalidStartDate ?? "Invalid start date"};
    }


    // // Проверка номера заявки
    // if (applicationNumController.text.trim().isEmpty) {
    //   return {'status': 'error', 'message': localizations?.addRequestView_invalidApplicationNumber ?? "Application number cannot be empty"};
    // }

    // Проверка выбора БПЛА
    if (selectedBplas.isEmpty) {
      return {'status': 'error', 'message': localizations?.addRequestView_invalidBpla ?? "Please select at least one BPLA"};
    }


    // Проверка времени начала полета
    if (flightStartDateTime == null) {
      return {'status': 'error', 'message': localizations?.addRequestView_invalidFlightStartDateTime ?? "Invalid flight start date"};
    }

    // Проверка времени окончания полета
    if (flightEndDateTime == null) {
      return {'status': 'error', 'message': localizations?.addRequestView_invalidFlightEndDateTime ?? "Invalid flight end date"};
    }

    // Проверка времени начала полета
    if (landmarkController.text.isEmpty ) {
      return {'status': 'error', 'message': localizations?.addRequestView_invalidLandmark ?? "Invalid flight area"};
    }

    if (selectedDistrict == null) {
      return {
        'status': 'error',
        'message': localizations?.addRequestView_invalidDistrict ?? "Please select a district"
      };
    }


    // Проверка высоты полета
    double? flightHeight = double.tryParse(flightHeightController.text);
    if (flightHeight == null) {
      return {'status': 'error', 'message': localizations?.addRequestView_invalidFlightHeight ?? "Invalid flight height"};
    }

    // Новый блок проверки координат и формирования coordList
    List<dynamic> coordList;
    if (selectedRouteType == "circle") {
      // Проверка радиуса
      double? radius = double.tryParse(radiusController.text);
      if (radius == null || radius <=0) {
        return {'status': 'error', 'message': localizations?.addRequestView_invalidRadius ?? "Invalid radius"};
      }

      // Для круга ожидается одна точка (широта и долгота), радиус парсится без обязательной проверки
      List<String> latLngParts = latLngController.text.trim().split(" ");
      if (latLngParts.length != 2) {
        return {
          'status': 'error',
          'message': localizations?.addRequestView_invalidLatLngFormat ?? "Invalid coordinates format"
        };
      }
      double? latitude = double.tryParse(latLngParts[0]);
      double? longitude = double.tryParse(latLngParts[1]);
      if (latitude == null || longitude == null) {
        return {
          'status': 'error',
          'message': localizations?.addRequestView_invalidLatitudeLongitude ?? "Invalid latitude/longitude"
        };
      }
      // Для круга радиус не проверяем – если не парсится, берем 0
      int circleRadius = int.tryParse(radiusController.text) ?? 0;
      coordList = [
        {
          "latitude": _formatLatitude(latitude),
          "longitude": _formatLongitude(longitude),
          "radius": circleRadius,
        }
      ];
    } else if (selectedRouteType == "polygon" || selectedRouteType == "line") {
      if (latLngController.text.trim().isEmpty) {
        return {
          'status': 'error',
          'message': localizations?.addRequestView_invalidLatLngFormat ?? "Coordinates cannot be empty"
        };
      }
      // Разбиваем строку по символу ';' и удаляем пустые элементы
      List<String> pointStrings = latLngController.text
          .trim()
          .split(";")
          .where((s) => s.trim().isNotEmpty)
          .toList();
      int minPoints = selectedRouteType == "polygon" ? 3 : 2;
      if (pointStrings.length < minPoints) {
        String errorMsg = selectedRouteType == "polygon"
            ? (localizations?.addRequestView_invalidPolygonPoints ?? "Please provide at least 3 points for polygon")
            : (localizations?.addRequestView_invalidLinePoints ?? "Please provide at least 2 points for line");
        return {'status': 'error', 'message': errorMsg};
      }
      coordList = [];
      for (String point in pointStrings) {
        List<String> parts = point.trim().split(" ").where((s) => s.trim().isNotEmpty).toList();
        if (parts.length != 2) {
          return {
            'status': 'error',
            'message': localizations?.addRequestView_invalidLatLngFormat ?? "Invalid coordinates format"
          };
        }
        double? lat = double.tryParse(parts[0]);
        double? lng = double.tryParse(parts[1]);
        if (lat == null || lng == null) {
          return {
            'status': 'error',
            'message': localizations?.addRequestView_invalidLatitudeLongitude ?? "Invalid latitude/longitude"
          };
        }
        coordList.add({
          "latitude": _formatLatitude(lat),
          "longitude": _formatLongitude(lng),
        });
      }
      // Если это полигон, добавляем первую координату в конец (если она ещё не совпадает с последней)
      if (selectedRouteType == "polygon" && coordList.isNotEmpty) {
        Map<String, dynamic> firstPoint = coordList.first;
        Map<String, dynamic> lastPoint = coordList.last;
        if (firstPoint["latitude"] != lastPoint["latitude"] ||
            firstPoint["longitude"] != lastPoint["longitude"]) {
          coordList.add(firstPoint);
        }
      }
    } else {
      return {'status': 'error', 'message': "Unknown route type"};
    }


    // Проверка выбора цели полета
    if (selectedPurpose == null) {
      return {'status': 'error', 'message': localizations?.addRequestView_invalidPurpose ?? "Please select purpose"};
    }
    if (selectedPurpose == "Другое" && customPurposeController.text.trim().isEmpty) {
      return {'status': 'error', 'message': localizations?.addRequestView_invalidPurpose ?? "Please enter flight purpose"};
    }
    // Проверка выбора операторов
    if (selectedOperators.isEmpty) {
      return {'status': 'error', 'message': localizations?.addRequestView_invalidOperators ?? "Please select at least one operator"};
    }

    // Проверка номера телефона
    List<String> phoneNumbers = [];
    phoneNumbers.addAll(operatorPhoneControllers.map((c) => c.text.trim()).where((text) => text.isNotEmpty));
    phoneNumbers.addAll(manualPhoneControllers.map((c) => c.text.trim()).where((text) => text.isNotEmpty));
    if (phoneNumbers.isEmpty) {
      return {'status': 'error', 'message': localizations?.addRequestView_invalidPhoneNumber ?? "Invalid phone number"};
    }
    String phoneNumbersString = phoneNumbers.join(', ');

    // Проверка email
    String email = emailController.text;
    if (email.isEmpty || !RegExp(r"^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$").hasMatch(email)) {
      return {'status': 'error', 'message': localizations?.addRequestView_invalidEmail ?? "Invalid email"};
    }




    SharedPreferences prefs = await SharedPreferences.getInstance();
    int? userId = prefs.getInt('userId');

    int zoneTypeId = selectedRouteType == "circle"
        ? 1
        : (selectedRouteType == "polygon" ? 2 : 3);

    // Формируем JSON объект вручную
    Map<String, dynamic> requestBody = {
      // "applicationNum": applicationNumController.text,
      "planDate": startDate?.toIso8601String() ?? '',
      "timeFrom": formatTimeToHHmm(flightStartDateTime),
      "timeTo": formatTimeToHHmm(flightEndDateTime),
      "flightArea": landmarkController.text,
      "districtCode": selectedDistrict?.code,
      "zoneTypeId": zoneTypeId,
      "purpose": selectedPurpose ==  localizations?.addRequestView_other ? customPurposeController.text : selectedPurpose,
      "bplaList": selectedBplas.isNotEmpty ? selectedBplaIds : [],
      "operatorList": selectedOperators.isNotEmpty
          ? (selectedOperatorIds.contains(userId) ? selectedOperatorIds : selectedOperatorIds + [userId ?? 0])
          : [],
      "coordList": coordList,
      "notes": noteController.text.isNotEmpty ? noteController.text : null,
      "operatorPhones": phoneNumbersString,
      "email": emailController.text.isNotEmpty ? emailController.text : null,
      "mAltitude": int.tryParse(flightHeightController.text) ?? 0,
    };

    // Логируем сформированные данные
    print("Submitting BPLA Plan: ${jsonEncode(requestBody)}");

    try {
      final response = await requestService.submitBplaPlan(requestBody);
      if (response['status'] == 200) {
        final jsonData = response['data'];
        int appNum = jsonData['applicationNum'];
        print("BPLA Plan submitted successfully: ${jsonEncode(requestBody)}");
        clearFields();
        return {
          'status': 'success',
          'message': localizations!.addRequestView_requestSentSuccess,
          'applicationNum': appNum.toString(),  // добавляем номер заявки в результат
        };
      } else {
        return {'status': 'error', 'message': response['message']};
      }
    } catch (e) {
      return {'status': 'error', 'message': localizations!.addRequestView_sendError};
    }

  }

  String formatTimeToHHmm(DateTime? dateTime) {
    if (dateTime == null) return '';
    return DateFormat('HH:mm').format(dateTime);
  }



  String _formatLatitude(double latitude) {
    int degrees = latitude.abs().toInt();
    double minutesDecimal = (latitude.abs() - degrees) * 60;
    int minutes = minutesDecimal.toInt();
    int seconds = ((minutesDecimal - minutes) * 60).toInt();

    String direction = latitude >= 0 ? 'N' : 'S';

    return '${degrees.toString().padLeft(2, '0')}${minutes.toString().padLeft(2, '0')}${seconds.toString().padLeft(2, '0')}$direction';
  }

  String _formatLongitude(double longitude) {
    int degrees = longitude.abs().toInt();
    double minutesDecimal = (longitude.abs() - degrees) * 60;
    int minutes = minutesDecimal.toInt();
    int seconds = ((minutesDecimal - minutes) * 60).toInt();

    String direction = longitude >= 0 ? 'E' : 'W';

    return '${degrees.toString().padLeft(3, '0')}${minutes.toString().padLeft(2, '0')}${seconds.toString().padLeft(2, '0')}$direction';
  }

  void clearFields() {
    updateStartDate(_buildContext, startDate!);

    operatorPhoneController.clear();
    emailController.clear();
    noteController.clear();
    latLngController.clear();
    radiusController.clear();
    flightHeightController.clear();
    startDateController.clear();
    flightStartDateControllerTime.clear();
    flightEndDateTimeController.clear();
    landmarkController.clear();

    // Очистка контроллеров телефонов
    for (var controller in operatorPhoneControllers) {
      controller.clear();
    }
    for (var controller in manualPhoneControllers) {
      controller.clear();
    }
    operatorPhoneControllers.clear();
    manualPhoneControllers.clear();

    endDate = null;
    flightStartDateTime = null;
    flightEndDateTime = null;
    permitDate = null;
    contractDate = null;
    selectedBplas = [];
    selectedOperators = [];
    selectedRegion = null;
    selectedDistrict = null;
    selectedPurpose = null;

    notifyListeners();
  }


  @override
  void dispose() {
    requesterNameController.dispose();
    operatorPhoneController.dispose();
    emailController.dispose();
    permitNumberController.dispose();
    contractNumberController.dispose();
    noteController.dispose();
    latLngController.dispose();
    radiusController.dispose();
    flightHeightController.dispose();
    startDateController.dispose();
    flightStartDateControllerTime.dispose();
    flightEndDateTimeController.dispose();
    landmarkController.dispose();
    customPurposeController.dispose();

    for (var controller in operatorPhoneControllers) {
      controller.dispose();
    }
    for (var controller in manualPhoneControllers) {
      controller.dispose();
    }

    super.dispose();
  }
}
