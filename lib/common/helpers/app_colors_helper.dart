import 'package:flutter/material.dart';
import 'package:real_amis/core/configs/theme/app_colors.dart';

class AppColorsHelper {
  static Color cardForIndex(
    BuildContext context,
    int index, {
    double alpha = 0.25,
    required bool isDark,
  }) {
    if (isDark) {
      return (index.isEven ? AppColors.cardDark : AppColors.tertiary)
          .withValues(alpha: alpha);
    } else {
      return (index.isEven ? AppColors.cardLight : AppColors.primary)
          .withValues(alpha: alpha);
    }
  }
}
