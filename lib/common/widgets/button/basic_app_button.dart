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

    // Nel tema scuro il rosso del brand su fondo scuro ha solo 1,95:1: per il
    // bottone "outline" (testo e bordo sul fondo) uso il teal.
    final Color outlineColor = isDark
        ? AppColors.tertiary
        : AppColors.buttonPrimaryLight;

    final Color fg = isOutline ? outlineColor : Colors.white;

    final Color bg = isOutline
        ? Colors.transparent
        : (isDark ? AppColors.buttonPrimaryDark : AppColors.buttonPrimaryLight);

    // Testo leggibile anche quando il bottone è disattivato (prima bianco al
    // 70% su grigio chiaro: circa 2:1).
    final Color textColor = disabled
        ? (isOutline
              ? (isDark
                    ? AppColors.textDarkSecondary
                    : AppColors.textLightSecondary)
              : AppColors.textLightPrimary)
        : fg;

    // L'altezza è un minimo: con il testo ingrandito il bottone cresce invece
    // di tagliare la scritta.
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: disabled ? AppColors.buttonDisabled : bg,
          foregroundColor: disabled ? AppColors.buttonDisabled : fg,
          side: isOutline
              ? BorderSide(
                  color: disabled ? AppColors.buttonDisabled : outlineColor,
                  width: 1.5,
                )
              : null,
          minimumSize: Size.fromHeight(height ?? 60),
        ),
        child: Text(title, style: TextStyle(color: textColor)),
      ),
    );
  }
}
