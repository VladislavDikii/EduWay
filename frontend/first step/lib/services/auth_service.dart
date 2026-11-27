import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;

class AuthService {
  static const String baseUrl = 'http://127.0.0.1:8000';
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

   static Future<void> logout() async {
    username = null; // forget the user first, so logout works even if the server is down
    try {
      await http.post(Uri.parse('$baseUrl/api/logout'));
    } catch (e) {
      debugPrint('Logout error: $e');
    }
  }

  // Зміна імені користувача (PUT /api/username).
  // Повертає код відповіді: 200 - успіх, 401 - невірний пароль,
  // 409 - ім'я зайняте, -1 - немає зв'язку з сервером.
  static Future<int> changeUsername(String newName, String password) async {
    final current = username;
    if (current == null) return 401;
    try {
      final response = await http
          .put(
            Uri.parse('$baseUrl/api/username'),
            headers: {'Content-Type': 'application/json; charset=UTF-8'},
            body: jsonEncode({
              'username': current,
              'password': password,
              'new_username': newName,
            }),
          )
          .timeout(const Duration(seconds: 5));
      if (response.statusCode == 200) {
        username = newName;
      }
      return response.statusCode;
    } catch (e) {
      debugPrint('Change username error: $e');
      return -1;
    }
  }
}
