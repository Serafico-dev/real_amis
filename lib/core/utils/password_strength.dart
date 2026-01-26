import 'package:real_amis/presentation/auth/enums/password_strength.dart';

PasswordStrength evaluatePassword(String password) {
  if (password.isEmpty) return PasswordStrength.empty;

  int score = 0;

  if (password.length >= 8) score++;
  if (password.contains(RegExp(r'[A-Z]'))) score++;
  if (password.contains(RegExp(r'[0-9]'))) score++;
  if (password.contains(RegExp(r'[!@#$%^&*(),.?":{}|<>]'))) score++;

  switch (score) {
    case 0:
    case 1:
      return PasswordStrength.weak;
    case 2:
      return PasswordStrength.medium;
    case 3:
      return PasswordStrength.strong;
    case 4:
      return PasswordStrength.veryStrong;
    default:
      return PasswordStrength.weak;
  }
}
