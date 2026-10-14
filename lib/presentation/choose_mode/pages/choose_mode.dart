import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:real_amis/common/widgets/button/basic_app_button.dart';
import 'package:real_amis/core/configs/assets/app_vectors.dart';
import 'package:real_amis/core/configs/theme/app_colors.dart';
import 'package:real_amis/presentation/choose_mode/providers/theme_provider.dart';
import 'package:real_amis/presentation/main/pages/main_page.dart';

class ChooseModePage extends ConsumerWidget {
  const ChooseModePage({super.key});

  static MaterialPageRoute route() =>
      MaterialPageRoute(builder: (_) => const ChooseModePage());

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final themeMode = ref.watch(themeNotifierProvider);
    final isDarkMode = themeMode == ThemeMode.dark;
    final textColor = isDarkMode
        ? AppColors.textDarkPrimary
        : AppColors.textLightPrimary;

    return Scaffold(
      // Contenuto scorrevole: con il testo ingrandito o in orizzontale non
      // sfora più lo schermo; negli altri casi resta centrato come prima.
      body: LayoutBuilder(
        builder: (context, constraints) => SingleChildScrollView(
          padding: const EdgeInsets.symmetric(vertical: 40, horizontal: 40),
          child: ConstrainedBox(
            constraints: BoxConstraints(
              minHeight: constraints.maxHeight > 80
                  ? constraints.maxHeight - 80
                  : 0,
            ),
            child: IntrinsicHeight(
              child: Column(
          children: [
            const Spacer(),
            Align(
              alignment: Alignment.topCenter,
              child: Image.asset(
                AppVectors.logo,
                width: 250,
                semanticLabel: 'Real Amis',
              ),
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
                  isDarkMode: isDarkMode,
                  onTap: () => ref
                      .read(themeNotifierProvider.notifier)
                      .updateTheme(ThemeMode.dark),
                ),
                const SizedBox(width: 40),
                ThemeModeCircle(
                  icon: Icons.light_mode,
                  label: 'Chiaro',
                  selected: !isDarkMode,
                  isDarkMode: isDarkMode,
                  onTap: () => ref
                      .read(themeNotifierProvider.notifier)
                      .updateTheme(ThemeMode.light),
                ),
              ],
            ),
            const SizedBox(height: 50),
            BasicAppButton(
              onPressed: () async {
                final prefs = await SharedPreferences.getInstance();
                final saved = await prefs.setBool(
                  'initial_onboarding_completed',
                  true,
                );
                await prefs.reload();

                // Non procedere se il flag non è stato effettivamente persistito.
                if (!saved ||
                    prefs.getBool('initial_onboarding_completed') != true) {
                  return;
                }

                if (!context.mounted) return;
                Navigator.pushReplacement(context, MainPage.route());
              },
              title: 'Prosegui',
            ),
          ],
              ),
            ),
          ),
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
  final bool isDarkMode;

  const ThemeModeCircle({
    super.key,
    required this.icon,
    required this.label,
    required this.onTap,
    required this.selected,
    required this.isDarkMode,
  });

  @override
  Widget build(BuildContext context) {
    final circleColor = isDarkMode
        ? AppColors.cardDark.withValues(alpha: 0.5)
        : AppColors.cardLight.withValues(alpha: 0.5);
    // Il rosso del brand su fondo scuro ha solo 1,95:1 di contrasto: nel tema
    // scuro l'elemento selezionato usa il teal (5,9:1).
    final accent = isDarkMode ? AppColors.tertiary : AppColors.primary;
    final borderColor = selected ? accent : Colors.transparent;
    final textColor = selected
        ? accent
        : isDarkMode
        ? AppColors.textDarkPrimary
        : AppColors.textLightPrimary;

    return Semantics(
      button: true,
      selected: selected,
      label: 'Tema $label',
      onTap: onTap,
      excludeSemantics: true,
      child: Column(
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
            fontWeight: selected ? FontWeight.w700 : FontWeight.w500,
            fontSize: 17,
            color: textColor,
          ),
        ),
      ],
      ),
    );
  }
}
