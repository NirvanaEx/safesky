import 'dart:convert';
import 'dart:math';
import 'package:http/http.dart' as http;
import 'package:safe_sky/utils/enums.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../config/api_routes.dart';
import '../config/config.dart';
import '../models/area_point_location_model.dart';
import '../models/location_model.dart';
import '../models/plan_detail_model.dart';
import '../models/prepare_model.dart';
import '../models/request.dart';
import '../models/request/flight_sign_model.dart';
import '../models/request/model_model.dart';
import '../models/request/purpose_model.dart';
import '../models/request/region_model.dart';
import '../models/request/status_model.dart';
import '../models/request_model.dart';
import '../models/request_model_main.dart';
import '../test/test_generator.dart';

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


  Future<http.Response> cancelRequest(int planId, String cancelReason) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? token = prefs.getString('auth_token');

    // Проверка на тестовые данные
    if (planId == 0) {
      print('Cancel request (TEST DATA): planId=$planId, cancelReason=$cancelReason');

      return http.Response(
        jsonEncode({'status': 'success', 'message': 'Request canceled successfully'}),
        200,
      );
    }

    final Uri url = Uri.parse('${ApiRoutes.requestCancel}/$planId/cancel');

    final Map<String, dynamic> requestBody = {
      'cancelReason': cancelReason,
    };

    print('Sending cancel request:');
    print('URL: $url');
    print('Headers: ${{
      'Content-Type': 'application/json',
      'Authorization': 'Bearer $token',
    }}');
    print('Body: ${jsonEncode(requestBody)}');

    try {
      final response = await http.post(
        url,
        headers: {
          'Content-Type': 'application/json; charset=utf-8',
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode(requestBody),
      );

      // Декодирование ответа в UTF-8
      final decodedBody = utf8.decode(response.bodyBytes);
      final decodedJson = jsonDecode(decodedBody);

      print('Response status code: ${response.statusCode}');
      print('Response body (decoded): $decodedJson');

      if (response.statusCode == 200) {
        return http.Response(decodedBody, response.statusCode);
      } else {
        var errorMessage = decodedJson['message'] ?? 'Failed to cancel request';
        print('Error in response: $errorMessage');
        throw Exception(errorMessage);
      }
    } catch (e) {
      print('Exception in cancelRequest: $e');
      throw Exception('Error in cancelRequest: $e');
    }
  }



  Future<http.Response> deleteRequest(int planId) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? token = prefs.getString('auth_token');

    // Проверка на тестовые данные
    if (planId == 0) {
      print('Delete request (TEST DATA): planId=$planId');

      return http.Response(
        jsonEncode({'status': 'success', 'message': 'Request deleted successfully'}),
        200,
      );
    }

    final Uri url = Uri.parse('${ApiRoutes.requestDelete}/$planId/delete');

    print('Sending delete request:');
    print('URL: $url');
    print('Headers: ${{
      'Content-Type': 'application/json',
      'Authorization': 'Bearer $token',
    }}');

    try {
      final response = await http.post(
        url,
        headers: {
          'Content-Type': 'application/json; charset=utf-8',
          'Authorization': 'Bearer $token',
        },
      );

      // Декодирование ответа в UTF-8
      final decodedBody = utf8.decode(response.bodyBytes);
      final decodedJson = jsonDecode(decodedBody);

      print('Response status code: ${response.statusCode}');
      print('Response body (decoded): $decodedJson');

      if (response.statusCode == 200) {
        return http.Response(decodedBody, response.statusCode);
      } else {
        var errorMessage = decodedJson['message'] ?? 'Failed to delete request';
        print('Error in response: $errorMessage');
        throw Exception(errorMessage);
      }
    } catch (e) {
      print('Exception in deleteRequest: $e');
      throw Exception('Error in deleteRequest: $e');
    }
  }



  Future<List<RequestModelMain>> fetchMainRequests({int page = 1, int count = 10}) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? token = prefs.getString('auth_token');

    return TestDataGenerator.generateMainRequests(count: 10);
    if (token == null || token.isEmpty) {
      throw Exception('No authentication token found');
    }

    final response = await http.get(
      Uri.parse('${ApiRoutes.requestList}?page=$page&count=$count'),
      headers: {
        'Authorization': 'Bearer $token',
        'Accept': 'application/json',
      },
    );

    print("API Response (raw bytes): ${response.bodyBytes}");

    if (response.statusCode == 200) {
      try {
        final decodedBody = latin1.decode(response.bodyBytes);
        final Map<String, dynamic> jsonData = json.decode(decodedBody);

        List<RequestModelMain> requests = (jsonData['rows'] as List)
            .map((item) => RequestModelMain.fromJson(item))
            .toList();

        print("Parsed requests count: ${requests.length}");
        for (var request in requests) {
          print("Request ID: ${request.planId}, Number: ${request.applicationNum}, State: ${request.state}");
        }

        return requests;
      } catch (e) {
        print("Error decoding response: $e");
        throw Exception('Failed to decode response');
      }
    } else {
      throw Exception('Failed to load requests: ${response.statusCode}');
    }
  }


  Future<PlanDetailModel> fetchPlanDetail(int planId) async {
    // 1. Получаем токен
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? token = prefs.getString('auth_token');

    return TestDataGenerator.generatePlanDetail();
    if (token == null || token.isEmpty) {
      throw Exception('No authentication token found');
    }

    // 2. Формируем запрос
    final url = Uri.parse('${ApiRoutes.requestDetailInfo}$planId');
    final response = await http.get(
      url,
      headers: {
        'Authorization': 'Bearer $token',
        'Accept': 'application/json',
      },
    );

    // 3. Обрабатываем ответ
    if (response.statusCode == 200) {

      final decodedBody = utf8.decode(response.bodyBytes);
      print('decodedBody: $decodedBody');

      try {
        final Map<String, dynamic> jsonData = json.decode(decodedBody);
        print('Parsed JSON map: $jsonData');

        final detailModel = PlanDetailModel.fromJson(jsonData);
        print('Parsed successfully: ${detailModel.permission}');

        return detailModel;
      } catch (e) {
        print("Error decoding response: $e");
        throw Exception('Failed to decode PlanDetail');
      }
    } else {
      // Если пришла ошибка (400, 403, 500 и т.д.)
      print("Error: ${response.statusCode} => ${response.body}");
      throw Exception('Failed to load plan detail: ${response.statusCode}');
    }
  }

  Future<PlanDetailModel> fetchPlanDetailByUuid(String uuid) async {
    // 1. Получаем токен
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? token = prefs.getString('auth_token');

    if (token == null || token.isEmpty) {
      throw Exception('No authentication token found');
    }

    // 2. Формируем запрос с использованием uuid
    final url = Uri.parse('${ApiRoutes.requestDetailInfoByUuid}$uuid');
    final response = await http.get(
      url,
      headers: {
        'Authorization': 'Bearer $token',
        'Accept': 'application/json',
      },
    );

    // 3. Обрабатываем ответ
    if (response.statusCode == 200) {
      final decodedBody = utf8.decode(response.bodyBytes);
      print('decodedBody: $decodedBody');

      try {
        final Map<String, dynamic> jsonData = json.decode(decodedBody);
        print('Parsed JSON map: $jsonData');

        final detailModel = PlanDetailModel.fromJson(jsonData);
        print('Parsed successfully: ${detailModel.permission}');

        return detailModel;
      } catch (e) {
        print("Error decoding response: $e");
        throw Exception('Failed to decode PlanDetail');
      }
    } else {
      print("Error: ${response.statusCode} => ${response.body}");
      throw Exception('Failed to load plan detail: ${response.statusCode}');
    }
  }

  Future<PrepareData> fetchPrepareData(String planDate) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? token = prefs.getString('auth_token');

    if (token == null || token.isEmpty) {
      throw Exception('No authentication token found');
    }

    final uri = Uri.parse('${ApiRoutes.requestPrepare}?plan_date=$planDate');
    print('Fetching data from: $uri');

    final response = await http.get(
      uri,
      headers: {
        'Authorization': 'Bearer $token',
        'Accept': 'application/json',
      },
    );

    print('Response status code: ${response.statusCode}');

    if (response.statusCode == 200) {
      try {
        final decodedBody = utf8.decode(response.bodyBytes);
        print('Raw response body: $decodedBody');  // Выводим необработанный ответ

        final jsonData = json.decode(decodedBody);
        print('Decoded JSON: $jsonData');  // Выводим распарсенный JSON

        PrepareData prepareData = PrepareData.fromJson(jsonData);
        print('Parsed PrepareData: ${prepareData.toString()}');  // Выводим объект PrepareData

        return prepareData;
      } catch (e) {
        print('Error while parsing response: $e');
        throw Exception('Failed to parse response: $e');
      }
    } else {
      print('Error response: ${response.body}');
      throw Exception('Failed to load data: ${response.statusCode}');
    }
  }

  Future<Map<String, dynamic>> submitBplaPlan(Map<String, dynamic> requestBody) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? token = prefs.getString('auth_token');

    if (token == null || token.isEmpty) {
      throw Exception('No authentication token found');
    }

    final uri = Uri.parse('${ApiRoutes.requestCreate}');
    print('Submitting BPLA Plan to: $uri');
    print('Request Body: ${jsonEncode(requestBody)}');

    try {
      final response = await http.post(
        uri,
        headers: {
          'Authorization': 'Bearer $token',
          'Accept': 'application/json',
          'Content-Type': 'application/json',
        },
        body: jsonEncode(requestBody),
      );

      print('Response status code: ${response.statusCode}');

      final decodedBody = utf8.decode(response.bodyBytes);
      print('Raw response body: $decodedBody');

      if (response.statusCode == 200) {
        final jsonData = json.decode(decodedBody);
        print('Decoded JSON: $jsonData');

        return {
          'status': response.statusCode,
          'message': 'Success',
          'data': jsonData,
        };
      } else {
        final errorData = json.decode(decodedBody);
        print('Error response: ${errorData['message']}');

        return {
          'status': response.statusCode,
          'message': errorData['message'] ?? 'Unknown error',
        };
      }
    } catch (e) {
      print('Error while submitting BPLA Plan: $e');
      throw Exception('Failed to submit BPLA plan: $e');
    }
  }



}
