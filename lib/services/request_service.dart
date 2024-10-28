import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/request_model.dart';

class RequestService {
  final String apiUrl = 'https://your-api-url.com';

  Future<http.Response> submitRequest(RequestModel request) async {
    final response = await http.post(
      Uri.parse('$apiUrl/requests'),
      headers: {
        'Content-Type': 'application/json',
      },
      body: jsonEncode(request.toJson()),
    );

    if (response.statusCode == 201) {
      return response;
    } else {
      throw Exception('Failed to submit request');
    }
  }

  // Метод для получения списка заявок (если потребуется)
  Future<List<RequestModel>> fetchRequests() async {
    final response = await http.get(Uri.parse('$apiUrl/requests'));

    if (response.statusCode == 200) {
      List<dynamic> data = json.decode(response.body);
      return data.map((item) => RequestModel.fromJson(item)).toList();
    } else {
      throw Exception('Failed to load requests');
    }
  }
}
