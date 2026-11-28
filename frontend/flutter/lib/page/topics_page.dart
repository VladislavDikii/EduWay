import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../test_screen.dart';

class TopicsPage extends StatelessWidget {
  final String selectedSubject;
  final String userName;
  final Color surfaceColor;
  final Color textColor;
  final Color subtitleColor;
  final bool isDarkMode;
  final Future<List<dynamic>> Function(String) fetchTopics;
  final Future<List<dynamic>> Function(int) fetchQuestions;

  const TopicsPage({
    super.key,
    required this.selectedSubject,
    required this.userName,
    required this.surfaceColor,
    required this.textColor,
    required this.subtitleColor,
    required this.isDarkMode,
    required this.fetchTopics,
    required this.fetchQuestions,
  });

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<dynamic>>(
      future: fetchTopics(selectedSubject),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        if (snapshot.hasError) {
          return Center(
            child: Text(
              'Помилка завантаження тем: ${snapshot.error}',
              style: const TextStyle(color: Colors.redAccent),
            ),
          );
        }

        final dbTopics = snapshot.data ?? [];

        return SingleChildScrollView(
          child: Container(
            width: double.infinity,
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: surfaceColor.withValues(alpha: 0.85),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: isDarkMode
                    ? Colors.white.withValues(alpha: 0.05)
                    : Colors.black.withValues(alpha: 0.05),
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  selectedSubject,
                  style: GoogleFonts.pixelifySans(
                    textStyle: TextStyle(
                      color: textColor,
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                    ),
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
                    child: Text(
                      'Теми не знайдені.',
                      style: TextStyle(color: Colors.white70),
                    ),
                  )
                else
                  ListView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: dbTopics.length,
                    itemBuilder: (context, index) {
                      final topicData = dbTopics[index];
                      final int realTopicId = topicData['id'] ?? (index + 1);
                      final int pos = topicData['pos'] ?? (index + 1);

                      final String topicName =
                          topicData['name'] ?? 'Тема $pos';
                      final String formattedTopicTitle =
                          'Тема $pos: $topicName';

                      return Container(
                        margin: const EdgeInsets.only(bottom: 12),
                        decoration: BoxDecoration(
                          color: isDarkMode
                              ? Colors.white.withValues(alpha: 0.05)
                              : Colors.black.withValues(alpha: 0.03),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: isDarkMode
                                ? Colors.white.withValues(alpha: 0.1)
                                : Colors.black.withValues(alpha: 0.1),
                          ),
                        ),
                        child: ListTile(
                          leading: CircleAvatar(
                            backgroundColor: const Color(0xFF2563EB),
                            child: Text(
                              '$pos',
                              style: const TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                          title: Text(
                            formattedTopicTitle,
                            style: TextStyle(
                              color: textColor,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          //  Додати відображення кількості питань (topicData['questions'])
                          trailing: Icon(
                            Icons.arrow_forward_ios_rounded,
                            color: subtitleColor,
                            size: 16,
                          ),
                          onTap: () async {
                            final questions = await fetchQuestions(realTopicId);

                            if (!context.mounted) return;

                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => TestScreen(
                                  topicIds: [realTopicId], // Передаємо список ID
                                  topicTitle: topicName,
                                  subjectTitle: selectedSubject, // Зверніть увагу: selectedSubject без підкреслення
                                  questions: questions,
                                ),
                              ),
                            );
                          },
                        ),
                      );
                    },
                  ),

                // Кнопка запуску всіх тем разом (з коду колеги)
                if (dbTopics.isNotEmpty) ...[
                  const SizedBox(height: 16),
                  SizedBox(
                    width: double.infinity,
                    height: 50,
                    child: ElevatedButton.icon(
                      onPressed: () {
                        Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (context) => TestScreen(
                              topicIds: dbTopics.map<int>((t) => t['id'] as int).toList(),
                              topicTitle: 'Усі теми',
                              subjectTitle: selectedSubject,
                              questions: const [],
                              startImmediately: true,
                            ),
                          ),
                        );
                      },
                      icon: const Icon(Icons.play_arrow_rounded, color: Colors.white),
                      label: const Text(
                        'START (Пройти всі теми)',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 1.1,
                        ),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF2563EB),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ),
        );
      },
    );
  }
}