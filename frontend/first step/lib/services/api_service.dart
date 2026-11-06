import 'dart:convert';
import 'package:http/http.dart' as http;

class ApiService {
  // on the Android emulator use http://10.0.2.2:8000
  static const String baseUrl = 'http://127.0.0.1:8000';

  static Future<List<dynamic>> _getList(String path) async {
    final response = await http.get(Uri.parse('$baseUrl$path'));
    if (response.statusCode != 200) {
      throw Exception('Server error: ${response.statusCode}');
    }
    return jsonDecode(utf8.decode(response.bodyBytes)) as List<dynamic>;
  }

  static Future<Map<String, dynamic>> _post(
      String path, Map<String, dynamic> body, int okCode) async {
    final response = await http.post(
      Uri.parse('$baseUrl$path'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(body),
    );
    if (response.statusCode != okCode) {
      throw Exception('Server error: ${response.statusCode}');
    }
    return jsonDecode(utf8.decode(response.bodyBytes)) as Map<String, dynamic>;
  }

  static Future<List<dynamic>> getSubjects() => _getList('/api/subjects');

  static Future<List<dynamic>> getTopics(int subjectId) =>
      _getList('/api/subjects/$subjectId/topics');

  static Future<List<dynamic>> getTopicQuestions(int topicId) =>
      _getList('/api/topics/$topicId/questions');

  // creates a ticket, answers are not included in the response
  static Future<Map<String, dynamic>> drawTicket(
      String username, int topicId, int count) =>
      _post('/api/tickets/draw', {
        'username': username,
        'topic_id': topicId,
        'count': count,
        'no_repeats': true,
      }, 201);

  // answers: [{"question_id": 3, "chosen_index": 2}, ...]
  static Future<Map<String, dynamic>> submitTicket(
      int ticketId, String username, List<Map<String, dynamic>> answers) =>
      _post('/api/tickets/$ticketId/submit', {
        'username': username,
        'answers': answers,
      }, 200);

  static Future<List<dynamic>> getTickets(String username) =>
      _getList('/api/tickets?username=${Uri.encodeQueryComponent(username)}&limit=20');
}