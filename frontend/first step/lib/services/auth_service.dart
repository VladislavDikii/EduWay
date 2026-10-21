import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;

class AuthService {
  // on the Android emulator use http://10.0.2.2:8000 instead
  static const String baseUrl = 'http://127.0.0.1:8000';

  // returns true if login succeeded
  static Future<bool> login(String username, String password) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/api/login'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'username': username,
          'password': password,
        }),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        debugPrint('Server answer: $data');
        return true;
      } else {
        debugPrint('Server error: ${response.statusCode}');
        return false;
      }
    } catch (e) {
      debugPrint('Connection error: $e');
      return false;
    }
  }

  // returns the status code: 201 = created, 409 = username taken,
  // 422 = bad input, -1 = no connection
  static Future<int> register(String username, String password) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/api/register'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'username': username,
          'password': password,
        }),
      );
      return response.statusCode;
    } catch (e) {
      debugPrint('Connection error: $e');
      return -1;
    }
  }
}