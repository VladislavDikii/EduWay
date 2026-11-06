import 'dart:convert';
import 'dart:ui'; 
import 'package:flutter/material.dart';
import 'package:particles_fly/particles_fly.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter/cupertino.dart';
import 'package:http/http.dart' as http;

import 'page/home_page.dart';
import 'page/topics_page.dart';
import 'page/profile_page.dart';

class HomeScreen extends StatefulWidget {
  final String userName; //зберігає ім'я користувача, передане з екрану входу
  const HomeScreen({ 
    super.key, 
    this.userName = 'Студент', // Значення за замовчуванням, якщо ім'я не передане
  });

  @override
  State<HomeScreen> createState() => _HomeScreenState(); //створює стан для HomeScreen
}

class _HomeScreenState extends State<HomeScreen> {
  bool _isDarkMode = true; //змінна для відстеження темного режиму
  String _selectedTab = 'Home'; //змінна для відстеження обраної вкладки
  String _selectedSubject = 'Математичний аналіз'; //змінна для відстеження обраного предмета
  late Map<String, String> _currentQuote; //змінна для зберігання поточної цитати

  final List<Map<String, String>> _educationQuotes = [
    {
      'text': '"Наука — це організоване знання. Мудрість — це організоване життя."',
      'author': '— Іммануїл Кант'
    },
    {
      'text': '"Важливо не припиняти ставити запитання. Допитливість має власну причину існування."',
      'author': '— Альберт Ейнштейн'
    },
    {
      'text': '"Те, що ми знаємо — обмежене, а те, чого не знаємо — нескінченне."',
      'author': '— Ален Лазар Ампер'
    },
    {
      'text': '"Ніде нічому не навчишся, якщо не любиш свою справу."',
      'author': '— Галілео Галілей'
    },
    {
      'text': '"Знання — це сила, дія — це перемога."',
      'author': '— Френсіс Бекон'
    },
  ];

  @override

  //ініціалізація стану віджета
  void initState() { 
    super.initState();
    _educationQuotes.shuffle(); //перемішує список цитат для випадкового відображення
    _currentQuote = _educationQuotes.first; //встановлює першу цитату як поточну
  }

  //ЗАВАНТАЖЕННЯ ПИТАНЬ З БЕКЕНДУ

  Future<List<dynamic>> _fetchQuestions(int topicId) async {
    try {
      final response = await http.get( //змінна для збереження відповіді від API, виконує GET-запит до вказаного URL
        Uri.parse('http://127.0.0.1:8000/api/topics/$topicId/questions'), //перетворення посилання на URI для запиту до API
      ).timeout(const Duration(seconds: 2)); //встановлює тайм-аут на 2 секунди для запиту

      // Перевірка статусу відповіді від API
      if (response.statusCode == 200) {
        return jsonDecode(utf8.decode(response.bodyBytes)) as List<dynamic>; //декодування JSON-відповіді та перетворення її на список питань
      } 
    } catch (e) {
      debugPrint('Помилка завантаження питань із БД: $e. Використовуються локальні питання.');
    }

    // Резервний список питань
    return [
      {
        'id': 1,
        'topic_id': topicId,
        'text': 'Чому дорівнює границя lim(x→2)(x+3)?',
        'options': ['3', '4', '5', '6'],
        'correct_index': 2,
      },
      {
        'id': 2,
        'topic_id': topicId,
        'text': 'Яке з наступних тверджень є фундаментальною теоремою аналізу?',
        'options': ['Теорема Піфагора', 'Теорема Ньютона-Лейбніца', 'Теорема Вієта', 'Теорема Фалеса'],
        'correct_index': 1,
      }
    ];
  }

  //ЗАВАНТАЖЕННЯ ТЕМ З БЕКЕНДУ

  Future<List<dynamic>> _fetchTopicsForSubject(String subjectName) async {
    int subjectId = (subjectName == 'Історія України') ? 2 : 1; //визначає ID предмета на основі його назви

    final Map<String, List<Map<String, dynamic>>> fallbackTopics = {
      'Математичний аналіз': [
        {'id': 1, 'pos': 1, 'name': 'Границі та неперервність функцій', 'questions': 11},
        {'id': 2, 'pos': 2, 'name': 'Похідна та її застосування', 'questions': 15},
        {'id': 3, 'pos': 3, 'name': 'Невизначений та визначений інтеграли', 'questions': 12},
        {'id': 4, 'pos': 4, 'name': 'Диференціальні рівняння', 'questions': 7},
      ],
      'Історія України': [
        {'id': 5, 'pos': 1, 'name': 'Київська Русь', 'questions': 10},
        {'id': 6, 'pos': 2, 'name': 'Козацька доба', 'questions': 12},
        {'id': 7, 'pos': 3, 'name': 'Україна в XIX столітті', 'questions': 9},
        {'id': 8, 'pos': 4, 'name': 'Українська революція 1917–1921 рр.', 'questions': 5},
      ],
    };
    try {
      final response = await http.get(
        Uri.parse('http://127.0.0.1:8000/api/subjects/$subjectId/topics'),
      ).timeout(const Duration(seconds: 2));

      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(utf8.decode(response.bodyBytes));
        if (data.isNotEmpty) return data;
      }
    } catch (e) {
      debugPrint('Помилка завантаження тем із БД: $e. Використовуємо резервні теми.');
    }

