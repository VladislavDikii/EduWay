
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../services/auth_service.dart';


Future<String?> showChangeUsernameDialog(
  BuildContext context, {
  required String currentName,
}) {
  return showDialog<String>(
    context: context,
    barrierDismissible: false,
    builder: (_) => _ChangeUsernameDialog(currentName: currentName),
  );
}


String? validateNewUsername(String? raw, String currentName) {
  final name = (raw ?? '').trim();
  if (name.isEmpty) return 'Введіть нове ім\'я';
  if (name.length > 50) return 'Максимум 50 символів';
  if (name == currentName) return 'Це ваше поточне ім\'я';
  return null;
}

class _ChangeUsernameDialog extends StatefulWidget {
  final String currentName;
  const _ChangeUsernameDialog({required this.currentName});

  @override
  State<_ChangeUsernameDialog> createState() => _ChangeUsernameDialogState();
}

class _ChangeUsernameDialogState extends State<_ChangeUsernameDialog> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _passwordController = TextEditingController();

  bool _loading = false;
  String? _serverError;

  @override
  void dispose() {
    _nameController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (_loading) return;
    setState(() => _serverError = null);
    if (!_formKey.currentState!.validate()) return;

    final newName = _nameController.text.trim();
    setState(() => _loading = true);

    final status = await AuthService.changeUsername(
      newName,
      _passwordController.text,
    );
    if (!mounted) return;

    if (status == 200) {
      Navigator.pop(context, newName);
      return;
    }

    setState(() {
      _loading = false;
      if (status == 409) {
        _serverError = 'Таке ім\'я вже зайняте';
      } else if (status == 401) {
        _serverError = 'Невірний пароль';
      } else if (status == -1) {
        _serverError = 'Немає зв\'язку із сервером';
      } else {
        _serverError = 'Не вдалося змінити ім\'я (код $status)';
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      backgroundColor: const Color(0xFF15131F),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      title: Text(
        'Зміна імені користувача',
        style: GoogleFonts.pixelifySans(color: Colors.white, fontSize: 22),
      ),
      content: SizedBox(
        width: 360,
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Поточне ім\'я: ${widget.currentName}',
                style: const TextStyle(color: Colors.white70, fontSize: 13),
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _nameController,
                autofocus: true,
                enabled: !_loading,
                style: const TextStyle(color: Colors.white),
                decoration: const InputDecoration(
                  labelText: 'Нове ім\'я',
                  labelStyle: TextStyle(color: Colors.white70),
                  errorStyle:
                      TextStyle(color: Colors.redAccent, fontSize: 13),
                ),
                validator: (v) => validateNewUsername(v, widget.currentName),
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _passwordController,
                enabled: !_loading,
                obscureText: true,
                style: const TextStyle(color: Colors.white),
                decoration: const InputDecoration(
                  labelText: 'Пароль (для підтвердження)',
                  labelStyle: TextStyle(color: Colors.white70),
                  errorStyle:
                      TextStyle(color: Colors.redAccent, fontSize: 13),
                ),
                validator: (v) =>
                    (v == null || v.isEmpty) ? 'Введіть пароль' : null,
                onFieldSubmitted: (_) => _submit(),
              ),
              if (_serverError != null) ...[
                const SizedBox(height: 12),
                Text(
                  _serverError!,
                  style:
                      const TextStyle(color: Colors.redAccent, fontSize: 13),
                ),
              ],
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: _loading ? null : () => Navigator.pop(context),
          child: const Text('Скасувати',
              style: TextStyle(color: Colors.white70)),
        ),
        ElevatedButton(
          onPressed: _loading ? null : _submit,
          style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF2563EB)),
          child: _loading
              ? const SizedBox(
                  width: 18,
                  height: 18,
                  child: CircularProgressIndicator(
                      strokeWidth: 2, color: Colors.white),
                )
              : const Text('Зберегти',
                  style: TextStyle(color: Colors.white)),
        ),
      ],
    );
  }
}
