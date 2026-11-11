import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'services/api_service.dart';
import 'services/auth_service.dart';

class TestScreen extends StatefulWidget {
  final List<int> topicIds; 
  final String topicTitle;
  final List<dynamic> dynamicQuestions;
  final String subjectTitle;
  final bool startImmediately; 

  const TestScreen({
    super.key,
    required this.topicIds,
    required List<dynamic> questions,
    required this.topicTitle,
    required this.subjectTitle,
    this.startImmediately = false,
  }) : dynamicQuestions = questions;

  @override
  State<TestScreen> createState() => _TestScreenState();
}

class _TestScreenState extends State<TestScreen> {
  static const int _singleTopicSize = 5; 
  static const int _allQuestions = 50; 

  bool _isTestingMode = false;
  bool _loading = false;

  List<Map<String, dynamic>> _runQuestions = [];
  final List<Map<String, dynamic>> _answers = [];
  final List<int> _ticketIds = [];
  final Set<int> _submittedIds = {};
  int _score = 0;
  int _total = 0;

  int _item = 0;
  int? _selected;

  @override
  void initState() {
    super.initState();
    if (widget.startImmediately) {
      _loading = true;
      WidgetsBinding.instance.addPostFrameCallback((_) => _startTicket());
    }
  }

  int _safeParseInt(dynamic value) {
    if (value is int) return value;
    if (value is String) return int.tryParse(value) ?? 0;
    return 0;
  }

  int _getCorrectIndex(Map q) {
    final raw = q['correctIndex'] ?? q['correct_index'] ?? q['correct'];
    return _safeParseInt(raw);
  }

  List<String> _getOptions(Map q) {
    final rawOpts = q['options'] ?? q['answers'];
    if (rawOpts is List) {
      return rawOpts.map((e) => e.toString()).toList();
    }
    return [];
  }

  String _getQuestionText(Map q) {
    final text = q['question'] ?? q['text'] ?? q['title'];
    return text?.toString() ?? 'Питання без тексту';
  }

  Future<void> _startTicket() async {
    final messenger = ScaffoldMessenger.of(context);
    final navigator = Navigator.of(context);

    final user = AuthService.username;
    if (user == null) {
      messenger.showSnackBar(
          const SnackBar(content: Text('Спочатку увійди в акаунт')));
      if (widget.startImmediately) navigator.pop();
      return;
    }

    setState(() => _loading = true);
    try {
      final count = widget.topicIds.length == 1 ? _singleTopicSize : _allQuestions;
      final ids = <int>[];
      final all = <Map<String, dynamic>>[];

      for (final topicId in widget.topicIds) {
        final data = await ApiService.drawTicket(user, topicId, count);
        final ticketId = data['ticket_id'] as int;
        ids.add(ticketId);

        for (final q in data['questions'] as List) {
          final m = Map<String, dynamic>.from(q as Map);
          m['ticket_id'] = ticketId; 
          all.add(m);
        }
      }

      all.shuffle(); 

      if (!mounted) return;
      setState(() {
        _ticketIds
          ..clear()
          ..addAll(ids);
        _submittedIds.clear();
        _runQuestions = all;
        _answers.clear();
        _score = 0;
        _total = 0;
        _item = 0;
        _selected = null;
        _isTestingMode = true;
        _loading = false;
      });
    } catch (e) {
      debugPrint('Draw ticket error: $e');
      if (!mounted) return;
      setState(() => _loading = false);
      messenger.showSnackBar(
          const SnackBar(content: Text('Не вдалося створити квиток')));
      if (widget.startImmediately) navigator.pop();
    }
  }

