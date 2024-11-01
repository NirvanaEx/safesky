import 'dart:convert';
import 'package:http/http.dart' as http;
import '../config/api_routes.dart';
import '../config/config.dart';
import '../models/request/flight_sign_model.dart';
import '../models/request/model_model.dart';
import '../models/request/purpose_model.dart';
import '../models/request/region_model.dart';
import '../models/request_model.dart';

class RequestService {
  // Метод для отправки запроса
  Future<http.Response> submitRequest(RequestModel request) async {
    // Заглушка для успешного ответа при тестировании
    // return http.Response(jsonEncode({'status': 'success', 'message': 'Request submitted successfully'}), 201);

    final response = await http.post(
      Uri.parse(ApiRoutes.add_request),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': Config.basicAuth,
      },
      body: jsonEncode(request.toJson()),
    );

    if (response.statusCode == 201) {
      return response;
    } else {
      var errorMessage = json.decode(response.body)['message'] ?? 'Failed to submit request';
      throw Exception(errorMessage);
    }
  }

  // Метод для получения списка моделей с параметром lang
  Future<List<ModelModel>> fetchModels(String lang) async {
    // Заглушка для тестирования
    return [
      ModelModel(id: 1, lang: lang, name: 'Model 1'),
      ModelModel(id: 2, lang: lang, name: 'Model 2')
    ];

    final response = await http.get(
      Uri.parse('${ApiRoutes.models}?lang=$lang'),
      headers: {
        'Authorization': Config.basicAuth,
      },
    );

    if (response.statusCode == 200) {
      final List<dynamic> data = jsonDecode(response.body);
      return data.map((item) => ModelModel.fromJson(item)).toList();
    } else {
      throw Exception('Failed to load models');
    }
  }

  // Метод для получения списка знаков полета с параметром lang
  Future<List<FlightSignModel>> fetchFlightSigns(String lang) async {
    // Заглушка для тестирования
    return [
      FlightSignModel(id: 1, lang: lang, name: 'Flight Sign 1'),
      FlightSignModel(id: 2, lang: lang, name: 'Flight Sign 2')
    ];

    final response = await http.get(
      Uri.parse('${ApiRoutes.flightSigns}?lang=$lang'),
      headers: {
        'Authorization': Config.basicAuth,
      },
    );

    if (response.statusCode == 200) {
      final List<dynamic> data = jsonDecode(response.body);
      return data.map((item) => FlightSignModel.fromJson(item)).toList();
    } else {
      throw Exception('Failed to load flight signs');
    }
  }

  // Метод для получения списка целей с параметром lang
  Future<List<PurposeModel>> fetchPurposes(String lang) async {
    // Заглушка для тестирования
    return [
      PurposeModel(id: 1, lang: lang, name: 'Tourism'),
      PurposeModel(id: 2, lang: lang, name: 'Research')
    ];

    final response = await http.get(
      Uri.parse('${ApiRoutes.purposes}?lang=$lang'),
      headers: {
        'Authorization': Config.basicAuth,
      },
    );

    if (response.statusCode == 200) {
      final List<dynamic> data = jsonDecode(response.body);
      return data.map((item) => PurposeModel.fromJson(item)).toList();
    } else {
      throw Exception('Failed to load purposes');
    }
  }

  // Метод для получения списка регионов с параметром lang
  Future<List<RegionModel>> fetchRegions(String lang) async {
    // Заглушка для тестирования
    return [
      RegionModel(id: 1, lang: lang, name: 'Tashkent'),
      RegionModel(id: 2, lang: lang, name: 'Samarkand')
    ];

    final response = await http.get(
      Uri.parse('${ApiRoutes.regions}?lang=$lang'),
      headers: {
        'Authorization': Config.basicAuth,
      },
    );

    if (response.statusCode == 200) {
      final List<dynamic> data = jsonDecode(response.body);
      return data.map((item) => RegionModel.fromJson(item)).toList();
    } else {
      throw Exception('Failed to load regions');
    }
  }

  // Метод для получения списка запросов
  Future<List<RequestModel>> fetchRequests(String token, {int batch = 0, int batchSize = 10}) async {
    return List.generate(
      batchSize,
          (index) => RequestModel(
        id: '${batch * batchSize + index}',
        number: '${batch * batchSize + index + 1}',
        status: index % 3 == 0
            ? 'confirmed'
            : index % 3 == 1
            ? 'pending'
            : 'rejected',
      ),
    );

    // Реальный API запрос:
    // final response = await http.get(
    //   Uri.parse('${ApiRoutes.requests}'),
    //   headers: {
    //     'Authorization': 'Bearer $token',
    //   },
    // );

    // if (response.statusCode == 200) {
    //   final List<dynamic> data = jsonDecode(response.body);
    //   return data.map((item) => RequestModel.fromJson(item)).toList();
    // } else {
    //   throw Exception('Failed to load requests');
    // }
  }
}
