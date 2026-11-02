import 'package:flutter/foundation.dart';

class AuthService {
  // Зберігаємо токен у пам'яті застосунку
  static String? _authToken;

  // Після появи бекенду розкоментувати адресу та HTTP-запити
  // static const String baseUrl = 'http://localhost:8000';

  // Вхід у застосунок (Тимчасова імітація)
  static Future<bool> login(String username, String password) async {
    // Імітуємо невеличку затримку мережі (500 мс)
    await Future.delayed(const Duration(milliseconds: 500));

    // Тимчасово приймаємо будь-який пароль довжиною від 6 символів
    if (username.isNotEmpty && password.length >= 6) {
      _authToken = 'fake_mock_token_for_$username';
      debugPrint('Успішний mock-вхід! Токен: $_authToken');
      return true;
    }

    return false;

    /* 
     HTTP-запит після розгортання бекенду:
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/api/login'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'username': username, 'password': password}),
      );
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        _authToken = data['token'] ?? data['access_token'];
        return true;
      }
      return false;
    } catch (e) {
      debugPrint('Connection error: $e');
      return false;
    }
    */
  }

  // Отримання токену для інших екранів 
  static String? getToken() {
    return _authToken;
  }

  // Вихід з акаунту (Асинхронний метод для сумісності з UI)
  static Future<void> logout() async {
    _authToken = null;
    debugPrint('Користувач вийшов з акаунту. Токен очищено.');

    /* 
     HTTP-запит після розгортання бекенду (якщо серверу потрібно повідомити про логаут):
    try {
      await http.post(
        Uri.parse('$baseUrl/api/logout'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $_authToken',
        },
      );
    } catch (e) {
      debugPrint('Logout network error: $e');
    } finally {
      _authToken = null;
    }
    */
  }

  // Реєстрація користувача (Тимчасова імітація)
  static Future<int> register(String username, String password) async {
    await Future.delayed(const Duration(milliseconds: 500));

    // Тимчасова перевірка: якщо ім'я "admin", вдаємо що воно зайняте (код 409)
    if (username.toLowerCase() == 'admin') {
      return 409;
    }

    // Всі інші імена реєструються успішно (код 201)
    if (username.isNotEmpty && password.length >= 6) {
      return 201;
    }

    return 422;

    /* 
     HTTP-запит після розгортання бекенду:
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/api/register'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'username': username, 'password': password}),
      );
      return response.statusCode;
    } catch (e) {
      return -1;
    }
    */
  }
}