  Future<void> _nextQuestion() async {
    final q = _runQuestions[_item];
    
    // Створюємо карту поточної відповіді
    final currentAnswer = {
      'ticket_id': q['ticket_id'],
      'question_id': q['id'],
      'chosen_index': _selected,
    };

    if (_item < _runQuestions.length - 1) {
      setState(() {
        _answers.add(currentAnswer); // Додаємо лише якщо переходимо далі
        _item++;
        _selected = null;
      });
      return;
    }

    // Якщо це останнє питання — проводимо фінальну відправку
    setState(() => _loading = true);
    try {
      // Створюємо повний список відповідей (включаючи поточну останню)
      final allAnswers = List<Map<String, dynamic>>.from(_answers)..add(currentAnswer);

      for (final ticketId in _ticketIds) {
        if (_submittedIds.contains(ticketId)) continue; 
        
        final mine = allAnswers
            .where((a) => a['ticket_id'] == ticketId)
            .map<Map<String, dynamic>>((a) => {
                  'question_id': a['question_id'],
                  'chosen_index': a['chosen_index'],
                })
            .toList();

        final result = await ApiService.submitTicket(
            ticketId, AuthService.username ?? '', mine);
        _submittedIds.add(ticketId);
        _score += result['score'] as int;
        _total += result['total'] as int;
      }
      
      if (!mounted) return;
      setState(() {
        _answers.add(currentAnswer); // Додаємо у глобальний стан лише при успіху
        _loading = false;
      });
      _showResultDialog(_score, _total);
    } catch (e) {
      debugPrint('Submit error: $e');
      if (!mounted) return;
      setState(() => _loading = false);
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
          content: Text('Не вдалося зберегти результат, спробуй ще раз')));
    }
  }

  void _showResultDialog(int score, int total) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF15131F),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text(
          'Тест завершено!',
          style: GoogleFonts.pixelifySans(color: Colors.white, fontSize: 24),
        ),
        content: Text(
          'Твій результат: $score з $total правильних відповідей!',
          style: const TextStyle(color: Colors.white70, fontSize: 16),
        ),
        actions: [
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              Navigator.pop(context);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF2563EB),
            ),
            child: const Text('На головну', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  Future<bool> _confirmExit() async {
    if (!_isTestingMode) return true;

    final shouldLeave = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF15131F),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('Вийти з квитка?', style: TextStyle(color: Colors.white)),
        content: const Text(
          'Ваш поточний прогрес у квитку буде втрачено.',
          style: TextStyle(color: Colors.white70),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Продовжити', style: TextStyle(color: Colors.white70)),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(backgroundColor: Colors.redAccent),
            child: const Text('Вийти', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
    return shouldLeave ?? false;
  }

  Future<void> _exitTicket() async {
    final leave = await _confirmExit();
    if (!leave || !mounted) return;
    setState(() {
      _isTestingMode = false;
      _ticketIds.clear();
      _submittedIds.clear();
      _runQuestions = [];
      _answers.clear();
      _item = 0;
      _selected = null;
    });
    if (widget.startImmediately && mounted) {
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: !_isTestingMode,
      onPopInvokedWithResult: (didPop, result) async {
        if (!didPop && _isTestingMode) {
          await _exitTicket();
        }
      },
      child: Scaffold(
        backgroundColor: const Color(0xFF0E1224),
        appBar: AppBar(
          backgroundColor: const Color(0xFF15131F),
          elevation: 0,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back_ios_new_rounded, color: Colors.white),
            onPressed: () async {
              if (_isTestingMode) {
                await _exitTicket();
              } else {
                Navigator.pop(context);
              }
            },
          ),
          title: Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.white70),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  widget.subjectTitle,
                  style: const TextStyle(color: Colors.white, fontSize: 13),
                ),
              ),
              const SizedBox(width: 10),
              Flexible(
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.white70),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    widget.topicTitle,
                    overflow: TextOverflow.ellipsis,
                    style: GoogleFonts.pixelifySans(color: Colors.white, fontSize: 14),
                  ),
                ),
              ),
],
            ),
          ),
          body: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 1000),
              child: Padding(
                padding: const EdgeInsets.all(20.0),
                child: _isTestingMode
                    ? _buildTestMode()
                    : (widget.startImmediately
                        ? const Center(child: CircularProgressIndicator())
                        : _buildOverviewMode()),
              ),
            ),
          ),
        ),
      );   
  }

  Widget _buildOverviewMode() {
    if (widget.dynamicQuestions.isEmpty) {
      return const Center(
        child: Text(
          'У цій темі поки немає завантажених питань.',
          style: TextStyle(color: Colors.white70, fontSize: 16),
        ),
      );
    }

    final double screenWidth = MediaQuery.of(context).size.width;
    final int crossAxisCount = screenWidth < 700 ? 1 : 2;

    return Stack(
      children: [
        GridView.builder(
          padding: const EdgeInsets.only(bottom: 80.0),
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: crossAxisCount,
            crossAxisSpacing: 16,
            mainAxisSpacing: 16,
            childAspectRatio: crossAxisCount == 1 ? 2.2 : 1.6,
          ),
          itemCount: widget.dynamicQuestions.length,
          itemBuilder: (context, qIndex) {
            final rawQ = widget.dynamicQuestions[qIndex];
            final Map q = (rawQ is Map) ? rawQ : {};

            final String questionText = _getQuestionText(q);
            final List<String> options = _getOptions(q);
            final int rawIdx = _getCorrectIndex(q);

            final int correctIdx = (rawIdx < options.length && rawIdx >= 0) ? rawIdx : 0;
            final String answerText = options.isNotEmpty ? options[correctIdx] : 'Варіанти відсутні';

            return Container(
              padding: const EdgeInsets.all(16.0),
              decoration: BoxDecoration(
                color: const Color(0xFF15131F),
                borderRadius: BorderRadius.circular(16.0),
                border: Border.all(color: Colors.white.withValues(alpha: 0.15)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Питання ${qIndex + 1}',
                    style: const TextStyle(color: Colors.white70, fontSize: 13, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    questionText,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(color: Colors.white, fontSize: 15, fontWeight: FontWeight.bold),
                  ),
                  const Padding(
                    padding: EdgeInsets.symmetric(vertical: 8.0),
                    child: Divider(color: Colors.white24, height: 1),
                  ),
                  Expanded(
                    child: Align(
                      alignment: Alignment.centerLeft,
                      child: Text(
                        'Відповідь: $answerText',
                        style: const TextStyle(color: Colors.greenAccent, fontSize: 14, fontWeight: FontWeight.w600),
                      ),
                    ),
                  ),
                ],
              ),
            );
          },
        ),
        Positioned(
          bottom: 16,
          left: 0,
          right: 0,
          child: Center(
            child: SizedBox(
              width: 180,
              height: 50,
              child: ElevatedButton(
                onPressed: _loading ? null : _startTicket,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF2563EB),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                    side: const BorderSide(color: Colors.white38, width: 1.5),
                  ),
                  elevation: 8,
                ),
                child: _loading
                    ? const SizedBox(
                        width: 22,
                        height: 22,
                        child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                      )
                    : const Text(
                        'START',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 1.2,
                        ),
                      ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildTestMode() {
    if (_runQuestions.isEmpty) {
      return const Center(
        child: Text('Питань немає', style: TextStyle(color: Colors.white)),
      );
    }

    final Map currentQuestion = _runQuestions[_item];

    final int total = _runQuestions.length;
    final double progress = (_item + 1) / total;
    final String questionText = _getQuestionText(currentQuestion);
    final List<String> options = _getOptions(currentQuestion);
    final bool isLast = _item == total - 1;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Питання ${_item + 1} з $total',
          style: const TextStyle(color: Colors.white70, fontSize: 14, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 8),
        ClipRRect(
          borderRadius: BorderRadius.circular(8),
          child: LinearProgressIndicator(
            value: progress,
            minHeight: 8,
            backgroundColor: Colors.white.withValues(alpha: 0.1),
            valueColor: const AlwaysStoppedAnimation<Color>(Color(0xFF2563EB)),
          ),
        ),
        const SizedBox(height: 24),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(24.0),
          decoration: BoxDecoration(
            color: const Color(0xFF15131F),
            borderRadius: BorderRadius.circular(16.0),
            border: Border.all(color: Colors.white.withValues(alpha: 0.08)),
          ),
          child: Text(
            questionText,
            style: GoogleFonts.roboto(color: Colors.white, fontSize: 20, fontWeight: FontWeight.w600),
          ),
        ),
        const SizedBox(height: 20),
        Expanded(
          child: ListView.builder(
            itemCount: options.length,
            itemBuilder: (context, index) {
              final isSelected = _selected == index;

              return Container(
                margin: const EdgeInsets.only(bottom: 12),
                decoration: BoxDecoration(
                  color: isSelected ? const Color(0xFF2563EB).withValues(alpha: 0.2) : const Color(0xFF15131F),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: isSelected ? const Color(0xFF2563EB) : Colors.white.withValues(alpha: 0.1),
                    width: isSelected ? 2 : 1,
                  ),
                ),
                child: ListTile(
                  contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                  leading: CircleAvatar(
                    backgroundColor: isSelected ? const Color(0xFF2563EB) : Colors.white.withValues(alpha: 0.1),
                    child: Text(
                      String.fromCharCode(65 + index),
                      style: TextStyle(
                        color: isSelected ? Colors.white : Colors.white70,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  title: Text(
                    options[index],
                    style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w500),
                  ),
                  onTap: () {
                    setState(() {
                      _selected = index;
                    });
                  },
                ),
              );
            },
          ),
        ),
        Row(
          children: [
            SizedBox(
              height: 52,
              child: OutlinedButton(
                onPressed: _loading ? null : _exitTicket,
                style: OutlinedButton.styleFrom(
                  side: const BorderSide(color: Colors.redAccent),
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
                child: const Text(
                  'Вийти',
                  style: TextStyle(color: Colors.redAccent, fontSize: 16, fontWeight: FontWeight.bold),
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: SizedBox(
                height: 52,
                child: ElevatedButton(
                  onPressed: (_selected != null && !_loading) ? _nextQuestion : null,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF2563EB),
                    disabledBackgroundColor: Colors.white.withValues(alpha: 0.1),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  child: _loading
                      ? const SizedBox(
                          width: 22,
                          height: 22,
                          child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                        )
                      : Text(
                          isLast ? 'Завершити тест' : 'Далі',
                          style: TextStyle(color: _selected != null ? Colors.white : Colors.white38,
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          ),
                          ),
                          ),
                          ),
                          ),
                          ],
                          ),
                          ],
                          );
                          }
                          }