import 'package:flutter/material.dart';
import 'package:real_amis/common/helpers/is_dark_mode.dart';
import 'package:real_amis/core/configs/theme/app_colors.dart';
import 'package:real_amis/presentation/auth/enums/password_strength.dart';

class PasswordStrengthIndicator extends StatelessWidget {
  final PasswordStrength strength;

  const PasswordStrengthIndicator({super.key, required this.strength});

  double get _value {
    switch (strength) {
      case PasswordStrength.weak:
        return 0.25;
      case PasswordStrength.medium:
        return 0.5;
      case PasswordStrength.strong:
        return 0.75;
      case PasswordStrength.veryStrong:
        return 1;
      case PasswordStrength.empty:
        return 0;
    }
  }

  Color _color(BuildContext context) {
    final isDark = context.isDarkMode;

    switch (strength) {
      case PasswordStrength.weak:
        return Colors.redAccent;
      case PasswordStrength.medium:
        return Colors.orangeAccent;
      case PasswordStrength.strong:
        return isDark ? AppColors.tertiary : AppColors.primary;
      case PasswordStrength.veryStrong:
        return Colors.green;
      case PasswordStrength.empty:
        return Colors.transparent;
    }
  }

  String get _label {
    switch (strength) {
      case PasswordStrength.weak:
        return 'Password debole';
      case PasswordStrength.medium:
        return 'Password media';
      case PasswordStrength.strong:
        return 'Password forte';
      case PasswordStrength.veryStrong:
        return 'Password ottima';
      case PasswordStrength.empty:
        return '';
    }
  }

  @override
  Widget build(BuildContext context) {
    if (strength == PasswordStrength.empty) {
      return const SizedBox.shrink();
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 8),

        AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          height: 6,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(6),
            color: _color(context).withValues(alpha: 0.2),
          ),
          child: FractionallySizedBox(
            alignment: Alignment.centerLeft,
            widthFactor: _value,
            child: Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(6),
                color: _color(context),
              ),
            ),
          ),
        ),

        const SizedBox(height: 6),

        Text(
          _label,
          style: TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w500,
            color: _color(context),
          ),
        ),
      ],
    );
  }
}
