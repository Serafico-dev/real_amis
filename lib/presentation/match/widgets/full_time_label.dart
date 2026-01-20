import 'package:flutter/material.dart';
import 'package:real_amis/common/helpers/is_dark_mode.dart';
import 'package:real_amis/core/configs/theme/app_colors.dart';

class FullTimeLabel extends StatelessWidget {
  const FullTimeLabel({super.key});

  @override
  Widget build(BuildContext context) {
    final color = context.isDarkMode
        ? AppColors.textDarkPrimary
        : AppColors.textLightPrimary;

    return Text(
      'FULL TIME',
      style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18, color: color),
      textAlign: TextAlign.center,
    );
  }
}
