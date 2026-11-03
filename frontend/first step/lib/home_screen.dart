import 'dart:convert';
import 'dart:ui'; 
import 'package:flutter/material.dart';
import 'package:particles_fly/particles_fly.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter/cupertino.dart';
import 'package:http/http.dart' as http;
import 'test_screen.dart';
import 'services/auth_service.dart';
import 'main.dart';

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
  void initState() { 
    super.initState(); //ініціалізація стану, викликається при створенні віджета
    _educationQuotes.shuffle(); //перемішує список цитат для випадкового відображення
    _currentQuote = _educationQuotes.first; //встановлює першу цитату як поточну
  }

  //ЗАВАНТАЖЕННЯ ПИТАНЬ З БЕКЕНДУ

  Future<List<dynamic>> _fetchQuestions(int topicId) async {
    try {
      final response = await http.get( //змінна для збереження відповіді від API, виконує GET-запит до вказаного URL
        Uri.parse('http://127.0.0.1:8000/api/topics/$topicId/questions'), //перетворення посилання на URI для запиту до API
      );

      // Перевірка статусу відповіді від API
      if (response.statusCode == 200) {
        return jsonDecode(utf8.decode(response.bodyBytes)) as List<dynamic>; //декодування JSON-відповіді та перетворення її на список питань
      } else {
        debugPrint('Помилка сервера при отриманні питань: ${response.statusCode}');
        return [];
      }
    } catch (e) {
      debugPrint('Помилка підключення до API (питання): $e');
      return [];
    }
  }

  //ЗАВАНТАЖЕННЯ ТЕМ З БЕКЕНДУ

  Future<List<dynamic>> _fetchTopicsForSubject(String subjectName) async {
    int subjectId = (subjectName == 'Історія України') ? 2 : 1;
    try {
      final response = await http.get(
        Uri.parse('http://127.0.0.1:8000/api/subjects/$subjectId/topics'),
      );
      if (response.statusCode == 200) {
        return jsonDecode(utf8.decode(response.bodyBytes)) as List<dynamic>;
      }
    } catch (e) {
      debugPrint('Помилка підключення до API (теми): $e');
    }
    return [];
  }

