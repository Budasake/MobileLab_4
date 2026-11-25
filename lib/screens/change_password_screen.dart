// lib/screens/change_password_screen.dart
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../state/auth_service.dart';
import '../utils/validators.dart';
import '../widgets/password_field.dart';

class ChangePasswordScreen extends StatefulWidget {
  const ChangePasswordScreen({super.key});

  @override
  State<ChangePasswordScreen> createState() => _ChangePasswordScreenState();
}

class _ChangePasswordScreenState extends State<ChangePasswordScreen> {
  final _formKey = GlobalKey<FormState>();
  final _currentKey = GlobalKey<FormFieldState<String>>();
  final _current = TextEditingController();
  final _next = TextEditingController();
  final _confirm = TextEditingController();
  bool _saving = false;
  String? _currentError; // серверээс ирсэн алдаа

  @override
  void dispose() {
    _current.dispose();
    _next.dispose();
    _confirm.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (_saving) return;
    setState(() => _currentError = null);
    if (!_formKey.currentState!.validate()) return;

    setState(() => _saving = true);
    final ok = await auth.changePassword(_current.text, _next.text);
    if (!mounted) return;
    setState(() => _saving = false);

    if (!ok) {
      _currentError = 'Одоогийн нууц үг буруу байна';
      _formKey.currentState!.validate();
      return;
    }
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Нууц үг амжилттай солигдлоо')),
    );
    context.pop();
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Scaffold(
      appBar: AppBar(title: const Text('Нууц үг солих')),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(24),
          children: [
            PasswordField(
              controller: _current,
              label: 'Одоогийн нууц үг',
              autofillHints: const [AutofillHints.password],
              fieldKey: _currentKey,
              onChanged: (_) {
                if (_currentError != null) {
                  _currentError = null;
                  _currentKey.currentState?.validate();
                }
              },
              validator: (v) {
                if (v == null || v.isEmpty) {
                  return 'Одоогийн нууц үгээ оруулна уу';
                }
                return _currentError;
              },
            ),
            const SizedBox(height: 12),
            PasswordField(
              controller: _next,
              label: 'Шинэ нууц үг',
              helperText: '8+ тэмдэгт, дор хаяж нэг үсэг ба нэг тоо',
              autofillHints: const [AutofillHints.newPassword],
              validator: (v) {
                final error = validateNewPassword(v);
                if (error != null) return error;
                if (v == _current.text) {
                  return 'Шинэ нууц үг одоогийнхоос өөр байх ёстой';
                }
                return null;
              },
            ),
            // Нууц үгийн хүч: сул / дунд / хүчтэй
            ListenableBuilder(
              listenable: _next,
              builder: (context, _) {
                final s = passwordStrength(_next.text);
                final color = s.color(scheme);
                return Padding(
                  padding: const EdgeInsets.only(top: 8),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      LinearProgressIndicator(
                        value: s.value,
                        color: color,
                        backgroundColor: scheme.surfaceContainerHighest,
                        minHeight: 6,
                        borderRadius: BorderRadius.circular(3),
                      ),
                      if (s != PasswordStrength.empty)
                        Padding(
                          padding: const EdgeInsets.only(top: 4),
                          child: Text(
                            'Нууц үгийн хүч: ${s.label}',
                            style: Theme.of(context)
                                .textTheme
                                .bodySmall
                                ?.copyWith(color: color),
                          ),
                        ),
                    ],
                  ),
                );
              },
            ),
            const SizedBox(height: 12),
            PasswordField(
              controller: _confirm,
              label: 'Шинэ нууц үгээ давтах',
              textInputAction: TextInputAction.done,
              autofillHints: const [AutofillHints.newPassword],
              onFieldSubmitted: (_) => _submit(),
              validator: (v) =>
                  v != _next.text ? 'Нууц үг таарахгүй байна' : null,
            ),
            const SizedBox(height: 24),
            FilledButton(
              onPressed: _saving ? null : _submit,
              child: _saving
                  ? const SizedBox(
                      height: 20,
                      width: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        semanticsLabel: 'Хадгалж байна',
                      ),
                    )
                  : const Text('Нууц үг солих'),
            ),
          ],
        ),
      ),
    );
  }
}
