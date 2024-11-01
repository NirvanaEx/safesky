import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:latlong2/latlong.dart';

import '../models/request/flight_sign_model.dart';
import '../models/request/model_model.dart';
import '../models/request/purpose_model.dart';
import '../models/request/region_model.dart';
import '../models/request_model.dart';
import '../services/request_service.dart';
import '../utils/localization_manager.dart';
import 'package:provider/provider.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class AddRequestViewModel extends ChangeNotifier {
  final RequestService requestService = RequestService();

  // Текстовые контроллеры для полей ввода
  final TextEditingController requesterNameController = TextEditingController();
  final TextEditingController operatorNameController = TextEditingController();
  final TextEditingController operatorPhoneController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController permitNumberController = TextEditingController();
  final TextEditingController contractNumberController = TextEditingController();
  final TextEditingController noteController = TextEditingController();
  final TextEditingController phoneController = TextEditingController();
  final TextEditingController latLngController = TextEditingController();
  final TextEditingController radiusController = TextEditingController();
  final TextEditingController flightHeightController = TextEditingController(); // Контроллер для высоты полета
  final TextEditingController startDateController = TextEditingController(); // Контроллер для даты начала
  final TextEditingController flightStartDateControllerTime = TextEditingController(); // Контроллер для времени начала полета
  final TextEditingController flightEndDateTimeController = TextEditingController(); // Контроллер для времени окончания полета
  final TextEditingController permitDateController = TextEditingController(); // Контроллер для даты разрешения
  final TextEditingController contractDateController = TextEditingController(); // Контроллер для даты контракта

  List<ModelModel> models = [];
  List<FlightSignModel> flightSigns = [];
  List<PurposeModel> purposes = [];
  List<RegionModel> regions = [];



  // Переменные для работы с датами
  DateTime? startDate;
  DateTime? endDate;
  DateTime? flightStartDateTime;
  DateTime? flightEndDateTime;
  DateTime? permitDate;
  DateTime? contractDate;

  // Поля для выпадающих списков
  ModelModel? selectedModel;
  RegionModel? selectedRegion;
  PurposeModel? selectedPurpose;
  FlightSignModel? selectedFlightSign;

  String selectedCountryCode = "+998";

  // Доступные страны
  final List<Map<String, String>> countries = [
    {"code": "+998", "flag": "🇺🇿"},
    {"code": "+1", "flag": "🇺🇸"},
    {"code": "+44", "flag": "🇬🇧"},
    {"code": "+7", "flag": "🇷🇺"},
    {"code": "+997", "flag": "🇰🇿"},
  ];


  Future<void> loadModels(String lang) async {
    models = await requestService.fetchModels(lang);
    notifyListeners();
  }

  Future<void> loadFlightSigns(String lang) async {
    flightSigns = await requestService.fetchFlightSigns(lang);
    notifyListeners();
  }

  Future<void> loadPurposes(String lang) async {
    purposes = await requestService.fetchPurposes(lang);
    notifyListeners();
  }

  Future<void> loadRegions(String lang) async {
    regions = await requestService.fetchRegions(lang);
    notifyListeners();
  }

  // Метод для инициализации всех списков данных сразу
  Future<void> initializeData(BuildContext context) async {
    String lang = context.read<LocalizationManager>().currentLocale.languageCode;
    await Future.wait([
      loadModels(lang),
      loadFlightSigns(lang),
      loadPurposes(lang),
      loadRegions(lang),
    ]);
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

  // Методы обновления даты
  void updateStartDate(DateTime date) {
    startDate = date;
    startDateController.text = DateFormat('dd.MM.yyyy').format(date);
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

  void updatePermitDate(DateTime date) {
    permitDate = date;
    permitDateController.text = DateFormat('dd.MM.yyyy').format(date);
    notifyListeners();
  }

  void updateContractDate(DateTime date) {
    contractDate = date;
    contractDateController.text = DateFormat('dd.MM.yyyy').format(date);
    notifyListeners();
  }

  void setModel(ModelModel model) {
    selectedModel = model;
    notifyListeners();
  }

  void setRegion(RegionModel region) {
    selectedRegion = region;
    notifyListeners();
  }

  void setPurpose(PurposeModel purpose) {
    selectedPurpose = purpose;
    notifyListeners();
  }

  void setFlightSign(FlightSignModel flightSign) {
    selectedFlightSign = flightSign;
    notifyListeners();
  }



  Future<Map<String, String>?> submitRequest(BuildContext context) async {
    final localizations = AppLocalizations.of(context);

    // Проверка даты начала
    if (startDate == null) {
      return {'status': 'error', 'message': localizations?.invalidStartDate ?? "Invalid start date"};
    }

    // Проверка наименования заявителя
    if (requesterNameController.text.isEmpty) {
      return {'status': 'error', 'message': localizations?.invalidRequesterName ?? "Invalid requester name"};
    }

    // Проверка модели
// Проверка модели
    if (selectedModel == null || selectedModel!.name.isEmpty) {
      return {'status': 'error', 'message': localizations?.invalidModel ?? "Invalid model"};
    }

    // Проверка знака полета
    if (selectedFlightSign == null || selectedFlightSign!.name.isEmpty) {
      return {'status': 'error', 'message': localizations?.invalidFlightSign ?? "Invalid flight sign"};
    }

    // Проверка времени начала полета
    if (flightStartDateTime == null) {
      return {'status': 'error', 'message': localizations?.invalidFlightStartDateTime ?? "Invalid flight start date"};
    }

    // Проверка времени окончания полета
    if (flightEndDateTime == null) {
      return {'status': 'error', 'message': localizations?.invalidFlightEndDateTime ?? "Invalid flight end date"};
    }

    // Проверка региона полета
    if (selectedRegion == null || selectedRegion!.name.isEmpty) {
      return {'status': 'error', 'message': localizations?.invalidRegion ?? "Invalid region"};
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
    if (selectedPurpose == null || selectedPurpose!.name.isEmpty) {
      return {'status': 'error', 'message': localizations?.invalidPurpose ?? "Invalid purpose"};
    }

    // Проверка имени оператора
    if (operatorNameController.text.isEmpty) {
      return {'status': 'error', 'message': localizations?.invalidOperatorName ?? "Invalid operator name"};
    }

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
    int? contractNumber = int.tryParse(contractNumberController.text);
    if (contractNumber == null) {
      return {'status': 'error', 'message': localizations?.invalidContractNumber ?? "Invalid contract number"};
    }



    // Проверка номера разрешения
    int? permitNumber = int.tryParse(permitNumberController.text);
    if (permitNumber == null) {
      return {'status': 'error', 'message': localizations?.invalidPermitNumber ?? "Invalid permit number"};
    }

    // Проверка даты разрешения
    if (permitDate == null) {
      return {'status': 'error', 'message': localizations?.invalidPermitDate ?? "Invalid permit date"};
    }

    // Проверка даты контракта
    if (contractDate == null) {
      return {'status': 'error', 'message': localizations?.invalidContractDate ?? "Invalid contract date"};
    }


    // Получаем текущий язык через context.read
    String lang = context.read<LocalizationManager>().currentLocale.languageCode;

    RequestModel requestModel = RequestModel(
      requesterName: requesterNameController.text,
      operatorName: operatorNameController.text,
      operatorPhone: phoneNumber,
      email: email,
      permitNumber: permitNumber.toString(),
      contractNumber: contractNumber.toString(),
      note: noteController.text,
      model: selectedModel?.name,
      region: selectedRegion?.name,
      purpose: selectedPurpose?.name,
      latitude: latitude,
      longitude: longitude,
      radius: radius,
      startDate: startDate,
      flightStartDateTime: flightStartDateTime,
      flightEndDateTime: flightEndDateTime,
      permitDate: permitDate,
      contractDate: contractDate,
      flightSign: selectedFlightSign?.name, // Добавлен знак полета
      lang: lang, // Используем текущий язык
    );

    print("Submitting request: ${requestModel.toJson()}");


    try {
      final response = await requestService.submitRequest(requestModel);
      if (response.statusCode == 201) {
        print("Submitting request: ${requestModel.toJson()}");
        return {'status': 'success', 'message': "Запрос успешно отправлен!"};

      } else {
        // Дополнительная обработка ошибок, если статус не 201
        return {'status': 'error', 'message': 'Не удалось отправить запрос'};
      }
    } catch (e) {
      // Обработка исключений
      return {'status': 'error', 'message': e.toString()};
    }

  }




  void clearFields() {
    requesterNameController.clear();
    operatorNameController.clear();
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
    permitDateController.clear();
    contractDateController.clear();

    startDate = null;
    endDate = null;
    flightStartDateTime = null;
    flightEndDateTime = null;
    permitDate = null;
    contractDate = null;
    selectedModel = null;
    selectedRegion = null;
    selectedPurpose = null;
    notifyListeners();
  }

  @override
  void dispose() {
    requesterNameController.dispose();
    operatorNameController.dispose();
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
    permitDateController.dispose();
    contractDateController.dispose();
    super.dispose();
  }
}
