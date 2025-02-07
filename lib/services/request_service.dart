import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../config/api_routes.dart';
import '../config/config.dart';
import '../models/plan_detail_model.dart';
import '../models/prepare_model.dart';
import '../models/request_model.dart';
import '../models/request_model_main.dart';
import 'auth_service.dart';

class RequestService {
  final AuthService _authService = AuthService();

  /// Получение базовых заголовков из AuthService.
  Future<Map<String, String>> _getDefaultHeaders() async {
    return await _authService.getDefaultHeaders();
  }

  /// Получение auth_token из SharedPreferences.
  Future<String?> _getToken() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getString('auth_token');
  }

  /// Универсальная обёртка для запросов, требующих авторизации.
  /// Принимает функцию с двумя параметрами:
  /// [token] и [defaultHeaders] – базовые заголовки.
  /// Если сервер возвращает 401, производится попытка обновления токена и повторного запроса.
  Future<http.Response> _makeAuthorizedRequest(
      Future<http.Response> Function(String token, Map<String, String> defaultHeaders)
      requestFunc) async {
    String? token = await _getToken();
    if (token == null || token.isEmpty) {
      throw Exception('No authentication token found');
    }
    final defaultHeaders = await _getDefaultHeaders();
    var response = await requestFunc(token, defaultHeaders);
    if (response.statusCode == 401) {
      // Пытаемся обновить токен через AuthService.
      bool refreshed = await _authService.tokenRefresh();
      if (!refreshed) {
        throw Exception('Unauthorized and failed to refresh token');
      }
      token = await _getToken();
      if (token == null || token.isEmpty) {
        throw Exception('Token is null after refresh');
      }
      response = await requestFunc(token, defaultHeaders);
    }
    return response;
  }

  /// Метод для отмены запроса.
  /// Если planId равен 0 (тестовые данные) – возвращается тестовый ответ.
  Future<http.Response> cancelRequest(int planId, String cancelReason) async {
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
    print('Body: ${jsonEncode(requestBody)}');

    final response = await _makeAuthorizedRequest((token, defaultHeaders) async {
      final headers = {
        ...defaultHeaders,
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json; charset=utf-8',
      };
      print('Using token: $token');
      return await http.post(
        url,
        headers: headers,
        body: jsonEncode(requestBody),
      );
    });

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
  }

  /// Метод для удаления запроса.
  /// Если planId равен 0 (тестовые данные) – возвращается тестовый ответ.
  Future<http.Response> deleteRequest(int planId) async {
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

    final response = await _makeAuthorizedRequest((token, defaultHeaders) async {
      final headers = {
        ...defaultHeaders,
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json; charset=utf-8',
      };
      print('Using token: $token');
      return await http.post(url, headers: headers);
    });

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
  }

  /// Метод для получения списка основных заявок с пагинацией.
  Future<List<RequestModelMain>> fetchMainRequests({int page = 1, int count = 10}) async {
    final response = await _makeAuthorizedRequest((token, defaultHeaders) async {
      final headers = {
        ...defaultHeaders,
        'Authorization': 'Bearer $token',
      };
      print('Fetching main requests using token: $token');
      return await http.get(
        Uri.parse('${ApiRoutes.requestList}?page=$page&count=$count'),
        headers: headers,
      );
    });

    print("API Response (raw bytes): ${response.bodyBytes}");

    if (response.statusCode == 200) {
      try {
        // Используем latin1-декодирование, как в исходном коде.
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

  /// Метод для получения детальной информации плана по planId.
  Future<PlanDetailModel> fetchPlanDetail(int planId) async {
    final Uri url = Uri.parse('${ApiRoutes.requestDetailInfo}$planId');
    final response = await _makeAuthorizedRequest((token, defaultHeaders) async {
      final headers = {
        ...defaultHeaders,
        'Authorization': 'Bearer $token',
      };
      print('Fetching plan detail for planId=$planId using token: $token');
      return await http.get(url, headers: headers);
    });

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

  /// Метод для получения детальной информации плана по UUID.
  Future<PlanDetailModel> fetchPlanDetailByUuid(String uuid) async {
    final Uri url = Uri.parse('${ApiRoutes.requestDetailInfoByUuid}$uuid');
    final response = await _makeAuthorizedRequest((token, defaultHeaders) async {
      final headers = {
        ...defaultHeaders,
        'Authorization': 'Bearer $token',
      };
      print('Fetching plan detail by uuid=$uuid using token: $token');
      return await http.get(url, headers: headers);
    });

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

  /// Метод для получения данных подготовки по плановой дате.
  Future<PrepareData> fetchPrepareData(String planDate) async {
    final Uri uri = Uri.parse('${ApiRoutes.requestPrepare}?plan_date=$planDate');
    print('Fetching prepare data from: $uri');

    final response = await _makeAuthorizedRequest((token, defaultHeaders) async {
      final headers = {
        ...defaultHeaders,
        'Authorization': 'Bearer $token',
      };
      print('Using token: $token');
      return await http.get(uri, headers: headers);
    });

    print('Response status code: ${response.statusCode}');

    if (response.statusCode == 200) {
      try {
        final decodedBody = utf8.decode(response.bodyBytes);
        print('Raw response body: $decodedBody');
        final jsonData = json.decode(decodedBody);
        print('Decoded JSON: $jsonData');
        PrepareData prepareData = PrepareData.fromJson(jsonData);
        print('Parsed PrepareData: ${prepareData.toString()}');
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

  /// Метод для отправки (создания) плана BPLA.
  Future<Map<String, dynamic>> submitBplaPlan(Map<String, dynamic> requestBody) async {
    final Uri uri = Uri.parse('${ApiRoutes.requestCreate}');
    print('Submitting BPLA Plan to: $uri');
    print('Request Body: ${jsonEncode(requestBody)}');

    final response = await _makeAuthorizedRequest((token, defaultHeaders) async {
      final headers = {
        ...defaultHeaders,
        'Authorization': 'Bearer $token',
      };
      print('Using token: $token');
      return await http.post(uri, headers: headers, body: jsonEncode(requestBody));
    });

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
  }
}
