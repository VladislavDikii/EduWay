// ignore_for_file: deprecated_member_use

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../services/api_service.dart';
import '../services/auth_service.dart';
import '../ticket_history_screen.dart';
import '../main.dart';

class ProfilePage extends StatefulWidget {
  final String userName;
  final Color surfaceColor;
  final Color textColor;

  const ProfilePage({
    super.key,
    required this.userName,
    required this.surfaceColor,
    required this.textColor,
  });

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  late Future<List<Map<String, dynamic>>> _ticketsFuture;

  @override
  void initState() {
    super.initState();
    _loadTickets();
  }

  void _loadTickets() {
    final user = widget.userName.isNotEmpty
        ? widget.userName
        : (AuthService.username ?? '');
    _ticketsFuture = ApiService.fetchTicketsHistory(user, limit: 50)
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
    final isDark = widget.textColor.computeLuminance() > 0.5;
    final cardBg = isDark
        ? const Color(0xFF15131F)
        : const Color(0xFFF1F5F9);
    final borderColor = widget.textColor.withValues(alpha: 0.12);
    final greenColor = isDark ? Colors.greenAccent : const Color(0xFF15803D);
    final orangeColor = isDark ? Colors.orangeAccent : const Color(0xFFB45309);

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: widget.surfaceColor.withValues(alpha: 0.85),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Профіль користувача',
            style: GoogleFonts.pixelifySans(
              textStyle: TextStyle(color: widget.textColor, fontSize: 28),
            ),
          ),
          const SizedBox(height: 12),
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
                    style: TextStyle(
                      color: widget.textColor,
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    'Статус: Студент',
                    style: TextStyle(
                      color: widget.textColor.withValues(alpha: 0.5),
                      fontSize: 14,
                    ),
                  ),
                ],
              ),
            ],
          ),
          Divider(height: 36, color: borderColor),
          Text(
            'Тут відображається ваш прогрес.',
            style: TextStyle(
              color: widget.textColor.withValues(alpha: 0.7),
              fontSize: 16,
            ),
          ),
          const SizedBox(height: 16),

          // Блок статистики та історії квитків
          FutureBuilder<List<Map<String, dynamic>>>(
            future: _ticketsFuture,
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Padding(
                  padding: EdgeInsets.symmetric(vertical: 20),
                  child: Center(child: CircularProgressIndicator()),
                );
              }

              final allTickets = snapshot.data ?? [];
              final finishedTickets =
                  allTickets.where((t) => t['finished_at'] != null).toList();

              double avgPercent = 0;
              if (finishedTickets.isNotEmpty) {
                double sumRatio = 0;
                for (final t in finishedTickets) {
                  final score = (t['score'] as num?)?.toDouble() ?? 0;
                  final total = (t['total'] as num?)?.toDouble() ?? 1;
                  if (total > 0) sumRatio += (score / total) * 100;
                }
                avgPercent = sumRatio / finishedTickets.length;
              }

              final lastTicket =
                  allTickets.isNotEmpty ? allTickets.first : null;

              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: _StatBox(
                          label: 'Пройдено квитків',
                          value: '${finishedTickets.length}',
                          textColor: widget.textColor,
                          cardBg: cardBg,
                          borderColor: borderColor,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _StatBox(
                          label: 'Середній бал',
                          value: finishedTickets.isEmpty
                              ? '—'
                              : '${avgPercent.toStringAsFixed(0)}%',
                          textColor: widget.textColor,
                          cardBg: cardBg,
                          borderColor: borderColor,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 14),
                  // Клікабельна картка «Останній квиток» -> відкриває повну історію
                                  // Клікабельна картка «Останній квиток» -> відкриває повну історію
                  InkWell(
                    borderRadius: BorderRadius.circular(14),
                    onTap: () async {
                      await Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => TicketHistoryScreen(
                            username: widget.userName,
                            isDark: isDark,
                          ),
                        ),
                      );

                      if (mounted) {
                        setState(() {
                          _loadTickets();
                        });
                      }
                    },
                    child: Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: cardBg,
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(color: borderColor),
                      ),
                      child: Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(10),
                            decoration: BoxDecoration(
                              color: const Color(0xFF2563EB)
                                  .withValues(alpha: 0.15),
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: const Icon(
                              Icons.history_rounded,
                              color: Color(0xFF2563EB),
                              size: 24,
                            ),
                          ),
                          const SizedBox(width: 14),
                          Expanded(
                            child: lastTicket == null
                                ? Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        'Історія квитків',
                                        style: TextStyle(
                                          color: widget.textColor,
                                          fontSize: 16,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                      const SizedBox(height: 4),
                                      Text(
                                        'Поки немає пройдених тестів',
                                        style: TextStyle(
                                          color: widget.textColor
                                              .withValues(alpha: 0.6),
                                          fontSize: 13,
                                        ),
                                      ),
                                    ],
                                  )
                                : Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Row(
                                        children: [
                                          Expanded(
                                            child: Text(
                                              'Останній квиток: ${lastTicket['topic'] ?? 'Тест'}',
                                              maxLines: 1,
                                              overflow: TextOverflow.ellipsis,
                                              style: TextStyle(
                                                color: widget.textColor,
                                                fontSize: 15,
                                                fontWeight: FontWeight.bold,
                                              ),
                                            ),
                                          ),
                                          const SizedBox(width: 8),
                                          Container(
                                            padding: const EdgeInsets.symmetric(
                                              horizontal: 8,
                                              vertical: 2,
                                            ),
                                            decoration: BoxDecoration(
                                              color: (lastTicket['finished_at'] !=
                                                          null
                                                      ? greenColor
                                                      : orangeColor)
                                                  .withValues(alpha: 0.15),
                                              borderRadius:
                                                  BorderRadius.circular(6),
                                            ),
                                            child: Text(
                                              lastTicket['finished_at'] != null
                                                  ? '${lastTicket['score']}/${lastTicket['total']}'
                                                  : 'У процесі',
                                              style: TextStyle(
                                                color:
                                                    lastTicket['finished_at'] !=
                                                            null
                                                        ? greenColor
                                                        : orangeColor,
                                                fontSize: 12,
                                                fontWeight: FontWeight.bold,
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                      const SizedBox(height: 4),
                                      Text(
                                        '${_formatDate((lastTicket['finished_at'] ?? lastTicket['created_at'])?.toString())} • Час: ${_formatDuration(lastTicket['duration_sec'] as int?)}',
                                        style: TextStyle(
                                          color: widget.textColor
                                              .withValues(alpha: 0.6),
                                          fontSize: 12,
                                        ),
                                      ),
                                    ],
                                  ),
                          ),
                          const SizedBox(width: 8),
                          Icon(
                            Icons.chevron_right_rounded,
                            color: widget.textColor.withValues(alpha: 0.6),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              );
            },
          ),
          const Spacer(),
          SizedBox(
            width: double.infinity,
            height: 50,
            child: ElevatedButton.icon(
              onPressed: () async {
                await AuthService.logout();

                if (!context.mounted) return;

                Navigator.pushAndRemoveUntil(
                  context,
                  MaterialPageRoute(builder: (context) => const EduWay()),
                  (route) => false,
                );
              },
              icon: const Icon(Icons.logout_rounded, color: Colors.white),
              label: const Text(
                'Вийти з акаунту',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
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
}

class _StatBox extends StatelessWidget {
  final String label;
  final String value;
  final Color textColor;
  final Color cardBg;
  final Color borderColor;

  const _StatBox({
    required this.label,
    required this.value,
    required this.textColor,
    required this.cardBg,
    required this.borderColor,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: cardBg,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: borderColor),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: TextStyle(
              color: textColor.withValues(alpha: 0.65),
              fontSize: 12,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: TextStyle(
              color: textColor,
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
}
