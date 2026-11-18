// ignore: deprecated_member_use
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'services/api_service.dart';
import 'services/auth_service.dart';

class TicketHistoryScreen extends StatefulWidget {
  final String? username;
  final bool isDark;

  const TicketHistoryScreen({
    super.key,
    this.username,
    this.isDark = true,
  });

  @override
  State<TicketHistoryScreen> createState() => _TicketHistoryScreenState();
}

class _TicketHistoryScreenState extends State<TicketHistoryScreen> {
  late Future<List<Map<String, dynamic>>> _historyFuture;

  @override
  void initState() {
    super.initState();
    final user = widget.username ?? AuthService.username ?? '';
    _historyFuture = ApiService.fetchTicketsHistory(user, limit: 50)
        .then((list) => list.cast<Map<String, dynamic>>());
  }

  String _formatDate(String? iso) {
    if (iso == null) return 'Невідомо';
    final dt = DateTime.tryParse(iso)?.toLocal();
    if (dt == null) return iso;
    final d = dt.day.toString().padLeft(2, '0');
    final m = dt.month.toString().padLeft(2, '0');
    final y = dt.year;
    final hh = dt.hour.toString().padLeft(2, '0');
    final mm = dt.minute.toString().padLeft(2, '0');
    return '$d.$m.$y • $hh:$mm';
  }

  String _formatDuration(int? seconds) {
    if (seconds == null) return '--:--';
    final mins = (seconds ~/ 60).toString().padLeft(2, '0');
    final secs = (seconds % 60).toString().padLeft(2, '0');
    return '$mins:$secs';
  }

  @override
  Widget build(BuildContext context) {
    final isDark = widget.isDark;
    final bgColor = isDark ? const Color(0xFF0E1224) : const Color(0xFFF4F6FA);
    final cardColor = isDark ? const Color(0xFF15131F) : Colors.white;
    final textColor = isDark ? Colors.white : const Color(0xFF0F172A);
    final subTextColor = isDark ? Colors.white70 : const Color(0xFF475569);
    final iconColor = isDark ? Colors.white54 : const Color(0xFF64748B);
    final greenColor = isDark ? Colors.greenAccent : const Color(0xFF15803D);
    final orangeColor = isDark ? Colors.orangeAccent : const Color(0xFFB45309);

    return Scaffold(
      backgroundColor: bgColor,
      appBar: AppBar(
        backgroundColor: cardColor,
        elevation: isDark ? 0 : 1,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios_new_rounded, color: textColor),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'Історія квитків',
          style: GoogleFonts.pixelifySans(color: textColor, fontSize: 20),
        ),
      ),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 900),
          child: FutureBuilder<List<Map<String, dynamic>>>(
            future: _historyFuture,
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              }
              if (snapshot.hasError) {
                return const Center(
                  child: Text(
                    'Помилка завантаження історії',
                    style: TextStyle(color: Colors.redAccent, fontSize: 16),
                  ),
                );
              }

              final tickets = snapshot.data ?? [];
              if (tickets.isEmpty) {
                return Center(
                  child: Text(
                    'Ви ще не проходили жодного квитка.',
                    style: TextStyle(color: subTextColor, fontSize: 16),
                  ),
                );
              }

              return ListView.separated(
                padding: const EdgeInsets.all(20),
                itemCount: tickets.length,
                separatorBuilder: (_, __) => const SizedBox(height: 12),
                itemBuilder: (context, index) {
                  final t = tickets[index];
                  final isFinished = t['finished_at'] != null;
                  final score = t['score'] ?? 0;
                  final total = t['total'] ?? 0;
                  final duration = t['duration_sec'] as int?;
                  final subject = t['subject']?.toString() ?? 'Предмет';
                  final topic = t['topic']?.toString() ?? 'Тема';
                  final dateStr = _formatDate(
                    (t['finished_at'] ?? t['created_at'])?.toString(),
                  );

                  return Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: cardColor,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: textColor.withValues(alpha: 0.1),
                      ),
                      boxShadow: isDark
                          ? null
                          : [
                              BoxShadow(
                                color: Colors.black.withValues(alpha: 0.04),
                                blurRadius: 8,
                                offset: const Offset(0, 2),
                              ),
                            ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Expanded(
                              child: Text(
                                '$subject • $topic',
                                style: TextStyle(
                                  color: textColor,
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 10,
                                vertical: 4,
                              ),
                              decoration: BoxDecoration(
                                color: (isFinished ? greenColor : orangeColor)
                                    .withValues(alpha: 0.15),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Text(
                                isFinished ? 'Завершено' : 'Не завершено',
                                style: TextStyle(
                                  color: isFinished ? greenColor : orangeColor,
                                  fontSize: 12,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 10),
                        Row(
                          children: [
                            Icon(Icons.calendar_today_outlined,
                                color: iconColor, size: 15),
                            const SizedBox(width: 6),
                            Text(
                              dateStr,
                              style:
                                  TextStyle(color: subTextColor, fontSize: 13),
                            ),
                            const Spacer(),
                            if (isFinished) ...[
                              Icon(Icons.timer_outlined,
                                  color: iconColor, size: 15),
                              const SizedBox(width: 4),
                              Text(
                                _formatDuration(duration),
                                style: TextStyle(
                                    color: subTextColor, fontSize: 13),
                              ),
                              const SizedBox(width: 14),
                              Text(
                                'Бали: $score / $total',
                                style: TextStyle(
                                  color: greenColor,
                                  fontSize: 14,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ],
                        ),
                      ],
                    ),
                  );
                },
              );
            },
          ),
        ),
      ),
    );
  }
}
