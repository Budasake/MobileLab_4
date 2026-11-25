import 'package:flutter/material.dart';

String? validateNewPassword(String? v) {
  final p = v ?? '';
  if (p.length < 8) return 'Хамгийн багадаа 8 тэмдэгт';
  if (!RegExp(r'\d').hasMatch(p)) return 'Дор хаяж нэг тоо оруулна уу';
  if (!RegExp(r'\p{L}', unicode: true).hasMatch(p)) {
    return 'Дор хаяж нэг үсэг оруулна уу';
  }
  if (p.contains(' ')) return 'Хоосон зай оруулж болохгүй';
  return null;
}

enum PasswordStrength { empty, weak, medium, strong }

PasswordStrength passwordStrength(String p) {
  if (p.isEmpty) return PasswordStrength.empty;
  var score = 0;
  if (p.length >= 8) score++;
  if (p.length >= 12) score++;
  if (RegExp(r'\p{Ll}', unicode: true).hasMatch(p) &&
      RegExp(r'\p{Lu}', unicode: true).hasMatch(p)) {
    score++;
  }
  if (RegExp(r'\d').hasMatch(p)) score++;
  if (RegExp(r'[^\p{L}\d]', unicode: true).hasMatch(p)) score++;
  if (score <= 2) return PasswordStrength.weak;
  if (score <= 3) return PasswordStrength.medium;
  return PasswordStrength.strong;
}

extension PasswordStrengthUi on PasswordStrength {
  double get value => switch (this) {
        PasswordStrength.empty => 0,
        PasswordStrength.weak => 0.33,
        PasswordStrength.medium => 0.66,
        PasswordStrength.strong => 1,
      };

  String get label => switch (this) {
        PasswordStrength.empty => '',
        PasswordStrength.weak => 'Сул',
        PasswordStrength.medium => 'Дунд',
        PasswordStrength.strong => 'Хүчтэй',
      };

  Color color(ColorScheme s) => switch (this) {
        PasswordStrength.empty => s.outline,
        PasswordStrength.weak => s.error,
        PasswordStrength.medium => Colors.orange,
        PasswordStrength.strong => Colors.green,
      };
}