    return fallbackTopics[subjectName] ?? []; //повертає резервні теми
  }

//ФУНКЦІЇ ДЛЯ ЗМІНИ ВИБРАНОГО ПРЕДМЕТА
  void _openSubjectTopics(String subjectName) {
    setState(() {
      _selectedSubject = subjectName;
      _selectedTab = 'Topics';
    });
  }

//ФУНКЦІЯ ДЛЯ ЗМІНИ ВИБРАНОЇ ВКЛАДКИ
  void changeTab(String newTab) {
    setState(() {
      _selectedTab = newTab;
    });
  }

//ФУНКЦІЯ ДЛЯ ЗМІНИ ЦИТАТИ ПРИ ТАПІ
  void _onQuoteTap() {
    setState(() {
      final availableQuotes = _educationQuotes.where((q) => q != _currentQuote).toList();
      availableQuotes.shuffle();
      _currentQuote = availableQuotes.first;
    });
  }

  @override
  Widget build(BuildContext context) {
    final double screenWidth = MediaQuery.of(context).size.width; //отримання ширини екрану
    final double screenHeight = MediaQuery.of(context).size.height; //отримання висоти екрану

    final backgroundColor = _isDarkMode ? const Color(0xFF0E1224) : const Color(0xFFF4F6F9); //встановлення кольору фону
    final surfaceColor = _isDarkMode ? const Color(0xFF15131F) : Colors.white; //встановлення кольору поверхні для контейнерів
    final textColor = _isDarkMode ? Colors.white : const Color(0xFF1C1E22); //встановлення кольору тексту
    final subtitleColor = _isDarkMode ? const Color(0xFF8A94A6) : const Color(0xFF6B7280); //встановлення кольору підзаголовків
    final iconColor = _isDarkMode ? Colors.white : const Color(0xFF1C1E22); //встановлення кольору іконок
    const primaryBlue = Color(0xFF2563EB); //встановлення основного синього кольору

    final bool isHomeActive = _selectedTab == 'Home';
    final bool isTopicsActive = _selectedTab == 'Topics';
    final bool isYouActive = _selectedTab == 'You';

    return AnimatedContainer( //анімований контейнер для зміни кольору фону
      duration: const Duration(milliseconds: 400), //тривалість анімації при зміні кольору
      color: backgroundColor,
      child: Scaffold(
        backgroundColor: Colors.transparent,
        body: Stack( //віджет для розміщення частинок
          children: [
            ParticlesFly( //віджет для створення анімованих частинок на фоні
              key: ValueKey(_isDarkMode),
              height: screenHeight,
              width: screenWidth,
              connectDots: true, //з'єднання частинок лініями
              numberOfParticles: 35, //кількість частинок на екрані
              particleColor: _isDarkMode 
                  ? Colors.white.withValues(alpha: 0.3) 
                  : Colors.black.withValues(alpha: 0.2),
              maxParticleSize: 2.5, //максимальний розмір частинок
              speedOfParticles: 0.8, //швидкість руху частинок
              lineColor: _isDarkMode //встановлення кольору ліній
                  ? const Color.fromARGB(255, 252, 252, 252).withValues(alpha: 0.15) 
                  : Colors.black.withValues(alpha: 0.08),
            ),

            Positioned.fill( //віджет для розмиття фону за допомогою BackdropFilter
              child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 1.5, sigmaY: 1.5),
                child: Container(color: Colors.transparent), //прозорий контейнер
              ),
            ),

            //APP BAR
            SafeArea(
              child: Column(
                children: [
                  AnimatedContainer( //анімований контейнер для верхньої панелі
                    duration: const Duration(milliseconds: 400),
                    margin: const EdgeInsets.only(left: 16.0, right: 16.0, top: 12.0, bottom: 8.0), //відступи від країв екрану
                    padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 10.0), //внутрішні відступи всередині контейнера
                    decoration: BoxDecoration(
                      color: surfaceColor.withValues(alpha: 0.85), //встановлення кольору поверхні з прозорістю
                      borderRadius: BorderRadius.circular(16.0), //закруглення кутів контейнера
                      border: Border.all( //встановлення обводки навколо контейнера
                        color: _isDarkMode 
                            ? const Color.fromARGB(255, 68, 73, 99) 
                            : Colors.black.withValues(alpha: 0.1),
                        width: 1.5,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.2),
                          blurRadius: 12,
                          spreadRadius: 1,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        
                        //назва додатку
                        Row(
                          children: [
                            Text(
                              'EduWay',
                              style: GoogleFonts.pixelifySans(
                                textStyle: TextStyle(
                                  color: textColor,
                                  fontSize: 35,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ],
                        ),

                        //навігація
                        Row(
                          children: [
                            NavItem(
                              title: 'Home',
                              icon: CupertinoIcons.home,
                              isActive: isHomeActive, //визначає, чи активна вкладка "Home"
                              textColor: textColor, //встановлює колір тексту для вкладки
                              onTap: () => changeTab('Home'),
                            ),
                            const SizedBox(width: 12),
                            NavItem(
                              title: 'Topics',
                              icon: CupertinoIcons.doc_on_doc,
                              isActive: isTopicsActive,
                              textColor: textColor,
                              onTap: () => changeTab('Topics'),
                            ),
                            const SizedBox(width: 12),
                            NavItem(
                              title: 'You',
                              icon: CupertinoIcons.person,
                              isActive: isYouActive,
                              textColor: textColor,
                              onTap: () => changeTab('You'),
                            ),
                          ],
                        ),

                        //кнопки для темного режиму та налаштувань
                        Row(
                          children: [
                            IconButton(
                              icon: AnimatedSwitcher( //анімований перемикач для іконки
                                duration: const Duration(milliseconds: 300),
                                child: Icon(
                                  _isDarkMode ? Icons.light_mode : Icons.dark_mode,
                                  key: ValueKey(_isDarkMode),
                                  color: iconColor,
                                ),
                              ),
                              onPressed: () {
                                setState(() {
                                  _isDarkMode = !_isDarkMode;
                                });
                              },
                            ),

                            IconButton(
                              onPressed: () {}, //НЕ ПРАЦЮЄ НАЛАШТУВАННЯ
                              icon: Icon(Icons.settings_rounded, color: iconColor),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),

                  Expanded(
                    child: Padding( 
                      padding: const EdgeInsets.only(left: 16.0, right: 16.0, bottom: 16.0, top: 8.0),
                      child: _buildBodyContent(surfaceColor, textColor, subtitleColor, primaryBlue),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  //функція для побудови основного вмісту залежно від обраної вкладки
  Widget _buildBodyContent(Color surfaceColor, Color textColor, Color subtitleColor, Color primaryBlue) {
    switch (_selectedTab) {
      case 'Topics':
        return TopicsPage(
          selectedSubject: _selectedSubject, //передає обраний предмет
          userName: widget.userName, //передає ім'я користувача
          surfaceColor: surfaceColor,
          textColor: textColor,
          subtitleColor: subtitleColor,
          isDarkMode: _isDarkMode,
          fetchTopics: _fetchTopicsForSubject, //передає функцію для завантаження тем
          fetchQuestions: _fetchQuestions, //передає функцію для завантаження питань
        );
      case 'You':
        return ProfilePage(
          userName: widget.userName,
          surfaceColor: surfaceColor,
          textColor: textColor,
        );
      case 'Home':
      default:
        return HomePage(
          userName: widget.userName,
          surfaceColor: surfaceColor,
          textColor: textColor,
          subtitleColor: subtitleColor,
          primaryBlue: primaryBlue,
          currentQuote: _currentQuote, //передає поточну цитату
          onSubjectTap: _openSubjectTopics, //передає функцію для відкриття тем предмета
          onQuoteTap: _onQuoteTap, //передає функцію для зміни цитати
        );
    }
  }
}

class NavItem extends StatelessWidget { //клас для віджету навігації
  final String title;
  final IconData icon;
  final bool isActive;
  final Color textColor;
  final VoidCallback onTap;

  const NavItem({ //конструктор для NavItem
    super.key,
    required this.title,
    required this.icon,
    required this.isActive,
    required this.textColor,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final activeColor = textColor == Colors.white ? const Color.fromARGB(255, 64, 82, 247) : const Color(0xFF2563EB);
    final inactiveColor = textColor.withValues(alpha: 0.6);

    return TextButton.icon(
      onPressed: onTap,
      icon: Icon(
        icon,
        color: isActive ? activeColor : inactiveColor,
        size: 18,
      ),
      label: Text(
        title,
        style: TextStyle(
          color: isActive ? activeColor : textColor,
          fontWeight: isActive ? FontWeight.bold : FontWeight.w500,
        ),
      ),
    );
  }
}