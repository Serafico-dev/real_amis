import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:real_amis/common/helpers/is_dark_mode.dart';
import 'package:real_amis/common/widgets/button/basic_app_button.dart';
import 'package:real_amis/core/configs/assets/app_vectors.dart';
import 'package:real_amis/core/configs/theme/app_colors.dart';
import 'package:real_amis/presentation/auth/pages/signin.dart';
import 'package:real_amis/presentation/choose_mode/bloc/theme_cubit.dart';

class ChooseModePage extends StatelessWidget {
  const ChooseModePage({super.key});

  static MaterialPageRoute route() =>
      MaterialPageRoute(builder: (_) => const ChooseModePage());

  @override
  Widget build(BuildContext context) {
    final isDarkMode = context.isDarkMode;

    final textColor = isDarkMode
        ? AppColors.textDarkPrimary
        : AppColors.textLightPrimary;

    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.symmetric(vertical: 40, horizontal: 40),
        child: Column(
          children: [
            const Spacer(),

            Align(
              alignment: Alignment.topCenter,
              child: Image.asset(AppVectors.logo, width: 250),
            ),

            const Spacer(),

            Text(
              'Scegli il tema',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 18,
                color: textColor,
              ),
            ),
            const SizedBox(height: 40),

            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                ThemeModeCircle(
                  icon: Icons.dark_mode,
                  label: 'Scuro',
                  selected: isDarkMode,
                  onTap: () =>
                      context.read<ThemeCubit>().updateTheme(ThemeMode.dark),
                ),
                const SizedBox(width: 40),
                ThemeModeCircle(
                  icon: Icons.light_mode,
                  label: 'Chiaro',
                  selected: !isDarkMode,
                  onTap: () =>
                      context.read<ThemeCubit>().updateTheme(ThemeMode.light),
                ),
              ],
            ),

            const SizedBox(height: 50),

            BasicAppButton(
              onPressed: () => Navigator.push(context, SigninPage.route()),
              title: 'Prosegui',
            ),
          ],
        ),
      ),
    );
  }
}

class ThemeModeCircle extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;
  final bool selected;

  const ThemeModeCircle({
    super.key,
    required this.icon,
    required this.label,
    required this.onTap,
    required this.selected,
  });

  @override
  Widget build(BuildContext context) {
    final isDarkMode = context.isDarkMode;
    final circleColor = isDarkMode
        ? AppColors.cardDark.withValues(alpha: 0.5)
        : AppColors.cardLight.withValues(alpha: 0.5);
    final borderColor = selected ? AppColors.primary : Colors.transparent;
    final textColor = selected
        ? AppColors.primary
        : isDarkMode
        ? AppColors.textDarkPrimary
        : AppColors.textLightPrimary;

    return Column(
      children: [
        Material(
          color: Colors.transparent,
          shape: const CircleBorder(),
          child: InkWell(
            onTap: onTap,
            customBorder: const CircleBorder(),
            child: ClipOval(
              child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                child: Container(
                  height: 80,
                  width: 80,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: circleColor,
                    border: Border.all(color: borderColor, width: 2),
                  ),
                  child: Icon(
                    icon,
                    color: textColor,
                    size: 32,
                    semanticLabel: label,
                  ),
                ),
              ),
            ),
          ),
        ),
        const SizedBox(height: 15),
        Text(
          label,
          style: TextStyle(
            fontWeight: FontWeight.w500,
            fontSize: 17,
            color: textColor,
          ),
        ),
      ],
    );
  }
}
