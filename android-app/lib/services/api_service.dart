import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class ApiService {
  static const String baseUrl = 'https://tuition.lucknows.shop/api';
  
  String? _token;
  
  // Singleton pattern
  static final ApiService _instance = ApiService._internal();
  factory ApiService() => _instance;
  ApiService._internal();

  // Initialize and load token
  Future<void> init() async {
    final prefs = await SharedPreferences.getInstance();
    _token = prefs.getString('auth_token');
  }

  // Save token
  Future<void> saveToken(String token) async {
    _token = token;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('auth_token', token);
  }

  // Clear token
  Future<void> clearToken() async {
    _token = null;
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('auth_token');
  }

  // Get headers
  Map<String, String> get _headers {
    final headers = {
      'Content-Type': 'application/json',
      'Accept': 'application/json',
    };
    
    if (_token != null) {
      headers['Authorization'] = 'Bearer $_token';
    }
    
    return headers;
  }

  // GET request
  Future<dynamic> get(String endpoint) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/$endpoint'),
        headers: _headers,
      );
      
      return _handleResponse(response);
    } on ApiException {
      rethrow;
    } catch (e) {
      throw Exception('Network error: $e');
    }
  }

  // POST request
  Future<dynamic> post(
    String endpoint,
    Map<String, dynamic> data,
  ) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/$endpoint'),
        headers: _headers,
        body: jsonEncode(data),
      );
      
      return _handleResponse(response);
    } on ApiException {
      rethrow;
    } catch (e) {
      throw Exception('Network error: $e');
    }
  }

  // PUT request
  Future<dynamic> put(
    String endpoint,
    Map<String, dynamic> data,
  ) async {
    try {
      final response = await http.put(
        Uri.parse('$baseUrl/$endpoint'),
        headers: _headers,
        body: jsonEncode(data),
      );
      
      return _handleResponse(response);
    } on ApiException {
      rethrow;
    } catch (e) {
      throw Exception('Network error: $e');
    }
  }
  Future<dynamic> delete(String endpoint) async {
    try {
      final response = await http.delete(
        Uri.parse('$baseUrl/$endpoint'),
        headers: _headers,
      );
      
      return _handleResponse(response);
    } on ApiException {
      rethrow;
    } catch (e) {
      throw Exception('Network error: $e');
    }
  }
  Future<dynamic> postMultipart(
    String endpoint,
    Map<String, String> fields,
    Map<String, String> files, // key: path
  ) async {
    try {
      final request = http.MultipartRequest('POST', Uri.parse('$baseUrl/$endpoint'));
      
      // Add headers
      _headers.forEach((key, value) {
        if (key != 'Content-Type') { // MultipartRequest sets its own Content-Type
           request.headers[key] = value;
        }
      });

      // Add fields
      fields.forEach((key, value) {
        request.fields[key] = value;
      });

      // Add files
      for (var entry in files.entries) {
        request.files.add(await http.MultipartFile.fromPath(entry.key, entry.value));
      }

      final streamedResponse = await request.send();
      final response = await http.Response.fromStream(streamedResponse);

      return _handleResponse(response);
    } on ApiException {
      rethrow;
    } catch (e) {
      throw Exception('Network error: $e');
    }
  }

  // Handle response
  dynamic _handleResponse(http.Response response) {
    if (response.body.isEmpty) return null;
    final data = jsonDecode(response.body);
    
    if (response.statusCode >= 200 && response.statusCode < 300) {
      return data;
    } else {
      throw ApiException(
        statusCode: response.statusCode,
        message: data is Map ? (data['message'] ?? 'An error occurred') : 'An error occurred',
        errors: data is Map ? data['errors'] : null,
      );
    }
  }
}

class ApiException implements Exception {
  final int statusCode;
  final String message;
  final Map<String, dynamic>? errors;

  ApiException({
    required this.statusCode,
    required this.message,
    this.errors,
  });

  @override
  String toString() => message;
}
