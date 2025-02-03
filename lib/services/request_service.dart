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

  Future<StatusModel> getRequestStatus(String requestId) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? token = prefs.getString('auth_token');

    await Future.delayed(Duration(seconds: 1));

    return StatusModel(
      id: requestId,
      status: RequestStatus.active,
      message: 'Request status retrieved successfully',
    );


    final response = await http.get(
      Uri.parse('${ApiRoutes.checkRequestStatus}/$requestId'), // Замените на ваш URL
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
    );

    if (response.statusCode == 200) {
      var jsonResponse = json.decode(response.body);
      return StatusModel.fromJson(jsonResponse);
    } else {
      var errorMessage = json.decode(response.body)['message'] ?? 'Failed to retrieve request status';
      throw Exception(errorMessage);
    }
  }

  Future<StatusModel> sendCodeAndGetStatus(String code) async {
    // Получаем токен из SharedPreferences
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? token = prefs.getString('auth_token');

    if (token == null) {
      throw Exception('Authentication token not found');
    }

    // Подготовка данных для запроса
    final requestData = {
      'code': code,
      'token': token,
    };

    // Выполнение HTTP POST запроса
    final response = await http.post(
      Uri.parse(ApiRoutes.sendCodeAndGetStatus),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': Config.basicAuth,
      },
      body: jsonEncode(requestData),
    );

    if (response.statusCode == 200) {
      // Обработка успешного ответа
      var jsonResponse = json.decode(response.body);
      return StatusModel.fromJson(jsonResponse);
    } else {
      // Обработка ошибки
      var errorMessage = json.decode(response.body)['message'] ?? 'Failed to retrieve status';
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

  // Метод для получения списка моделей с параметром lang
  Future<List<Bpla>> fetchModels(String lang) async {
    // Заглушка для тестирования
    return [
      Bpla(id: 1,  name: 'Model 1', type: 'БПЛА', regnum: '12'),
      Bpla(id: 2,  name: 'Model 2', type: 'БПЛА', regnum: '231'),
    ];


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
  Future<List<String>> fetchPurposes(String lang) async {
    // Заглушка для тестирования
    return [
      'Tourism',
      'Research',
    ];


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

  // Временная функция для генерации тестовых данных
  List<RequestModel> generateTestRequests(int batch, int batchSize) {
    final random = Random();

    // Функция для генерации случайных координат (список объектов LocationModel)
    List<LocationModel> generateRandomCoordinates(int count) {
      return List.generate(count, (index) {
        final latitude = 41.1 + 0.1*random.nextDouble();
        final longitude = 69.1 + 0.1*random.nextDouble();
        return LocationModel(
          id: '${random.nextInt(100000)}', // уникальный id для каждой точки
          latitude: latitude,
          longitude: longitude,
        );
      });
    }

    return List.generate(
      batchSize,
          (index) {
        final id = '${batch * batchSize + index}';
        final number = '${batch * batchSize + index + 1}';
        final status = index % 3 == 0 ? 'confirmed' : index % 3 == 1 ? 'pending' : 'rejected';
        final requesterName = 'Requester ${batch * batchSize + index + 1}';
        final operatorName = 'Operator ${index + 1}';
        final operatorPhone = '+99899${random.nextInt(9000000) + 1000000}';
        final email = 'test${index}@example.com';
        final permitNumber = '${random.nextInt(1000000)}';
        final contractNumber = '${random.nextInt(1000000)}';
        final note = 'Sample note for request ${number}';
        final model = 'Model ${index + 1}';
        final region = 'Region ${index + 1}';
        final purpose = 'Purpose ${index + 1}';
        final flightSign = 'Sign ${index + 1}';
        final flightHeight = 50.0 + random.nextDouble() * 150; // Генерация высоты полета
        final startDate = DateTime.now().subtract(Duration(days: random.nextInt(30)));
        final flightStartDateTime = DateTime.now().subtract(Duration(days: random.nextInt(10)));
        final flightEndDateTime = DateTime.now().add(Duration(days: random.nextInt(10)));
        final permitDate = DateTime.now().subtract(Duration(days: random.nextInt(60)));
        final contractDate = DateTime.now().subtract(Duration(days: random.nextInt(60)));
        final lang = 'en';

        // Генерация областей
        final area = [
          // Запрещенная зона с координатами для полигона
          AreaPointLocationModel(
            id: '${random.nextInt(100000)}',
            tag: AreaType.authorizedZone, // Запрещенная зона
            coordinates: generateRandomCoordinates(4), // Полигона с 4 точками
          ),
          // Разрешенная область с кругом, где определены только центральные координаты и радиус
          AreaPointLocationModel(
            id: '${random.nextInt(100000)}',
            tag: AreaType.noFlyZone, // Разрешенная зона
            latitude: 41.0 + random.nextDouble(), // Центральная широта
            longitude: 69.0 + random.nextDouble(), // Центральная долгота
            radius: 1000.0 + random.nextDouble() * 500, // Радиус круга
          ),
          AreaPointLocationModel(
            id: '${random.nextInt(100000)}',
            tag: AreaType.authorizedZone, // Разрешенная зона
            latitude: 41.4221,
            longitude: 69.5021 , // Центральная долгота
            radius: 1000.0, // Радиус круга
          ),
        ];

        return RequestModel(
          id: id,
          number: number,
          status: status,
          requesterName: requesterName,
          operatorName: operatorName,
          operatorPhone: operatorPhone,
          email: email,
          permitNumber: permitNumber,
          contractNumber: contractNumber,
          note: note,
          model: model,
          region: region,
          purpose: purpose,
          flightSign: flightSign,
          flightHeight: flightHeight, // Новый параметр
          startDate: startDate,
          flightStartDateTime: flightStartDateTime,
          flightEndDateTime: flightEndDateTime,
          permitDate: permitDate,
          contractDate: contractDate,
          lang: lang,
          area: area, // Добавление списка разрешенных и запрещенных участков
        );
      },
    );
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



  PlanDetailModel generateTestPlanDetailModel() {
    return PlanDetailModel(
      planId: 1,
      planDate: DateTime.now(),
      applicantId: 100,
      applicant: "Test Applicant",
      applicationNum: "12345",
      timeFrom: "2025-02-02T15:27:57.823Z",
      timeTo: "2025-02-02T15:27:57.823Z",
      flightArea: "Test Flight Area, Some Region",
      zoneTypeId: 1,
      zoneType: "радиус от точки",
      purpose: "Тестирование",
      operatorList: [
        OperatorModel(
          id: 1,
          surname: "Иванов",
          name: "Иван",
          patronymic: "Иванович",
          phone: "+1234567890",
        ),
      ],
      bplaList: [
        BplaModel(
          id: 1,
          type: "БПЛА",
          name: "Test Drone",
          regnum: "ABC123",
        ),
      ],
      coordList: [
        CoordModel(
          latitude: "400530N",
          longitude: "0645754E",
          radius: 1000,
        ),
      ],
      operatorPhones: "+1234567890",
      email: "test@example.com",
      notes: "Тестовые примечания",
      permission: PermissionModel(
        orgName: "Test Organization",
        docNum: "DOC-123",
        docDate: DateTime.now(),
      ),
      agreement: AgreementModel(
        docNum: "AG-123",
        docDate: DateTime.now(),
      ),
      source: "Test Source",
      stateId: 2,
      state: "Test State",
      checkUrl: "https://example.com/check",
      cancelReason: "Test cancel reason",
      uuid: "f9de2cfb-a0e5-41b8-bc79-3c3500d8f482",
      execStateId: 1,
      execState: "Test Execution State",
      activity: 1,
      mAltitude: 500,
      fAltitude: 1640.42,
    );
  }


  Future<PlanDetailModel> fetchPlanDetail(int planId) async {
    // 1. Получаем токен
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? token = prefs.getString('auth_token');

    return generateTestPlanDetailModel();
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
