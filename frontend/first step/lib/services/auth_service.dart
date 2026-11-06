import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;

class AuthService {
  static const String baseUrl = 'http://127.0.0.1:8000';

  // name of the logged in user, sent with ticket requests
  static String? username;

  static Future<int> register(String name, String password) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/api/register'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'username': name, 'password': password}),
      );
      return response.statusCode;
    } catch (e) {
      debugPrint('Register error: $e');
      return -1;
    }
  }

  static Future<bool> login(String name, String password) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/api/login'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'username': name, 'password': password}),
      );
      if (response.statusCode == 200) {
        username = name;
        return true;
      }
      return false;
    } catch (e) {
      debugPrint('Login error: $e');
      return false;
    }
  }

  static String? getToken() => username;

  static Future<void> logout() async {
    username = null;
  }
}