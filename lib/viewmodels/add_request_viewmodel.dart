import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:latlong2/latlong.dart';
import 'package:safe_sky/models/prepare_model.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../models/district_model.dart';
import '../models/region_model.dart';
import '../models/request.dart';

import '../services/request_service.dart';

import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class AddRequestViewModel extends ChangeNotifier {
  final RequestService requestService = RequestService();

  bool isLoading = false;  // Флаг загрузки данных

  // Текстовые контроллеры для полей ввода
  final TextEditingController requesterNameController = TextEditingController();
  final TextEditingController operatorPhoneController = TextEditingController();
  final TextEditingController requestNumController = TextEditingController();

  final TextEditingController emailController = TextEditingController();
  final TextEditingController noteController = TextEditingController();
  final TextEditingController phoneController = TextEditingController();
  final TextEditingController latLngController = TextEditingController();
  final TextEditingController radiusController = TextEditingController();
  final TextEditingController flightHeightController = TextEditingController(); // Контроллер для высоты полета
  final TextEditingController startDateController = TextEditingController(); // Контроллер для даты начала
  final TextEditingController flightStartDateControllerTime = TextEditingController(); // Контроллер для времени начала полета
  final TextEditingController flightEndDateTimeController = TextEditingController(); // Контроллер для времени окончания полета
  final TextEditingController permitNumberController = TextEditingController();
  final TextEditingController contractNumberController = TextEditingController();

  final TextEditingController landmarkController = TextEditingController();


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

  Future<void> initializeData(BuildContext context, String planDate) async {
    await Future.delayed(Duration(seconds: 1));  // Симуляция загрузки данных
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? applicant = prefs.getString('applicant');

    await loadPrepare(planDate);
    requesterNameController.text = applicant ?? '';
    bplaList = prepareData!.bplaList;
    operatorList = prepareData!.operatorList;
    purposeList = prepareData!.purposeList;
    permitNumberController.text = "${prepareData?.permission?.orgName} ${prepareData!.permission?.docNum} ${prepareData!.permission?.docDate}";
    contractNumberController.text = "${prepareData!.agreement?.docNum} ${prepareData!.agreement?.docDate}";
    notifyListeners();
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

  void updateCountryCode(String code) {
    selectedCountryCode = code;
    phoneController.clear();
    notifyListeners();
  }

  void updateDateField(DateTime date, TextEditingController controller) {
    // Устанавливаем отформатированную дату в контроллер
    controller.text = DateFormat('dd.MM.yyyy').format(date);
    notifyListeners(); // Обновляем интерфейс
  }


  void updateCoordinatesAndRadius(LatLng coordinates, double? radius) {
    latLngController.text = '${coordinates.latitude.toStringAsFixed(5)} ${coordinates.longitude.toStringAsFixed(5)}';
    radiusController.text = radius != null ? radius.toStringAsFixed(0) : '';
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
    notifyListeners();
  }

  void setOperators(List<Operator> operators) {
    selectedOperators = operators;
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


    // Проверка номера заявки
    if (requestNumController.text.trim().isEmpty) {
      return {'status': 'error', 'message': localizations?.addRequestView_invalidRequestNumber ?? "Request number cannot be empty"};
    }

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


    // Проверка координат
    List<String> latLngParts = latLngController.text.split(" ");
    if (latLngParts.length != 2) {
      return {'status': 'error', 'message': localizations?.addRequestView_invalidLatLngFormat ?? "Invalid coordinates format"};
    }

    double? latitude = double.tryParse(latLngParts[0]);
    double? longitude = double.tryParse(latLngParts[1]);
    if (latitude == null || longitude == null) {
      return {'status': 'error', 'message': localizations?.addRequestView_invalidLatitudeLongitude ?? "Invalid latitude/longitude"};
    }

    // Проверка высоты полета
    double? flightHeight = double.tryParse(flightHeightController.text);
    if (flightHeight == null) {
      return {'status': 'error', 'message': localizations?.addRequestView_invalidFlightHeight ?? "Invalid flight height"};
    }

    // Проверка радиуса
    double? radius = double.tryParse(radiusController.text);
    if (radius == null) {
      return {'status': 'error', 'message': localizations?.addRequestView_invalidRadius ?? "Invalid radius"};
    }

    // Проверка выбора цели полета
    if (selectedPurpose == null || selectedPurpose!.trim().isEmpty) {
      return {'status': 'error', 'message': localizations?.addRequestView_invalidPurpose ?? "Please select purpose"};
    }

    // Проверка выбора операторов
    if (selectedOperators.isEmpty) {
      return {'status': 'error', 'message': localizations?.addRequestView_invalidOperators ?? "Please select at least one operator"};
    }

    // Проверка номера телефона
    String phoneNumber = "$selectedCountryCode ${phoneController.text}";
    if (phoneController.text.isEmpty || phoneController.text.length < 7) {
      return {'status': 'error', 'message': localizations?.addRequestView_invalidPhoneNumber ?? "Invalid phone number"};
    }

    // Проверка email
    String email = emailController.text;
    if (email.isEmpty || !RegExp(r"^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$").hasMatch(email)) {
      return {'status': 'error', 'message': localizations?.addRequestView_invalidEmail ?? "Invalid email"};
    }




    SharedPreferences prefs = await SharedPreferences.getInstance();
    int? userId = prefs.getInt('userId');
    Map<String, String> formattedCoordinates = formatLatLng(latLngController.text);

    // Формируем JSON объект вручную
    Map<String, dynamic> requestBody = {
      "applicationNum": requestNumController.text,
      "planDate": startDate?.toIso8601String() ?? '',
      "timeFrom": formatTimeToHHmm(flightStartDateTime),
      "timeTo": formatTimeToHHmm(flightEndDateTime),
      "flightArea": landmarkController.text,
      "districtCode": selectedDistrict?.code,
      "zoneTypeId": 1 ?? 0,
      "purpose": selectedPurpose ?? '',
      "bplaList": selectedBplas.isNotEmpty
          ? selectedBplaIds
          : [],
      "operatorList": selectedOperators.isNotEmpty
          ? (selectedOperatorIds.contains(userId) ? selectedOperatorIds : selectedOperatorIds + [userId ?? 0])
          : [],
      "coordList": [
        {
          "latitude": formattedCoordinates['latitude'],
          "longitude": formattedCoordinates['longitude'],
          "radius": int.tryParse(radiusController.text) ?? 0
        }
      ],
      "notes": noteController.text.isNotEmpty ? noteController.text : null,
      "operatorPhones": phoneNumber,
      "email": emailController.text.isNotEmpty ? emailController.text : null,
      "mAltitude": int.tryParse(flightHeightController.text) ?? 0,
    };

// Логируем сформированные данные
    print("Submitting BPLA Plan: ${jsonEncode(requestBody)}");

    try {
      final response = await requestService.submitBplaPlan(requestBody);
      if (response['status'] == 200) {
        print("BPLA Plan submitted successfully: ${jsonEncode(requestBody)}");
        clearFields();
        return {'status': 'success', 'message': localizations!.addRequestView_requestSentSuccess};
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

  Map<String, String> formatLatLng(String latLngStr) {
    List<String> coordinates = latLngStr.trim().split(' ');

    if (coordinates.length != 2) {
      throw FormatException("Invalid coordinate format. Expected 'lat lon'");
    }

    double latitude = double.tryParse(coordinates[0]) ?? 0.0;
    double longitude = double.tryParse(coordinates[1]) ?? 0.0;

    return {
      "latitude": _formatLatitude(latitude),
      "longitude": _formatLongitude(longitude),
    };
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

    requestNumController.clear();
    operatorPhoneController.clear();
    emailController.clear();
    noteController.clear();
    phoneController.clear();
    latLngController.clear();
    radiusController.clear();
    flightHeightController.clear();
    startDateController.clear();
    flightStartDateControllerTime.clear();
    flightEndDateTimeController.clear();
    landmarkController.clear();


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
    phoneController.dispose();
    latLngController.dispose();
    radiusController.dispose();
    flightHeightController.dispose();
    startDateController.dispose();
    flightStartDateControllerTime.dispose();
    flightEndDateTimeController.dispose();
    landmarkController.dispose();

    super.dispose();
  }
}
