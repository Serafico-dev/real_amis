import 'package:flutter/material.dart';
import 'package:real_amis/common/helpers/is_dark_mode.dart';
import 'package:real_amis/core/configs/theme/app_colors.dart';
import 'package:real_amis/core/utils/format_data.dart';

class MatchDate extends StatelessWidget {
  final DateTime date;

  const MatchDate({super.key, required this.date});

  @override
  Widget build(BuildContext context) {
    final color = context.isDarkMode
        ? AppColors.textDarkPrimary
        : AppColors.textLightPrimary;

    return Text(
      formatDateByddMMYYYYnHHmm(date),
      style: TextStyle(fontWeight: FontWeight.bold, color: color),
      textAlign: TextAlign.center,
    );
  }
}
