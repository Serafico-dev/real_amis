import 'package:flutter/material.dart';
import 'package:real_amis/common/helpers/is_dark_mode.dart';
import 'package:real_amis/core/configs/theme/app_colors.dart';

class MatchDay extends StatelessWidget {
  final String? day;

  const MatchDay({super.key, this.day});

  @override
  Widget build(BuildContext context) {
    if (day == null || day!.isEmpty) return const SizedBox.shrink();

    final color = context.isDarkMode
        ? AppColors.textDarkPrimary
        : AppColors.textLightPrimary;

    return Align(
      alignment: Alignment.centerRight,
      child: Text(
        day!,
        style: TextStyle(
          fontSize: 20,
          fontWeight: FontWeight.bold,
          color: color,
        ),
      ),
    );
  }
}
