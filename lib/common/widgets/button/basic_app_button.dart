import 'package:flutter/material.dart';
import 'package:real_amis/core/configs/theme/app_colors.dart';

class BasicAppButton extends StatelessWidget {
  final VoidCallback? onPressed;
  final String title;
  final double? height;
  final bool isOutline;

  const BasicAppButton({
    super.key,
    required this.onPressed,
    required this.title,
    this.height,
    this.isOutline = false,
  });

  @override
  Widget build(BuildContext context) {
    final bool isDark = Theme.of(context).brightness == Brightness.dark;
    final bool disabled = onPressed == null;

    final Color fg = isOutline
        ? (isDark ? AppColors.buttonPrimaryDark : AppColors.buttonPrimaryLight)
        : Colors.white;

    final Color bg = isOutline
        ? Colors.transparent
        : (isDark ? AppColors.buttonPrimaryDark : AppColors.buttonPrimaryLight);

    return SizedBox(
      width: double.infinity,
      height: height ?? 60,
      child: ElevatedButton(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: disabled ? AppColors.buttonDisabled : bg,
          foregroundColor: disabled ? AppColors.buttonDisabled : fg,
          side: isOutline
              ? BorderSide(
                  color: disabled
                      ? AppColors.buttonDisabled
                      : (isDark
                            ? AppColors.buttonPrimaryDark
                            : AppColors.buttonPrimaryLight),
                  width: 1.5,
                )
              : null,
          minimumSize: Size.fromHeight(height ?? 60),
        ),
        child: Opacity(
          opacity: disabled ? 0.7 : 1.0,
          child: Text(title, style: TextStyle(color: fg)),
        ),
      ),
    );
  }
}
