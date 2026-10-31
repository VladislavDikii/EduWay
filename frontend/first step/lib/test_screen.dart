import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class TestScreen extends StatefulWidget {
  final String topicTitle; //зберігається назва обраної теми
  final List questions;    //передаєм список запитань
  final String subjectTitle;

  const TestScreen({
    super.key,
    required this.questions,
    required this.topicTitle, //змінна є обов'язкова при виклику екрану
    required this.subjectTitle,
  });

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

//функція переходу до наступного питання
void _nextQuestion() {
    if (_selected == widget.questions[_item]['correctIndex']) {
      _score++;
    }

    if (_item < widget.questions.length - 1) {
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
          'Твій результат: $_score з ${widget.questions.length} правильних відповідей!',
          style: const TextStyle(color: Colors.white70, fontSize: 16),
        ),
        //Список кнопок у нижній частині діалогового вікна
        actions: [
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context); // Закрити діалог
              Navigator.pop(context); // Повернутися на HomeScreen
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

@override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0E1224),
      appBar: AppBar( //Верхня шапка екрана
        backgroundColor: const Color(0xFF15131F),
        elevation: 0, //Прибирає тінь під панеллю
        leading: IconButton( //кнопка повернення назад
          icon: const Icon(Icons.arrow_back_ios_new_rounded, color: Colors.white),
          onPressed: () {
            if (_isTestingMode) {
              // Якщо натиснули "Назад" під час тесту — повертаємо до перегляду
              setState(() {
                _isTestingMode = false;
                _item = 0;
                _selected = null;
                _score = 0;
              });
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
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                border: Border.all(color: Colors.white70),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                widget.topicTitle,
                style: GoogleFonts.pixelifySans(color: Colors.white, fontSize: 14),
              ),
            ),
          ],
        ),
      ),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 1000), // Оптимальна ширина для десктопа
          child: Padding(
            padding: const EdgeInsets.all(20.0),
            child: _isTestingMode ? _buildTestMode() : _buildOverviewMode(),
          ),
        ),
      ),
    );
  }

  // 1. РЕЖИМ ПЕРЕГЛЯДУ (СІТКА 2 СТОВПЧИКИ + КНОПКА START)
  Widget _buildOverviewMode() {
    return Stack(
      children: [
        // Двоколоночна сітка із запитаннями
        GridView.builder(
          padding: const EdgeInsets.only(bottom: 80.0), // Відступ знизу, щоб кнопка Start не перекривала вміст
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2, // 2 колонки як на макеті
            crossAxisSpacing: 16,
            mainAxisSpacing: 16,
            childAspectRatio: 1.6, // Співвідношення сторін картки
          ),
          itemCount: widget.questions.length,
          itemBuilder: (context, qIndex) {
            final q = widget.questions[qIndex];
            final options = List<String>.from(q['options']);
            final correctIdx = q['correctIndex'] as int;

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
                    q['question'],
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(color: Colors.white, fontSize: 15, fontWeight: FontWeight.bold),
                  ),
                  const Padding(
                    padding: EdgeInsets.symmetric(vertical: 8.0),
                    child: Divider(color: Colors.white24, height: 1),
                  ),
                  // Відображення правильної відповіді
                  Expanded(
                    child: Align(
                      alignment: Alignment.centerLeft,
                      child: Text(
                        'Відповідь: ${options[correctIdx]}',
                        style: const TextStyle(color: Colors.greenAccent, fontSize: 14, fontWeight: FontWeight.w600),
                      ),
                    ),
                  ),
                ],
              ),
            );
          },
        ),

        // Спливаюча (плаваюча) кнопка "START" по центру знизу
        Positioned(
          bottom: 16,
          left: 0,
          right: 0,
          child: Center(
            child: SizedBox(
              width: 180,
              height: 50,
              child: ElevatedButton(
                onPressed: () {
                  setState(() {
                    _isTestingMode = true; // Запуск тесту
                  });
                },
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

      // 2. РЕЖИМ ПРОХОДЖЕННЯ ТЕСТУ
  Widget _buildTestMode() {
    final currentQuestion = widget.questions[_item];
    final double progress = (_item + 1) / widget.questions.length;
    final List<String> options = List<String>.from(currentQuestion['options']);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Індикатор прогресу
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

        // Картка з питанням
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(24.0),
          decoration: BoxDecoration(
            color: const Color(0xFF15131F),
            borderRadius: BorderRadius.circular(16.0),
            border: Border.all(color: Colors.white.withValues(alpha: 0.08)),
          ),
          child: Text(
            currentQuestion['question'],
            style: GoogleFonts.roboto(color: Colors.white, fontSize: 20, fontWeight: FontWeight.w600),
          ),
        ),
        const SizedBox(height: 20),

        // Варіанти відповідей
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

        // Кнопка "Наступне питання" / "Завершити тест"
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
              _item == widget.questions.length - 1 ? 'Завершити тест' : 'Наступне питання',
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