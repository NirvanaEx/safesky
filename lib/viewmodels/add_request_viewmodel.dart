import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:latlong2/latlong.dart';
import 'package:safe_sky/models/prepare_model.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../models/request.dart';
import '../models/request/flight_sign_model.dart';

import '../services/request_service.dart';
import '../utils/localization_manager.dart';
import 'package:provider/provider.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class AddRequestViewModel extends ChangeNotifier {
  final RequestService requestService = RequestService();

  bool isLoading = false;  // Флаг загрузки данных

  // Текстовые контроллеры для полей ввода
  final TextEditingController requesterNameController = TextEditingController();
  final TextEditingController operatorPhoneController = TextEditingController();
  final TextEditingController requestNumController = TextEditingController();
  final TextEditingController regionController = TextEditingController();

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


  List<Bpla> bplaList = [];

  List<FlightSignModel> flightSigns = [];
  List<String> purposeList = [];


  ///NEW
  List<Operator> operatorList = [];
  List<Permission> permissionList = [];
  List<String> agreementList = [];


  // Переменные для работы с датами
  DateTime? startDate;
  DateTime? endDate;
  DateTime? flightStartDateTime;
  DateTime? flightEndDateTime;
  DateTime? permitDate;
  DateTime? contractDate;

  // Поля для выпадающих списков
  Bpla? selectedBpla;
  String? selectedPurpose;
  Operator? selectedOperator;

  String selectedCountryCode = "+998";


  PrepareData? prepareData;

  // Доступные страны
  final List<Map<String, String>> countries = [
    {"code": "+998", "flag": "🇺🇿"},
    {"code": "+1", "flag": "🇺🇸"},
    {"code": "+44", "flag": "🇬🇧"},
    {"code": "+7", "flag": "🇷🇺"},
    {"code": "+997", "flag": "🇰🇿"},
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


  Future<void> loadPrepare(String planDate) async {
    prepareData = await requestService.fetchPrepareData(planDate);
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



  void setBpla(Bpla bpla) {
    selectedBpla = bpla;
    notifyListeners();
  }



  void setPurpose(String purpose) {
    selectedPurpose = purpose;
    notifyListeners();
  }

  void setOperator(Operator operator) {
    selectedOperator = operator;
    notifyListeners();
  }




  Future<Map<String, String>?> submitRequest(BuildContext context) async {
    final localizations = AppLocalizations.of(context);

    // Проверка даты начала
    if (startDate == null) {
      return {'status': 'error', 'message': localizations?.invalidStartDate ?? "Invalid start date"};
    }

    // Проверка наименования заявителя
    // if (requesterNameController.text.isEmpty) {
    //   return {'status': 'error', 'message': localizations?.invalidRequesterName ?? "Invalid requester name"};
    // }

    // Проверка модели
    if (selectedBpla == null ) {
      return {'status': 'error', 'message': localizations?.invalidModel ?? "Invalid model"};
    }



    // Проверка времени начала полета
    if (flightStartDateTime == null) {
      return {'status': 'error', 'message': localizations?.invalidFlightStartDateTime ?? "Invalid flight start date"};
    }

    // Проверка времени окончания полета
    if (flightEndDateTime == null) {
      return {'status': 'error', 'message': localizations?.invalidFlightEndDateTime ?? "Invalid flight end date"};
    }



    // Проверка координат
    List<String> latLngParts = latLngController.text.split(" ");
    if (latLngParts.length != 2) {
      return {'status': 'error', 'message': localizations?.invalidLatLngFormat ?? "Invalid coordinates format"};
    }

    double? latitude = double.tryParse(latLngParts[0]);
    double? longitude = double.tryParse(latLngParts[1]);
    if (latitude == null || longitude == null) {
      return {'status': 'error', 'message': localizations?.invalidLatitudeLongitude ?? "Invalid latitude/longitude"};
    }

    // Проверка высоты полета
    double? flightHeight = double.tryParse(flightHeightController.text);
    if (flightHeight == null) {
      return {'status': 'error', 'message': localizations?.invalidFlightHeight ?? "Invalid flight height"};
    }

    // Проверка радиуса
    double? radius = double.tryParse(radiusController.text);
    if (radius == null) {
      return {'status': 'error', 'message': localizations?.invalidRadius ?? "Invalid radius"};
    }

    // Проверка цели полета
    // if (selectedPurpose == null || selectedPurpose!.isEmpty) {
    //   return {'status': 'error', 'message': localizations?.invalidPurpose ?? "Invalid purpose"};
    // }



    // Проверка номера телефона
    String phoneNumber = "$selectedCountryCode ${phoneController.text}";
    if (phoneController.text.isEmpty || phoneController.text.length < 7) {
      return {'status': 'error', 'message': localizations?.invalidPhoneNumber ?? "Invalid phone number"};
    }

    // Проверка email
    String email = emailController.text;
    if (email.isEmpty || !RegExp(r"^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$").hasMatch(email)) {
      return {'status': 'error', 'message': localizations?.invalidEmail ?? "Invalid email"};
    }

    // Проверка номера контракта
    // int? contractNumber = int.tryParse(contractNumberController.text);
    // if (contractNumber == null) {
    //   return {'status': 'error', 'message': localizations?.invalidContractNumber ?? "Invalid contract number"};
    // }



    // Проверка номера разрешения
    // int? permitNumber = int.tryParse(permitNumberController.text);
    // if (permitNumber == null) {
    //   return {'status': 'error', 'message': localizations?.invalidPermitNumber ?? "Invalid permit number"};
    // }

    // Проверка даты разрешения
    // if (permitDate == null) {
    //   return {'status': 'error', 'message': localizations?.invalidPermitDate ?? "Invalid permit date"};
    // }

    // Проверка даты контракта
    // if (contractDate == null) {
    //   return {'status': 'error', 'message': localizations?.invalidContractDate ?? "Invalid contract date"};
    // }




    SharedPreferences prefs = await SharedPreferences.getInstance();
    int? userId = prefs.getInt('userId');


    // Формируем JSON объект вручную
    Map<String, dynamic> requestBody = {
      "applicationNum": requestNumController.text,
      "planDate": startDate?.toIso8601String() ?? '',
      "timeFrom": formatTimeToHHmm(flightStartDateTime),
      "timeTo": formatTimeToHHmm(flightEndDateTime),
      "flightArea": regionController.text,
      "zoneTypeId": 1 ?? 0,
      "purpose": selectedPurpose ?? '',
      "bplaList": selectedBpla != null ? [selectedBpla!.id?? 0] : [],
      "operatorList": selectedOperator != null ? [selectedOperator!.id, userId ?? 0] : [],
      "coordList": [
        {
          "latitude": formatLatitude(latLngController.text),
          "longitude": formatLongitude(latLngController.text),
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
        return {'status': 'success', 'message': "Запрос успешно отправлен!"};
      } else {
        return {'status': 'error', 'message': response['message']};
      }
    } catch (e) {
      return {'status': 'error', 'message': 'Ошибка при отправке: $e'};
    }

  }

  String formatTimeToHHmm(DateTime? dateTime) {
    if (dateTime == null) return '';
    return DateFormat('HH:mm').format(dateTime);
  }

  String formatLatitude(String latitudeStr) {
    double latitude = double.tryParse(latitudeStr) ?? 0.0;

    int degrees = latitude.abs().toInt();
    double minutesDecimal = (latitude.abs() - degrees) * 60;
    int minutes = minutesDecimal.toInt();
    int seconds = ((minutesDecimal - minutes) * 60).toInt();

    String direction = latitude >= 0 ? 'N' : 'S';

    return '${degrees.toString().padLeft(2, '0')}${minutes.toString().padLeft(2, '0')}${seconds.toString().padLeft(2, '0')}$direction';
  }

  String formatLongitude(String longitudeStr) {
    double longitude = double.tryParse(longitudeStr) ?? 0.0;

    int degrees = longitude.abs().toInt();
    double minutesDecimal = (longitude.abs() - degrees) * 60;
    int minutes = minutesDecimal.toInt();
    int seconds = ((minutesDecimal - minutes) * 60).toInt();

    String direction = longitude >= 0 ? 'E' : 'W';

    return '${degrees.toString().padLeft(3, '0')}${minutes.toString().padLeft(2, '0')}${seconds.toString().padLeft(2, '0')}$direction';
  }


  void clearFields() {
    requesterNameController.clear();
    operatorPhoneController.clear();
    emailController.clear();
    permitNumberController.clear();
    contractNumberController.clear();
    noteController.clear();
    phoneController.clear();
    latLngController.clear();
    radiusController.clear();
    flightHeightController.clear();
    startDateController.clear();
    flightStartDateControllerTime.clear();
    flightEndDateTimeController.clear();


    endDate = null;
    flightStartDateTime = null;
    flightEndDateTime = null;
    permitDate = null;
    contractDate = null;
    selectedBpla = null;
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

    super.dispose();
  }
}
