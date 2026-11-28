
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';


Future<int?> showTicketSetupDialog(
  BuildContext context, {
  required String subjectName,
  required int maxQuestions,
}) {
  return showDialog<int>(
    context: context,
    builder: (_) => _TicketSetupDialog(
      subjectName: subjectName,
      maxQuestions: maxQuestions,
    ),
  );
}


String? validateQuestionCount(String? raw, int max) {
  final text = (raw ?? '').trim();
  if (text.isEmpty) return 'Введіть кількість питань';
  final n = int.tryParse(text);
  if (n == null) return 'Введіть ціле число';
  if (n < 1) return 'Мінімум 1 питання';
  if (n > max) return 'Максимум $max (стільки питань у предметі)';
  return null;
}


Map<int, int> distributeAcrossTopics(List<dynamic> topics, int n) {
  final slots = <int>[];
  for (final t in topics) {
    final id = t['id'] as int;
    final cnt = (t['questions'] as num?)?.toInt() ?? 0;
    slots.addAll(List.filled(cnt, id));
  }
  slots.shuffle(Random());
  final result = <int, int>{};
  for (final id in slots.take(n)) {
    result[id] = (result[id] ?? 0) + 1;
  }
  return result;
}

class _TicketSetupDialog extends StatefulWidget {
  final String subjectName;
  final int maxQuestions;

  const _TicketSetupDialog({
    required this.subjectName,
    required this.maxQuestions,
  });

  @override
  State<_TicketSetupDialog> createState() => _TicketSetupDialogState();
}

class _TicketSetupDialogState extends State<_TicketSetupDialog> {
  final _formKey = GlobalKey<FormState>();
  final _controller = TextEditingController();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _submit() {
    if (_formKey.currentState!.validate()) {
      Navigator.pop(context, int.parse(_controller.text.trim()));
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      backgroundColor: const Color(0xFF15131F),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      title: Text(
        'Налаштування квитка',
        style: GoogleFonts.pixelifySans(color: Colors.white, fontSize: 22),
      ),
      content: Form(
        key: _formKey,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              widget.subjectName,
              style: const TextStyle(
                  color: Colors.white, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 4),
            Text(
              'Доступно питань: ${widget.maxQuestions}',
              style: const TextStyle(color: Colors.white70, fontSize: 13),
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _controller,
              autofocus: true,
              keyboardType: TextInputType.number,
              style: const TextStyle(color: Colors.white),
              decoration: InputDecoration(
                labelText: 'Кількість питань (1–${widget.maxQuestions})',
                labelStyle: const TextStyle(color: Colors.white70),
                errorStyle:
                    const TextStyle(color: Colors.redAccent, fontSize: 13),
              ),
              validator: (v) => validateQuestionCount(v, widget.maxQuestions),
              onFieldSubmitted: (_) => _submit(),
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Скасувати',
              style: TextStyle(color: Colors.white70)),
        ),
        ElevatedButton(
          onPressed: _submit,
          style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF2563EB)),
          child: const Text('Почати', style: TextStyle(color: Colors.white)),
        ),
      ],
    );
  }
}
