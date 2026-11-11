import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../services/api_service.dart';

class HomePage extends StatefulWidget {
  final String userName;
  final Color surfaceColor;
  final Color textColor;
  final Color subtitleColor;
  final Color primaryBlue;
  final Map<String, String> currentQuote;
  final Function(String) onSubjectTap;
  final VoidCallback onQuoteTap;

  const HomePage({
    super.key,
    required this.userName,
    required this.surfaceColor,
    required this.textColor,
    required this.subtitleColor,
    required this.primaryBlue,
    required this.currentQuote,
    required this.onSubjectTap,
    required this.onQuoteTap,
  });

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  late Future<List<dynamic>> _subjectsFuture;

  @override
  void initState() {
    super.initState();
    _subjectsFuture = ApiService.fetchSubjects();
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
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
                    gradient: const LinearGradient(
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
                          color: widget.primaryBlue.withValues(alpha: 0.3),
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
                              'EduWay допоможе тобі підготуватися до екзаменів і впевнено скласти їх.',
                              style: GoogleFonts.roboto(color: Colors.white70, fontSize: 13),
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
                              color: widget.textColor,
                              fontSize: 22,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          'Обирай предмет, щоб почати підготовку',
                          style: GoogleFonts.roboto(color: widget.subtitleColor, fontSize: 12),
                        ),
                      ],
                    ),
                    ElevatedButton.icon(
                      onPressed: () {},
                      icon: const Icon(Icons.add, size: 18, color: Colors.white),
                      label: const Text('Додати предмет', style: TextStyle(color: Colors.white)),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: widget.primaryBlue,
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                FutureBuilder<List<dynamic>>(
                  future: _subjectsFuture,
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      // ВИПРАВЛЕНО: Замість Center(padding: ...) використано Padding(child: Center(...))
                      return const Padding(
                        padding: EdgeInsets.symmetric(vertical: 20),
                        child: Center(child: CircularProgressIndicator()),
                      );
                    }

                    final subjects = snapshot.data ?? [];

                    if (subjects.isEmpty) {
                      return const Text('Предмети відсутні', style: TextStyle(color: Colors.white54));
                    }

                    return GridView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 2,
                        crossAxisSpacing: 12,
                        mainAxisSpacing: 12,
                        childAspectRatio: 1.4,
                      ),
                      itemCount: subjects.length,
                      itemBuilder: (context, index) {
                        final subject = subjects[index];
                        final String title = subject['name'] ?? 'Предмет';
                        final int questionsCount = subject['questions'] ?? 0;

                        final Color iconBg = index % 2 == 0 
                            ? widget.primaryBlue 
                            : const Color(0xFF7C3AED);

                        return _buildSubjectCard(
                          title: title,
                          questionsCount: '$questionsCount питань',
                          icon: index % 2 == 0 
                              ? Icons.calculate_outlined 
                              : Icons.account_balance_outlined,
                          iconBgColor: iconBg,
                          onViewTap: () => widget.onSubjectTap(title),
                        );
                      },
                    );
                  },
                ),
              ],
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            flex: 1,
            child: Column(
              children: [
                Container(
                  padding: const EdgeInsets.all(16.0),
                  decoration: BoxDecoration(
                    color: widget.surfaceColor.withValues(alpha: 0.85),
                    borderRadius: BorderRadius.circular(16.0),
                    border: Border.all(color: widget.textColor.withValues(alpha: 0.05)),
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
                              Text('Останній квиток', style: TextStyle(color: widget.textColor, fontWeight: FontWeight.bold, fontSize: 13)),
                            ],
                          ),
                          Icon(Icons.chevron_right, color: widget.subtitleColor, size: 18),
                        ],
                      ),
                      const SizedBox(height: 12),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text('22 жовт. 2026 • 14:32', style: TextStyle(color: widget.subtitleColor, fontSize: 11)),
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
                InkWell(
                  onTap: widget.onQuoteTap,
                  borderRadius: BorderRadius.circular(16.0),
                  child: Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(16.0),
                    decoration: BoxDecoration(
                      color: widget.surfaceColor.withValues(alpha: 0.85),
                      borderRadius: BorderRadius.circular(16.0),
                      border: Border.all(color: widget.textColor.withValues(alpha: 0.05)),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('“', style: TextStyle(color: Colors.blue, fontSize: 36, height: 0.8, fontFamily: 'serif')),
                        Text(widget.currentQuote['text']!, style: TextStyle(color: widget.textColor, fontSize: 12, fontStyle: FontStyle.italic)),
                        const SizedBox(height: 8),
                        Text(widget.currentQuote['author']!, style: TextStyle(color: widget.subtitleColor, fontSize: 11)),
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

  Widget _buildSubjectCard({
    required String title,
    required String questionsCount,
    required IconData icon,
    required Color iconBgColor,
    required VoidCallback onViewTap,
  }) {
    return Container(
      padding: const EdgeInsets.all(16.0),
      decoration: BoxDecoration(
        color: widget.surfaceColor.withValues(alpha: 0.85),
        borderRadius: BorderRadius.circular(16.0),
        border: Border.all(color: widget.textColor.withValues(alpha: 0.05)),
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
                icon: Icon(Icons.more_vert, color: widget.subtitleColor, size: 18),
                onPressed: () {},
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(title, style: GoogleFonts.roboto(color: widget.textColor, fontWeight: FontWeight.bold, fontSize: 15)),
          const SizedBox(height: 2),
          Text(questionsCount, style: GoogleFonts.roboto(color: widget.subtitleColor, fontSize: 12)),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: onViewTap,
                  icon: const Icon(Icons.play_arrow_rounded, size: 16, color: Colors.white),
                  label: const Text('Почати тест', style: TextStyle(fontSize: 11, color: Colors.white)),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: widget.primaryBlue,
                    padding: const EdgeInsets.symmetric(vertical: 10),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: onViewTap,
                  icon: Icon(Icons.article_outlined, size: 16, color: widget.textColor),
                  label: Text('Переглянути', style: TextStyle(fontSize: 11, color: widget.textColor)),
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 10),
                    side: BorderSide(color: widget.subtitleColor.withValues(alpha: 0.3)),
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