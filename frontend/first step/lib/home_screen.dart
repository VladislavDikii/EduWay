import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:particles_fly/particles_fly.dart';
import 'package:google_fonts/google_fonts.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  // Налаштування теми та активного пункту меню
  bool _isDarkMode = true;
  int _selectedIndex = 0;

   // Оголошуємо змінну та список цитат відомих науковців про навчання
  late Map<String, String> _currentQuote;

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
    super.initState();
    // Перемішуємо список і беремо першу цитату при кожному оновленні сторінки
    _educationQuotes.shuffle();
    _currentQuote = _educationQuotes.first;
  }

  @override
  Widget build(BuildContext context) {
    final double screenWidth = MediaQuery.of(context).size.width;
    final double screenHeight = MediaQuery.of(context).size.height;

    // Палітра кольорів
    final backgroundColor = _isDarkMode ? const Color(0xFF111622) : const Color(0xFFF4F6F9);
    final surfaceColor = _isDarkMode ? const Color(0xFF1D2433) : Colors.white;
    final textColor = _isDarkMode ? Colors.white : const Color(0xFF1C1E22);
    final subtitleColor = _isDarkMode ? const Color(0xFF8A94A6) : const Color(0xFF6B7280);
    final iconColor = _isDarkMode ? Colors.white : const Color(0xFF1C1E22);
    const primaryBlue = Color(0xFF2563EB);

    return AnimatedContainer(
      duration: const Duration(milliseconds: 400),
      color: backgroundColor,
      child: Scaffold(
        backgroundColor: Colors.transparent,
        body: Stack(
          children: [
            // 1. Анімований фон з регульованим легким розмиттям (3.0)
            ParticlesFly(
              key: ValueKey(_isDarkMode),
              height: screenHeight,
              width: screenWidth,
              connectDots: true,
              numberOfParticles: 35,
              particleColor: _isDarkMode 
                  ? Colors.white.withValues(alpha: 0.3) 
                  : Colors.black.withValues(alpha: 0.2),
              maxParticleSize: 2,
              speedOfParticles: 0.8,
              lineColor: _isDarkMode 
                  ? Colors.white.withValues(alpha: 0.1) 
                  : Colors.black.withValues(alpha: 0.08),
            ),

            Positioned.fill(
              child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 3.0, sigmaY: 3.0),
                child: Container(color: Colors.transparent),
              ),
            ),

            // 2. Основна верстка
            SafeArea(
              child: Column(
                children: [
                  // --- ВЕРХНЯ ПАНЕЛЬ (ПРЯМОКУТНИК) ---
                  AnimatedContainer(
                    duration: const Duration(milliseconds: 400),
                    margin: const EdgeInsets.only(left: 16.0, right: 16.0, top: 16.0, bottom: 8.0),
                    padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 12.0),
                    decoration: BoxDecoration(
                      color: surfaceColor.withValues(alpha: 0.85),
                      borderRadius: BorderRadius.circular(16.0),
                      border: Border.all(
                        color: _isDarkMode 
                            ? Colors.white.withValues(alpha: 0.05) 
                            : Colors.black.withValues(alpha: 0.05),
                      ),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        // Логотип EduWay
                        Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(8.0),
                              decoration: BoxDecoration(
                                color: primaryBlue,
                                borderRadius: BorderRadius.circular(8.0),
                              ),
                              child: const Icon(Icons.school, color: Colors.white, size: 24),
                            ),
                            const SizedBox(width: 12),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'EduWay',
                                  style: GoogleFonts.roboto(
                                    color: textColor,
                                    fontSize: 22,
                                    fontWeight: FontWeight.bold,
                                    letterSpacing: 0.5,
                                  ),
                                ),
                                Text(
                                  'Шлях до освіти',
                                  style: GoogleFonts.roboto(
                                    color: subtitleColor,
                                    fontSize: 12,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                        // Кнопки налаштувань теми та профілю
                        Row(
                          children: [
                            IconButton(
                              icon: AnimatedSwitcher(
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
                            const SizedBox(width: 12),
                            Icon(Icons.account_circle_outlined, color: iconColor, size: 28),
                          ],
                        ),
                      ],
                    ),
                  ),

                  // --- НИЖНЯ ЧАСТИНА: САЙДБАР ТА ОБЛАСТЬ КОНТЕНТУ ---
                  Expanded(
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Ліве бічне меню (Сайдбар)
                        AnimatedContainer(
                          duration: const Duration(milliseconds: 400),
                          width: 240,
                          margin: const EdgeInsets.only(left: 16.0, bottom: 16.0, top: 8.0),
                          padding: const EdgeInsets.symmetric(vertical: 16.0, horizontal: 8.0),
                          decoration: BoxDecoration(
                            color: surfaceColor.withValues(alpha: 0.85),
                            borderRadius: BorderRadius.circular(16.0),
                            border: Border.all(
                              color: _isDarkMode 
                                  ? Colors.white.withValues(alpha: 0.05) 
                                  : Colors.black.withValues(alpha: 0.05),
                            ),
                          ),
                          child: Column(
                            children: [
                              _buildMenuItem(0, Icons.home_rounded, 'Головна', textColor, primaryBlue),
                              _buildMenuItem(1, Icons.auto_stories_rounded, 'Мої предмети', textColor, primaryBlue),
                              _buildMenuItem(2, Icons.history_rounded, 'Історія квитків', textColor, primaryBlue),
                              _buildMenuItem(3, Icons.settings_rounded, 'Налаштування', textColor, primaryBlue),
                            ],
                          ),
                        ),

                        // Повністю чиста права робоча область
                      // Нова права робоча область, розділена на дві великі колонки
                        Expanded(
                          child: Padding(
                            padding: const EdgeInsets.only(left: 16.0, right: 16.0, bottom: 16.0, top: 8.0),
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.stretch,
                              children: [
                                // === 1. ВЕЛИКА ЛІВА КОЛОНКА (Банер, Предмети) ===
                                Expanded(
                                  flex: 2, // Займає 2/3 ширини
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      AnimatedContainer(
                                        duration: const Duration(milliseconds: 400),
                                        width: double.infinity,
                                        padding: const EdgeInsets.all(24.0),
                                        decoration: BoxDecoration(
                                          color: primaryBlue,
                                          borderRadius: BorderRadius.circular(16.0),
                                        ),
                                        child: Text(
                                          'Місце під банер "Ласкаво просимо" та картки предметів',
                                          style: GoogleFonts.roboto(color: Colors.white, fontSize: 16),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),

                                const SizedBox(width: 16),

                                // === 2. ВУЖЧА ПРАВА КОЛОНКА (Статистика та Цитата знизу) ===
                                Expanded(
                                  flex: 1, // Займає 1/3 ширини, як на референсі
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween, // Розштовхує блоки вгору та вниз
                                    children: [
                                      // Верхня частина правої колонки (для блоків статистики)
                                      Column(
                                        children: [
                                          AnimatedContainer(
                                            duration: const Duration(milliseconds: 400),
                                            width: double.infinity,
                                            padding: const EdgeInsets.all(20.0),
                                            decoration: BoxDecoration(
                                              color: surfaceColor.withValues(alpha: 0.85),
                                              borderRadius: BorderRadius.circular(16.0),
                                              border: Border.all(
                                                color: _isDarkMode 
                                                    ? Colors.white.withValues(alpha: 0.05) 
                                                    : Colors.black.withValues(alpha: 0.05),
                                              ),
                                            ),
                                            child: Text(
                                              'Місце під блоки "Останній квиток" та "Твоя статистика"',
                                              style: TextStyle(color: textColor),
                                            ),
                                          ),
                                        ],
                                      ),

                                      // --- ОКРЕМІЙ КОНТЕЙНЕР З ЦИТАТОЮ (СТРОГО СПРАВА ЗНИЗУ) ---
                                      // --- ОКРЕМІЙ КОНТЕЙНЕР З ЦИТАТОЮ (ЗМІНЮЄТЬСЯ ПРИ НАТИСКАННІ) ---
                                      InkWell(
                                        onTap: () {
                                          setState(() {
                                            // Перемішуємо список цитат знову
                                            _educationQuotes.shuffle();
                                            // Беремо нову першу цитату
                                            _currentQuote = _educationQuotes.first;
                                          });
                                        },
                                        borderRadius: BorderRadius.circular(16.0), // Закруглення для ефекту хвилі
                                        child: AnimatedContainer(
                                          duration: const Duration(milliseconds: 400),
                                          width: double.infinity,
                                          padding: const EdgeInsets.all(20.0),
                                          decoration: BoxDecoration(
                                            color: surfaceColor.withValues(alpha: 0.85),
                                            borderRadius: BorderRadius.circular(16.0),
                                            border: Border.all(
                                              color: _isDarkMode 
                                                  ? Colors.white.withValues(alpha: 0.05) 
                                                  : Colors.black.withValues(alpha: 0.05),
                                            ),
                                          ),
                                          child: Column(
                                            crossAxisAlignment: CrossAxisAlignment.start,
                                            children: [
                                              Text(
                                                '“',
                                                style: TextStyle(
                                                  color: primaryBlue.withValues(alpha: 0.6),
                                                  fontSize: 48,
                                                  height: 0.5,
                                                  fontFamily: 'serif',
                                                ),
                                              ),
                                              Text(
                                                _currentQuote['text']!,
                                                style: GoogleFonts.roboto(
                                                  color: textColor,
                                                  fontSize: 14,
                                                  fontStyle: FontStyle.italic,
                                                  height: 1.4,
                                                ),
                                              ),
                                              const SizedBox(height: 12),
                                              Row(
                                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                                children: [
                                                  Text(
                                                    _currentQuote['author']!,
                                                    style: GoogleFonts.roboto(
                                                      color: subtitleColor,
                                                      fontSize: 12,
                                                      fontWeight: FontWeight.w500,
                                                    ),
                                                  ),
                                                  Icon(
                                                    Icons.terrain_rounded,
                                                    color: primaryBlue.withValues(alpha: 0.3),
                                                    size: 24,
                                                  ),
                                                ],
                                              ),
                                            ],
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),

                      ],
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

  // Окремий чистий метод для кнопок меню
  Widget _buildMenuItem(int index, IconData icon, String title, Color defaultTextColor, Color activeColor) {
    final isSelected = _selectedIndex == index;
    
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: InkWell(
        onTap: () => setState(() => _selectedIndex = index),
        borderRadius: BorderRadius.circular(12.0),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 250),
          width: double.infinity,
          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
          decoration: BoxDecoration(
            color: isSelected ? activeColor : Colors.transparent,
            borderRadius: BorderRadius.circular(12.0),
          ),
          child: Row(
            children: [
              Icon(
                icon,
                color: isSelected ? Colors.white : defaultTextColor.withValues(alpha: 0.7),
                size: 20,
              ),
              const SizedBox(width: 16),
              Text(
                title,
                style: GoogleFonts.roboto(
                  color: isSelected ? Colors.white : defaultTextColor,
                  fontSize: 15,
                  fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                    ),
                  ),
               ],
            ),
          ),
        ),
      );
    }
  }