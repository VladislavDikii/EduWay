import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;

class ApiService {
  static const String baseUrl = 'http://127.0.0.1:8000';

  // 1. Отримання предметів (GET /api/subjects)
  static Future<List<dynamic>> fetchSubjects() async {
    try {
      final response = await http
          .get(Uri.parse('$baseUrl/api/subjects'))
          .timeout(const Duration(seconds: 3));

      if (response.statusCode == 200) {
        return jsonDecode(utf8.decode(response.bodyBytes)) as List<dynamic>;
      }
    } catch (e) {
      debugPrint('Помилка мережі (subjects): $e');
    }

    return [
      {'id': 1, 'name': 'Математичний аналіз', 'questions': 45},
      {'id': 2, 'name': 'Історія України', 'questions': 32},
    ];
  }

  // 2. Отримання тем (GET /api/subjects/{subject_id}/topics)
  static Future<List<dynamic>> fetchTopics(int subjectId) async {
    try {
      final response = await http
          .get(Uri.parse('$baseUrl/api/subjects/$subjectId/topics'))
          .timeout(const Duration(seconds: 3));

      if (response.statusCode == 200) {
        return jsonDecode(utf8.decode(response.bodyBytes)) as List<dynamic>;
      }
    } catch (e) {
      debugPrint('Помилка мережі (topics): $e');
    }
    return [];
  }

  // 3. Перегляд питань теми (GET /api/topics/{topic_id}/questions)
  static Future<List<dynamic>> fetchQuestions(int topicId) async {
    try {
      final response = await http
          .get(Uri.parse('$baseUrl/api/topics/$topicId/questions'))
          .timeout(const Duration(seconds: 3));

      if (response.statusCode == 200) {
        return jsonDecode(utf8.decode(response.bodyBytes)) as List<dynamic>;
      }
    } catch (e) {
      debugPrint('Помилка мережі (questions): $e');
    }
    return [];
  }

  // 4. Створення квитка (POST /api/tickets/draw)
  static Future<Map<String, dynamic>> drawTicket(
    String username,
    int topicId, [
    int count = 5,
    bool noRepeats = true,
  ]) async {
    final response = await http
        .post(
          Uri.parse('$baseUrl/api/tickets/draw'),
          headers: {'Content-Type': 'application/json; charset=UTF-8'},
          body: jsonEncode({
            'username': username,
            'topic_id': topicId,
            'count': count,
            'no_repeats': noRepeats,
          }),
        )
        .timeout(const Duration(seconds: 3));

    if (response.statusCode == 201) {
      return jsonDecode(utf8.decode(response.bodyBytes)) as Map<String, dynamic>;
    } else {
      final error = jsonDecode(utf8.decode(response.bodyBytes));
      throw Exception(error['detail'] ?? 'Не вдалося створити квиток');
    }
  }

  // 5. Здача квитка (POST /api/tickets/{ticket_id}/submit)
  static Future<Map<String, dynamic>> submitTicket(
    int ticketId,
    String username,
    List<Map<String, dynamic>> answers,
  ) async {
    final response = await http
        .post(
          Uri.parse('$baseUrl/api/tickets/$ticketId/submit'),
          headers: {'Content-Type': 'application/json; charset=UTF-8'},
          body: jsonEncode({
            'username': username,
            'answers': answers,
          }),
        )
        .timeout(const Duration(seconds: 3));

    if (response.statusCode == 200) {
      return jsonDecode(utf8.decode(response.bodyBytes)) as Map<String, dynamic>;
    } else {
      final error = jsonDecode(utf8.decode(response.bodyBytes));
      throw Exception(error['detail'] ?? 'Не вдалося відправити відповіді');
    }
  }

  // 6. Історія квитків (GET /api/tickets?username=...)
  static Future<List<dynamic>> fetchTicketsHistory(String username, {int limit = 20}) async {
    try {
      final response = await http
          .get(Uri.parse('$baseUrl/api/tickets?username=$username&limit=$limit'))
          .timeout(const Duration(seconds: 3));

      if (response.statusCode == 200) {
        return jsonDecode(utf8.decode(response.bodyBytes)) as List<dynamic>;
      }
    } catch (e) {
      debugPrint('Помилка завантаження історії квитків: $e');
    }
    return [];
  }
}
