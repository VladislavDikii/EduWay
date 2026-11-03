import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class TestScreen extends StatefulWidget {
  final String topicTitle; //зберігається назва обраної теми
  final List dynamicQuestions; //передаєм список запитань
  final String subjectTitle;

  const TestScreen({
    super.key,
    required List questions,
    required this.topicTitle, //змінна є обов'язкова при виклику екрану
    required this.subjectTitle,
  }) : dynamicQuestions = questions;

  @override
  State<TestScreen> createState() => _TestScreenState(); //метод який відповідає за логіку інтерфейсу
}

class _TestScreenState extends State<TestScreen> {
  // false = режим перегляду запитань (за замовчуванням)
  // true = режим проходження тесту
  bool _isTestingMode = false;

  int _item = 0; //кількість питань
  int? _selected; //зберігає індекс відповіді
  int _score = 0; //кількість правильних

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

  void _nextQuestion() {
    if (_item < widget.dynamicQuestions.length) {
      final rawQ = widget.dynamicQuestions[_item];
      if (rawQ is Map) {
        final int correctIdx = _getCorrectIndex(rawQ);
        if (_selected == correctIdx) {
          _score++;
        }
      }
    }

    if (_item < widget.dynamicQuestions.length - 1) {
      setState(() {
        _item++;
        _selected = null;
      });
    } else {
      _showResultDialog();
    }
  }

//відображення спливаючого вікна результатів
  void _showResultDialog() {
    //віджет що спливає поверх інших
    showDialog(
      context: context,
      barrierDismissible: false, //заборона закривати вікно поза ним( користувач повинен натиснути кнопку «На головну»)
      builder: (context) => AlertDialog( //створюється  спливаюче вікно
        backgroundColor: const Color(0xFF15131F),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text(
          'Тест завершено! 🎉',
          style: GoogleFonts.pixelifySans(color: Colors.white, fontSize: 24),
        ),
        //текст усередині вікна
        content: Text(
          'Твій результат: $_score з ${widget.dynamicQuestions.length} правильних відповідей!',
          style: const TextStyle(color: Colors.white70, fontSize: 16),
        ),
        //Список кнопок у нижній частині діалогового вікна
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

  Future<bool> _onWillPop() async {
    if (!_isTestingMode) return true;

    final shouldLeave = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF15131F),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('Перервати тест?', style: TextStyle(color: Colors.white)),
        content: const Text(
          'Ваш поточний прогрес у тесті буде втрачено.',
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

    if (shouldLeave == true) {
      setState(() {
        _isTestingMode = false;
        _item = 0;
        _selected = null;
        _score = 0;
      });
    }
    return shouldLeave ?? false;
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: !_isTestingMode,
      onPopInvokedWithResult: (didPop, result) async {
        if (!didPop && _isTestingMode) {
          await _onWillPop();
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
                final shouldLeave = await _onWillPop();
                if (shouldLeave && context.mounted) {
                  Navigator.pop(context);
                }
              } else {
                Navigator.pop(context);
              }
            },
          ),
          title: Row(
            children: [
              // Тег предмета
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
              // Тег теми
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
              child: _isTestingMode ? _buildTestMode() : _buildOverviewMode(),
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
                onPressed: widget.dynamicQuestions.isNotEmpty
                    ? () {
                        setState(() {
                          _isTestingMode = true;
                        });
                      }
                    : null,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF2563EB),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                    side: const BorderSide(color: Colors.white38, width: 1.5),
                  ),
                  elevation: 8,
                ),
                child: const Text(
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
    if (widget.dynamicQuestions.isEmpty) {
      return const Center(
        child: Text('Питань немає', style: TextStyle(color: Colors.white)),
      );
    }

    final rawQ = widget.dynamicQuestions[_item];
    final Map currentQuestion = (rawQ is Map) ? rawQ : {};
    
    final double progress = (_item + 1) / widget.dynamicQuestions.length;
    final String questionText = _getQuestionText(currentQuestion);
    final List<String> options = _getOptions(currentQuestion);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
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
        SizedBox(
          width: double.infinity,
          height: 52,
          child: ElevatedButton(
            onPressed: _selected != null ? _nextQuestion : null,
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF2563EB),
              disabledBackgroundColor: Colors.white.withValues(alpha: 0.1),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
            child: Text(
              _item == widget.dynamicQuestions.length - 1 ? 'Завершити тест' : 'Наступне питання',
              style: TextStyle(
                color: _selected != null ? Colors.white : Colors.white38,
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ),
      ],
    );
  }
}