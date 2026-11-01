import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;

class AuthService {
  // on the Android emulator use http://10.0.2.2:8000
  static const String baseUrl = 'http://127.0.0.1:8000';

  // name of the logged in user (the tickets API identifies users by name)
  static String? _username;

  static String? get currentUser => _username;

  static Future<bool> login(String username, String password) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/api/login'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'username': username, 'password': password}),
      );
      if (response.statusCode == 200) {
        _username = username;
        return true;
      }
      return false;
    } catch (e) {
      debugPrint('Connection error: $e');
      return false;
    }
  }

  // returns the status code: 201 ok, 409 taken, 422 bad input, -1 no connection
  static Future<int> register(String username, String password) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/api/register'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'username': username, 'password': password}),
      );
      return response.statusCode;
    } catch (e) {
      debugPrint('Connection error: $e');
      return -1;
    }
  }

  static void logout() {
    _username = null;
  }
}