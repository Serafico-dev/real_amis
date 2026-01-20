import 'package:flutter/material.dart';
import 'package:real_amis/common/helpers/is_dark_mode.dart';
import 'package:real_amis/core/configs/theme/app_colors.dart';

class EmptyMatches extends StatelessWidget {
  const EmptyMatches({super.key});

  @override
  Widget build(BuildContext context) {
    final iconColor = context.isDarkMode
        ? AppColors.textDarkSecondary
        : AppColors.textLightSecondary;

    final textColor = context.isDarkMode
        ? AppColors.textDarkPrimary
        : AppColors.textLightPrimary;

    return ListView(
      physics: const AlwaysScrollableScrollPhysics(),
      children: [
        const SizedBox(height: 180),
        Icon(Icons.event_busy, size: 64, color: iconColor),
        const SizedBox(height: 12),
        Center(
          child: Text(
            'Nessuna partita trovata',
            style: TextStyle(fontSize: 16, color: textColor),
          ),
        ),
      ],
    );
  }
}
