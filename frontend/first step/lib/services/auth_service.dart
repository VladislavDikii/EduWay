import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;

class AuthService {
  static const String baseUrl = 'http://127.0.0.1:8000';

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
        debugPrint('Відповідь від Python: $data');
        return true;
      } else {
        debugPrint('Помилка сервера: ${response.statusCode}');
        return false;
      }
    } catch (e) {
      debugPrint('Помилка зєднання: $e');
      return false;
    }
  }
}