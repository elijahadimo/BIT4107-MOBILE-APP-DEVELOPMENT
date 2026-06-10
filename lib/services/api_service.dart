import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'exceptions.dart';

class ApiService {
  // Replace with your actual backend URL
  static const String baseUrl = 'https://api.kapoeta-logistics.com/v1';
  
  final http.Client _client;

  ApiService({http.Client? client}) : _client = client ?? http.Client();

  Map<String, String> _getHeaders([String? token]) {
    return {
      'Content-Type': 'application/json',
      'Accept': 'application/json',
      if (token != null) 'Authorization': 'Bearer $token',
    };
  }

  Future<dynamic> get(String endpoint, {String? token}) async {
    try {
      final response = await _client.get(
        Uri.parse('$baseUrl$endpoint'),
        headers: _getHeaders(token),
      );
      return _processResponse(response);
    } on SocketException {
      throw NetworkException();
    }
  }

  Future<dynamic> post(String endpoint, Map<String, dynamic> body, {String? token}) async {
    try {
      final response = await _client.post(
        Uri.parse('$baseUrl$endpoint'),
        headers: _getHeaders(token),
        body: json.encode(body),
      );
      return _processResponse(response);
    } on SocketException {
      throw NetworkException();
    }
  }

  dynamic _processResponse(http.Response response) {
    final body = json.decode(response.body);
    
    switch (response.statusCode) {
      case 200:
      case 201:
        return body;
      case 400:
        throw ValidationException(body['message'] ?? 'Bad Request');
      case 401:
        throw UnauthorizedException(body['message'] ?? 'Unauthorized');
      case 403:
        throw UnauthorizedException(body['message'] ?? 'Forbidden');
      case 422:
        throw ValidationException(body['message'] ?? 'Validation Error');
      case 500:
      default:
        throw ApiException(
          'Error occurred while communicating with server',
          response.statusCode,
        );
    }
  }
}
