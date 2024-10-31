import 'package:flutter/material.dart';
import '../models/request_model.dart';
import '../services/request_service.dart';

class RequestViewModel extends ChangeNotifier {
  final RequestService _requestService = RequestService();
  RequestModel _requestModel = RequestModel();

  String? errorMessage;
  String? selectedModel;
  String? selectedRegion;
  String? selectedPurpose;

  void updateRequesterName(String value) {
    _requestModel.requesterName = value;
    notifyListeners();
  }

  void updateOperatorName(String value) {
    _requestModel.operatorName = value;
    notifyListeners();
  }

  void updateOperatorPhone(String value) {
    _requestModel.operatorPhone = value;
    notifyListeners();
  }

  void updateEmail(String value) {
    _requestModel.email = value;
    notifyListeners();
  }

  void updatePermitNumber(String value) {
    _requestModel.permitNumber = value;
    notifyListeners();
  }

  void updateContractNumber(String value) {
    _requestModel.contractNumber = value;
    notifyListeners();
  }

  void updateNote(String value) {
    _requestModel.note = value;
    notifyListeners();
  }

  void updateCoordinates(String value) {
    List<String> latLngParts = value.split(" ");

    if (latLngParts.length == 2) {
      double? latitude = double.tryParse(latLngParts[0]);
      double? longitude = double.tryParse(latLngParts[1]);

      if (latitude != null && longitude != null) {
        _requestModel.latitude = latitude;
        _requestModel.longitude = longitude;
      } else {
        print("Ошибка: Некорректные значения для широты или долготы");
      }
    } else {
      print("Ошибка: Некорректный формат координат. Используйте формат 'широта долгота'");
    }

    notifyListeners();
  }


  void updateRadius(double? value) {
    _requestModel.radius = value;
    notifyListeners();
  }

  void updateModel(String? model) {
    selectedModel = model;
    _requestModel.model = model;
    notifyListeners();
  }

  void updateRegion(String? region) {
    selectedRegion = region;
    _requestModel.region = region;
    notifyListeners();
  }

  void updatePurpose(String? purpose) {
    selectedPurpose = purpose;
    _requestModel.purpose = purpose;
    notifyListeners();
  }

  Future<void> submitRequest() async {
    try {
      await _requestService.submitRequest(_requestModel);
      errorMessage = null; // Очистка сообщения об ошибке при успешной отправке
      notifyListeners();
    } catch (e) {
      errorMessage = 'Ошибка отправки заявки: $e';
      notifyListeners();
    }
  }
}
