import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:latlong2/latlong.dart';

import '../models/request_model.dart';
import '../utils/localization_manager.dart';
import 'package:provider/provider.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class AddRequestViewModel extends ChangeNotifier {
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

  // Списки для выпадающих полей
  final List<String> models = ["Модель 1", "Модель 2", "Модель 3"];
  final List<String> regions = ["Ташкент", "Самарканд", "Бухара"];
  final List<String> purposes = ["Туризм", "Научные исследования", "Грузоперевозки"];
  final List<String> flightSigns = ["Знак 1", "Знак 2", "Знак 3"];


  // Переменные для работы с датами
  DateTime? startDate;
  DateTime? endDate;
  DateTime? flightStartDateTime;
  DateTime? flightEndDateTime;
  DateTime? permitDate;
  DateTime? contractDate;

  // Поля для выпадающих списков
  String? selectedModel;
  String? selectedRegion;
  String? selectedPurpose;
  String? selectedFlightSign;

  String selectedCountryCode = "+998";

  // Доступные страны
  final List<Map<String, String>> countries = [
    {"code": "+998", "flag": "🇺🇿"},
    {"code": "+1", "flag": "🇺🇸"},
    {"code": "+44", "flag": "🇬🇧"},
    {"code": "+7", "flag": "🇷🇺"},
    {"code": "+997", "flag": "🇰🇿"},
  ];



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

  void setModel(String model) {
    selectedModel = model;
    notifyListeners();
  }

  void setRegion(String region) {
    selectedRegion = region;
    notifyListeners();
  }

  void setPurpose(String purpose) {
    selectedPurpose = purpose;
    notifyListeners();
  }


  void setFlightSign(String flightSign) {
    selectedFlightSign = flightSign;
    notifyListeners();
  }



  String? submitRequest(BuildContext context) {
    final localizations = AppLocalizations.of(context);

    // Проверка даты начала
    if (startDate == null) {
      return localizations?.invalidStartDate;
    }

    // Проверка наименование заявителя
    if (requesterNameController.text.isEmpty) {
      return localizations?.invalidRequesterName;
    }

    // Проверка модели
    if (selectedModel == null || selectedModel!.isEmpty) {
      return localizations?.invalidModel;
    }

    // Проверка знака полета
    if (selectedFlightSign == null || selectedFlightSign!.isEmpty) {
      return localizations?.invalidFlightSign;
    }

    // Проверка времени начала полета
    if (flightStartDateTime == null) {
      return localizations?.invalidFlightStartDateTime;
    }

    // Проверка времени окончания полета
    if (flightEndDateTime == null) {
      return localizations?.invalidFlightEndDateTime;
    }

    // Проверка региона полета
    if (selectedRegion == null || selectedRegion!.isEmpty) {
      return localizations?.invalidRegion;
    }

    // Проверка координат
    List<String> latLngParts = latLngController.text.split(" ");
    if (latLngParts.length != 2) {
      return localizations?.invalidLatLngFormat;
    }

    double? latitude = double.tryParse(latLngParts[0]);
    double? longitude = double.tryParse(latLngParts[1]);
    if (latitude == null || longitude == null) {
      return localizations?.invalidLatitudeLongitude;
    }

    // Проверка высоты полета
    double? flightHeight = double.tryParse(flightHeightController.text);
    if (flightHeight == null) {
      return localizations?.invalidFlightHeight;
    }

    // Проверка радиуса
    double? radius = double.tryParse(radiusController.text);
    if (radius == null) {
      return localizations?.invalidRadius;
    }

    // Проверка цели полета
    if (selectedPurpose == null || selectedPurpose!.isEmpty) {
      return localizations?.invalidPurpose;
    }

    // Проверка имени оператора
    if (operatorNameController.text.isEmpty) {
      return localizations?.invalidOperatorName;
    }

    // Проверка номера контракта
    int? contractNumber = int.tryParse(contractNumberController.text);
    if (contractNumber == null) {
      return localizations?.invalidContractNumber;
    }


    // Проверка email
    String email = emailController.text;
    if (email.isEmpty || !RegExp(r"^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$").hasMatch(email)) {
      return localizations?.invalidEmail;
    }

    // Проверка номера разрешения
    int? permitNumber = int.tryParse(permitNumberController.text);
    if (permitNumber == null) {
      return localizations?.invalidPermitNumber;
    }

    // Проверка даты разрешения
    if (permitDate == null) {
      return localizations?.invalidPermitDate;
    }


    // Проверка даты контракта
    if (contractDate == null) {
      return localizations?.invalidContractDate;
    }

    // Проверка номера телефона
    String phoneNumber = "$selectedCountryCode ${phoneController.text}";
    if (phoneController.text.isEmpty || phoneController.text.length < 7) {
      return localizations?.invalidPhoneNumber;
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
      model: selectedModel,
      region: selectedRegion,
      purpose: selectedPurpose,
      latitude: latitude,
      longitude: longitude,
      radius: radius,
      startDate: startDate,
      flightStartDateTime: flightStartDateTime,
      flightEndDateTime: flightEndDateTime,
      permitDate: permitDate,
      contractDate: contractDate,
      flightSign: selectedFlightSign, // Добавлен знак полета
      lang: lang, // Используем текущий язык
    );

    print("Submitting request: ${requestModel.toJson()}");

    return null; // Если ошибок нет, возвращаем null
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
