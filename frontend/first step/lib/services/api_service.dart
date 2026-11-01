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
    // utf8.decode keeps Ukrainian letters correct
    return jsonDecode(utf8.decode(response.bodyBytes)) as List<dynamic>;
  }

  static Future<List<dynamic>> getSubjects() => _getList('/api/subjects');

  static Future<List<dynamic>> getTopics(int subjectId) =>
      _getList('/api/subjects/$subjectId/topics');

  static Future<List<dynamic>> getTopicQuestions(int topicId) =>
      _getList('/api/topics/$topicId/questions');
}