//ФУНКЦІЇ ДЛЯ ЗМІНИ ВИБРАНОГО ПРЕДМЕТА ТА ВКЛАДКИ

  void _openSubjectTopics(String subjectName) {
    setState(() {
      _selectedSubject = subjectName;
      _selectedTab = 'Topics';
    });
  }
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
    const primaryBlue = Color(0xFF2563EB); //встановлення основного синього кольору для кнопок та іконок

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

            SafeArea(
              child: Column(
                children: [
                  AnimatedContainer( //анімований контейнер для верхньої панелі з логотипом та навігацією
                    duration: const Duration(milliseconds: 400), //тривалість анімації при зміні кольору та стилю
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

                        Row(
                          children: [
                            //Використання NavItem для створення навігаційних кнопок
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
                              onPressed: () {},
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

//ФУНКЦІЇ ДЛЯ ВІДОБРАЖЕННЯ КОНТЕНТУ ВІДПОВІДНО ДО ВИБРАНОЇ ВКЛАДКИ

  Widget _buildBodyContent(Color surfaceColor, Color textColor, Color subtitleColor, Color primaryBlue) {
    switch (_selectedTab) {
      case 'Topics':
        return _buildTopicsPage(surfaceColor, textColor, subtitleColor);
      case 'You':
        return _buildYouPage(surfaceColor, textColor);
      case 'Home':
      default:
        return _buildHomePage(surfaceColor, textColor, subtitleColor, primaryBlue);
    }
  }

  Widget _buildHomePage(Color surfaceColor, Color textColor, Color subtitleColor, Color primaryBlue) {
    return SingleChildScrollView( //дозволяє прокручувати вміст, якщо він перевищує висоту екрану
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            flex: 2,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(24.0),
                  decoration: BoxDecoration(
                    gradient: const LinearGradient( //створює градієнтний фон для контейнера
                      colors: [Color(0xFF1E3A8A), Color(0xFF15131F)],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(16.0),
                  ),
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(12.0),
                        decoration: BoxDecoration(
                          color: primaryBlue.withValues(alpha: 0.3),
                          borderRadius: BorderRadius.circular(12.0),
                        ),
                        child: const Icon(Icons.school, color: Colors.blueAccent, size: 40),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              "Раді тебе бачити, ${widget.userName}!",
                              style: GoogleFonts.pixelifySans(
                                textStyle: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 22,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                            const SizedBox(height: 6),
                            Text(
                              'EduWay допоможе тобі підготуватися до екзаменів і впевнено скласти їх. Обирай предмет і починай!',
                              style: GoogleFonts.roboto(
                                color: Colors.white70,
                                fontSize: 13,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 20),

                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Мої предмети',
                          style: GoogleFonts.pixelifySans(
                            textStyle: TextStyle(
                              color: textColor,
                              fontSize: 22,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          'Обирай предмет, щоб почати підготовку',
                          style: GoogleFonts.roboto(color: subtitleColor, fontSize: 12),
                        ),
                      ],
                    ),

                    // Кнопка для додавання нового предмета
                    ElevatedButton.icon(
                      onPressed: () {},
                      icon: const Icon(Icons.add, size: 18, color: Colors.white),
                      label: const Text('Додати предмет', style: TextStyle(color: Colors.white)),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: primaryBlue,
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 16),

                Row(
                  children: [
                    Expanded(
                      child: _buildSubjectCard( //створює картку предмета
                        title: 'Математичний аналіз',
                        questionsCount: '45 питань',
                        icon: Icons.calculate_outlined,
                        iconBgColor: const Color(0xFF2563EB), //встановлює колір фону іконки
                        surfaceColor: surfaceColor, //встановлює колір поверхні картки
                        textColor: textColor,
                        subtitleColor: subtitleColor, 
                        onViewTap: () => _openSubjectTopics('Математичний аналіз'), //викликає функцію для відкриття тем предмета
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _buildSubjectCard(
                        title: 'Історія України',
                        questionsCount: '32 питання',
                        icon: Icons.account_balance_outlined,
                        iconBgColor: const Color(0xFF7C3AED),
                        surfaceColor: surfaceColor,
                        textColor: textColor,
                        subtitleColor: subtitleColor,
                        onViewTap: () => _openSubjectTopics('Історія України'),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

          const SizedBox(width: 16),

          Expanded(
            flex: 1,
            child: Column(
              children: [

                //ВІДЖЕТ ДЛЯ ВІДОБРАЖЕННЯ ОСТАННЬОГО КВИТКА
                Container(
                  padding: const EdgeInsets.all(16.0),
                  decoration: BoxDecoration(
                    color: surfaceColor.withValues(alpha: 0.85),
                    borderRadius: BorderRadius.circular(16.0),
                    border: Border.all(
                      color: _isDarkMode ? Colors.white.withValues(alpha: 0.05) : Colors.black.withValues(alpha: 0.05),
                    ),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Row(
                            children: [
                              const Icon(Icons.access_time_rounded, color: Colors.blueAccent, size: 18),
                              const SizedBox(width: 8),
                              Text('Останній квиток', style: TextStyle(color: textColor, fontWeight: FontWeight.bold, fontSize: 13)),
                            ],
                          ),
                          Icon(Icons.chevron_right, color: subtitleColor, size: 18),
                        ],
                      ),
                      const SizedBox(height: 12),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text('22 жовт. 2026 • 14:32', style: TextStyle(color: subtitleColor, fontSize: 11)),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                            decoration: BoxDecoration(
                              color: const Color(0xFF6D28D9).withValues(alpha: 0.3),
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: const Text('Завершено', style: TextStyle(color: Color(0xFFA78BFA), fontSize: 10, fontWeight: FontWeight.bold)),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 16),

                //ВІДЖЕТ ДЛЯ ВІДОБРАЖЕННЯ ЦИТАТИ

                InkWell( //віджет для обробки натискань на контейнер
                  onTap: _onQuoteTap, //викликає функцію для зміни цитати
                  borderRadius: BorderRadius.circular(16.0),
                  child: Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(16.0),
                    decoration: BoxDecoration(
                      color: surfaceColor.withValues(alpha: 0.85),
                      borderRadius: BorderRadius.circular(16.0),
                      border: Border.all(
                        color: _isDarkMode ? Colors.white.withValues(alpha: 0.05) : Colors.black.withValues(alpha: 0.05),
                      ),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('“', style: TextStyle(color: Colors.blue, fontSize: 36, height: 0.8, fontFamily: 'serif')),
                        Text(_currentQuote['text']!, style: TextStyle(color: textColor, fontSize: 12, fontStyle: FontStyle.italic)),
                        const SizedBox(height: 8),
                        Text(_currentQuote['author']!, style: TextStyle(color: subtitleColor, fontSize: 11)),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  //ФУНКЦІЇ ДЛЯ ВІДОБРАЖЕННЯ ТЕМ 

  Widget _buildTopicsPage(Color surfaceColor, Color textColor, Color subtitleColor) {
    return FutureBuilder<List<dynamic>>(
      future: _fetchTopicsForSubject(_selectedSubject), //викликає функцію для отримання тем з API
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) { //перевіряє стан підключення до API, якщо очікує відповіді, відображає індикатор завантаження
          return const Center(child: CircularProgressIndicator()); //індикатор завантаження
        }

        final dbTopics = snapshot.data ?? []; //отримує дані з API або порожній список, якщо дані відсутні

        return SingleChildScrollView( //віджет для прокручування вмісту
          child: Container(
            width: double.infinity,
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: surfaceColor.withValues(alpha: 0.85),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: _isDarkMode ? Colors.white.withValues(alpha: 0.05) : Colors.black.withValues(alpha: 0.05),
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  _selectedSubject,
                  style: GoogleFonts.pixelifySans(
                    textStyle: TextStyle(color: textColor, fontSize: 28, fontWeight: FontWeight.bold),
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Обирайте тему для перегляду та проходження квитків:',
                  style: TextStyle(color: subtitleColor, fontSize: 14),
                ),
                const SizedBox(height: 20),

                if (dbTopics.isEmpty)
                  const Padding(
                    padding: EdgeInsets.symmetric(vertical: 20.0),
                    child: Text('Теми не знайдені або БД не запущена.', style: TextStyle(color: Colors.white70)),
                  )
                else
                  ListView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: dbTopics.length,
                    itemBuilder: (context, index) {
                      final topicData = dbTopics[index];
                      final int realTopicId = topicData['id'];
                      final String topicName = topicData['name'] ?? 'Тема ${index + 1}';

                      return Container(
                        margin: const EdgeInsets.only(bottom: 12),
                        decoration: BoxDecoration(
                          color: _isDarkMode ? Colors.white.withValues(alpha: 0.05) : Colors.black.withValues(alpha: 0.03),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: _isDarkMode ? Colors.white.withValues(alpha: 0.1) : Colors.black.withValues(alpha: 0.1),
                          ),
                        ),
                        child: ListTile(
                          leading: CircleAvatar(
                            backgroundColor: const Color(0xFF2563EB),
                            child: Text(
                              '${index + 1}',
                              style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                            ),
                          ),
                          title: Text(
                            topicName,
                            style: TextStyle(color: textColor, fontWeight: FontWeight.w500),
                          ),
                          trailing: Icon(Icons.arrow_forward_ios_rounded, color: subtitleColor, size: 16),
                          onTap: () async {
                            final navigator = Navigator.of(context);
                            
                            // Запит за правильним topic_id з БД
                            final questions = await _fetchQuestions(realTopicId);

                            if (!mounted) return;

                            navigator.push(
                              MaterialPageRoute(
                                builder: (context) => TestScreen(
                                  topicTitle: topicName,
                                  subjectTitle: _selectedSubject,
                                  questions: questions,
                                ),
                              ),
                            );
                          },
                        ),
                      );
                    },
                  ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildYouPage(Color surfaceColor, Color textColor) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: surfaceColor.withValues(alpha: 0.85),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Профіль користувача', 
            style: GoogleFonts.pixelifySans(textStyle: TextStyle(color: textColor, fontSize: 28)),
          ),
          const SizedBox(height: 12),
          
           // Блок з інформацією про студента
          Row(
            children: [
              const CircleAvatar(
                radius: 30,
                backgroundColor: Color(0xFF2563EB),
                child: Icon(Icons.person, size: 35, color: Colors.white),
              ),
              const SizedBox(width: 16),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    widget.userName,
                    style: TextStyle(color: textColor, fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                  Text(
                    'Статус: Студент',
                    style: TextStyle(color: textColor.withValues(alpha: 0.5), fontSize: 14),
                  ),
                ],
              ),
            ],
          ),
          
          const Divider(height: 40, color: Colors.white24),
          
          Text(
            'Тут відображається ваш прогрес.', 
            style: TextStyle(color: textColor.withValues(alpha: 0.7), fontSize: 16),
          ),
          
          const Spacer(), // Зміщує кнопку в самий низ екрана
          
           // Червона кнопка виходу з акаунту
          SizedBox(
            width: double.infinity,
            height: 50,
            child: ElevatedButton.icon(
              onPressed: () async {
                // 1. Очищаємо фейковий токен у пам'яті застосунку
                await AuthService.logout();

                // 2. Безпечно перевіряємо віджет в асинхронному потоці
                if (!mounted) return; 

                // 3. Скидаємо навігацію та повертаємо на екран логіну (EduWay)
                Navigator.pushAndRemoveUntil(
                  context,
                  MaterialPageRoute(builder: (context) => const EduWay()),
                  (route) => false,
                );
              },
              icon: const Icon(Icons.logout_rounded, color: Colors.white),
              label: const Text(
                'Вийти з акаунту',
                style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color.fromARGB(255, 141, 0, 0),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                elevation: 4,
              ),
            ),
          ),
        ],
      ),
    );
  }


  Widget _buildSubjectCard({
    required String title,
    required String questionsCount,
    required IconData icon,
    required Color iconBgColor,
    required Color surfaceColor,
    required Color textColor,
    required Color subtitleColor,
    required VoidCallback onViewTap,
  }) {
    return Container(
      padding: const EdgeInsets.all(16.0),
      decoration: BoxDecoration(
        color: surfaceColor.withValues(alpha: 0.85),
        borderRadius: BorderRadius.circular(16.0),
        border: Border.all(
          color: _isDarkMode ? Colors.white.withValues(alpha: 0.05) : Colors.black.withValues(alpha: 0.05),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                padding: const EdgeInsets.all(10.0),
                decoration: BoxDecoration(
                  color: iconBgColor,
                  borderRadius: BorderRadius.circular(10.0),
                ),
                child: Icon(icon, color: Colors.white, size: 20),
              ),
              IconButton(
                icon: Icon(Icons.more_vert, color: subtitleColor, size: 18),
                onPressed: () {},
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(title, style: GoogleFonts.roboto(color: textColor, fontWeight: FontWeight.bold, fontSize: 15)),
          const SizedBox(height: 2),
          Text(questionsCount, style: GoogleFonts.roboto(color: subtitleColor, fontSize: 12)),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: onViewTap, // ТУТ ВСТАНОВЛЕНО onViewTap
                  icon: const Icon(Icons.play_arrow_rounded, size: 16, color: Colors.white),
                  label: const Text('Почати тест', style: TextStyle(fontSize: 11, color: Colors.white)),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF2563EB),
                    padding: const EdgeInsets.symmetric(vertical: 10),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: onViewTap, // ТУТ ВСТАНОВЛЕНО onViewTap
                  icon: Icon(Icons.article_outlined, size: 16, color: textColor),
                  label: Text('Переглянути', style: TextStyle(fontSize: 11, color: textColor)),
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 10),
                    side: BorderSide(color: subtitleColor.withValues(alpha: 0.3)),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class NavItem extends StatelessWidget {
  final String title;
  final IconData icon;
  final bool isActive;
  final Color textColor;
  final VoidCallback onTap;

  const NavItem({
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