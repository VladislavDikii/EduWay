import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter/cupertino.dart';

void main() {
  runApp(const EduWay());
}

class EduWay extends StatefulWidget {
  const EduWay({super.key});

  @override
  State<EduWay> createState() => _EduWayState();
}

class _EduWayState extends State<EduWay> {
  String _selectedTab = 'Topics';
  bool isTilted = false;
  int? selectedTopicIndex; // Змінна для вибору картки теми

  void changeTab(String newTab) {
    setState(() {
      _selectedTab = newTab;
    });
  }

  @override
  Widget build(BuildContext context) {
    final bool isTopicsActive = _selectedTab == 'Topics';
    final bool isHomeActive = _selectedTab == 'Home';
    final bool isYouActive = _selectedTab == 'You';

    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: Scaffold(
        backgroundColor: const Color.fromARGB(255, 14, 18, 36),
        body: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
            child: SingleChildScrollView(
              child: Column(
                children: [

                  // 1. ШАПКА САЙТУ (HEADER)
                  
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                    decoration: BoxDecoration(
                      color: const Color.fromARGB(255, 15, 13, 31),
                      borderRadius: BorderRadius.circular(12),
                      border: const Border(
                        bottom: BorderSide(
                          color: Color.fromARGB(255, 68, 73, 99),
                          width: 1.5,
                        ),
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: const Color.fromARGB(255, 61, 60, 60).withValues(alpha: 0.2),
                          blurRadius: 12,
                          spreadRadius: 1,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'EduWay',
                          style: GoogleFonts.pixelifySans(
                            textStyle: const TextStyle(
                              color: Colors.white,
                              fontSize: 32,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        Row(
                          children: [
                            NavItem(
                              title: 'Home',
                              icon: CupertinoIcons.home,
                              isActive: isHomeActive,
                              onTap: () => changeTab('Home'),
                            ),
                            const SizedBox(width: 16),
                            NavItem(
                              title: 'Topics',
                              icon: CupertinoIcons.doc_on_doc,
                              isActive: isTopicsActive,
                              onTap: () => changeTab('Topics'),
                            ),
                            const SizedBox(width: 16),
                            NavItem(
                              title: 'You',
                              icon: CupertinoIcons.person,
                              isActive: isYouActive,
                              onTap: () => changeTab('You'),
                            ),
                          ],
                        ),
                        IconButton(
                          onPressed: () {},
                          icon: const Icon(CupertinoIcons.search, color: Colors.white),
                        ),
                      ],
                    ),
                  ),
                  
                  const SizedBox(height: 20),

                  // 2. БЛОК З КАРТКОЮ ТА ОПИСОМ
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            'Фізика',
                            style: GoogleFonts.pixelifySans(
                              textStyle: const TextStyle(
                                color: Colors.white,
                                fontSize: 30,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                          const SizedBox(height: 16),
                          GestureDetector(
                            onTap: () {
                              setState(() {
                                isTilted = !isTilted;
                              });
                            },
                            child: SizedBox(
                              width: 220,
                              height: 160,
                              child: Padding(
                                padding: const EdgeInsets.all(16.0),
                                child: TweenAnimationBuilder<double>(
                                  tween: Tween<double>(begin: 0, end: isTilted ? 3.14159 : 0),
                                  duration: const Duration(milliseconds: 600),
                                  curve: Curves.easeInOut,
                                  builder: (context, angle, child) {
                                    return Transform(
                                      transform: Matrix4.identity()
                                        ..setEntry(3, 2, 0.001)
                                        ..rotateY(angle),
                                      alignment: Alignment.center,
                                      child: Image.asset(
                                      'assets/image/10.png',
                                      fit: BoxFit.contain,

                                      ),
                                    );
                                  },
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(width: 30),
                      const Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Шкільна програма',
                              style: TextStyle(
                                color: Colors.grey,
                                fontSize: 12.0,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            SizedBox(height: 8),
                            Text(
                              'Ядерна фізика',
                              style: TextStyle(
                                fontSize: 24.0,
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ), 

                  const SizedBox(height: 30),

                  // 3. СІРИЙ КОНТЕЙНЕР З КАРТКАМИ ТЕМ (ВАШ БЛОК)
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 16),
                    decoration: BoxDecoration(
                      color: const Color.fromARGB(255, 24, 30, 58),
                      borderRadius: BorderRadius.circular(24),
                    ),
                    child: Stack(
                      alignment: Alignment.centerLeft,
                      children: [
                        // ГОРИЗОНТАЛЬНА ЛІНІЯ-З'ЄДНУВАЧ
                        Positioned(
                          top: 60,
                          left: 20,
                          right: 20,
                          child: Container(
                            height: 2,
                            color: Colors.white.withValues(alpha: 0.15),
                          ),
                        ),

                        // ВАШ ГОРИЗОНТАЛЬНИЙ СПИСОК КАРТОК
                        SingleChildScrollView(
                          scrollDirection: Axis.horizontal,
                          child: Row(
                            children: [
                              BrilliantTopicCard(
                                isNew: true,
                                title: 'Тема 1',
                                icon: CupertinoIcons.chart_pie_fill,
                                isSelected: selectedTopicIndex == 0,
                                onTap: () {
                                  setState(() {
                                    selectedTopicIndex = selectedTopicIndex == 0 ? null : 0;
                                  });
                                },
                              ),
                              const SizedBox(width: 20),
                              BrilliantTopicCard(
                                isNew: false,
                                title: 'Тема 2',
                                icon: Icons.balance,
                                isSelected: selectedTopicIndex == 1,
                                onTap: () {
                                  setState(() {
                                    selectedTopicIndex = selectedTopicIndex == 1 ? null : 1;
                                  });
                                },
                              ),
                              const SizedBox(width: 20),
                              BrilliantTopicCard(
                                isNew: false,
                                title: 'Тема 3',
                                icon: CupertinoIcons.plus_slash_minus,
                                isSelected: selectedTopicIndex == 2,
                                onTap: () {
                                  setState(() {
                                    selectedTopicIndex = selectedTopicIndex == 2 ? null : 2;
                                  });
                                },
                              ),
                              const SizedBox(width: 20),
                              BrilliantTopicCard(
                                isNew: false,
                                title: 'Тема 4',
                                icon: CupertinoIcons.graph_square,
                                isSelected: selectedTopicIndex == 3,
                                onTap: () {
                                  setState(() {
                                    selectedTopicIndex = selectedTopicIndex == 3 ? null : 3;
                                  });
                                },
                              ),
                              const SizedBox(width: 20),
                              BrilliantTopicCard(
                                isNew: false,
                                title: 'Тема 5',
                                icon: CupertinoIcons.percent,
                                isSelected: selectedTopicIndex == 4,
                                onTap: () {
                                  setState(() {
                                    selectedTopicIndex = selectedTopicIndex == 4 ? null : 4;
                                  });
                                },
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 20),

                  // 4. ВИПАДАЮЧИЙ БЛОК ПИТАНЬ/ВІДПОВІДЕЙ
                  if (selectedTopicIndex != null)
                    AnimatedContainer(
                      duration: const Duration(milliseconds: 300),
                      width: double.infinity,
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: const Color.fromARGB(255, 24, 30, 58),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(color: Colors.cyanAccent.withValues(alpha: 0.6), width: 1.5),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Питання та відповіді до теми #${selectedTopicIndex! + 1}',
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 12),
                          const Text(
                            '• Питання 1: Які основні поняття вивчаються в цьому розділі?\n• Питання 2: Які формули необхідно застосувати для розв\'язку задач?',
                            style: TextStyle(color: Colors.grey, height: 1.6),
                          ),
                        ],
                      ),
                    ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

// КАРТКА В СТИЛІ BRILLIANT
class BrilliantTopicCard extends StatelessWidget {
  final String? grade;
  final bool isNew;
  final String title;
  final IconData icon;
  final bool isSelected;
  final VoidCallback onTap;

  const BrilliantTopicCard({
    super.key,
    this.grade,
    required this.isNew,
    required this.title,
    required this.icon,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            width: 120,
            height: 120,
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: isSelected ? Colors.cyanAccent : Colors.transparent,
                width: 3,
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.15),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      grade ?? '',
                      style: const TextStyle(
                        color: Colors.grey,
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    if (isNew)
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 2),
                        decoration: BoxDecoration(
                          color: Colors.green,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: const Text(
                          'NEW',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 8,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                  ],
                ),
                const Spacer(),
                Center(
                  child: Icon(
                    icon,
                    size: 46,
                    color: const Color.fromARGB(255, 43, 92, 230),
                  ),
                ),
                const Spacer(),
              ],
            ),
          ),
          const SizedBox(height: 12),
          SizedBox(
            width: 120,
            child: Text(
              title,
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 13,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// Окремий віджет для пунктів меню
class NavItem extends StatelessWidget {
  final String title;
  final IconData icon;
  final bool isActive;
  final VoidCallback onTap;

  const NavItem({
    super.key,
    required this.title,
    required this.icon,
    required this.isActive,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return TextButton.icon(
      onPressed: onTap,
      icon: Icon(
        icon,
        color: isActive ? Colors.white : Colors.grey,
        size: 20,
      ),
      label: Container(
        padding: const EdgeInsets.only(bottom: 4),
        decoration: BoxDecoration(
          border: isActive
              ? const Border(
                  bottom: BorderSide(color: Colors.white, width: 2),
                )
              : null,
        ),
        child: Text(
          title,
          style: TextStyle(
            color: isActive ? Colors.white : Colors.grey,
            fontWeight: isActive ? FontWeight.bold : FontWeight.normal,
          ),
        ),
      ),
    );
  }
}