import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:real_amis/common/helpers/is_dark_mode.dart';
import 'package:real_amis/common/widgets/button/basic_app_button.dart';
import 'package:real_amis/core/configs/assets/app_vectors.dart';
import 'package:real_amis/presentation/auth/pages/signin.dart';
import 'package:real_amis/presentation/choose_mode/bloc/theme_cubit.dart';

class ChooseModePage extends StatelessWidget {
  const ChooseModePage({super.key});

  static MaterialPageRoute route() =>
      MaterialPageRoute(builder: (context) => const ChooseModePage());

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 40, horizontal: 40),
            child: Column(
              children: [
                Spacer(),
                Align(
                  alignment: Alignment.topCenter,
                  child: Image.asset(AppVectors.logo, width: 250),
                ),
                Spacer(),
                Text(
                  'Scegli il tema',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: context.isDarkMode ? Colors.white : Colors.black,
                    fontSize: 18,
                  ),
                ),
                SizedBox(height: 40),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    _modeCircle(
                      icon: Icons.dark_mode,
                      label: 'Scuro',
                      isDarkMode: context.isDarkMode,
                      onTap: () {
                        context.read<ThemeCubit>().updateTheme(ThemeMode.dark);
                      },
                    ),
                    SizedBox(width: 40),
                    _modeCircle(
                      icon: Icons.light_mode,
                      label: 'Chiaro',
                      isDarkMode: context.isDarkMode,
                      onTap: () {
                        context.read<ThemeCubit>().updateTheme(ThemeMode.light);
                      },
                    ),
                  ],
                ),
                SizedBox(height: 50),
                BasicAppButton(
                  onPressed: () {
                    Navigator.push(context, SigninPage.route());
                  },
                  title: 'Prosegui',
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _modeCircle({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
    required bool isDarkMode,
  }) {
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
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: Color(0xff30393C).withValues(alpha: 0.5),
                  ),
                  alignment: Alignment.center,
                  child: Icon(icon, semanticLabel: label),
                ),
              ),
            ),
          ),
        ),
        SizedBox(height: 15),
        Text(
          label,
          style: TextStyle(
            fontWeight: FontWeight.w500,
            fontSize: 17,
            color: isDarkMode ? Colors.white : Colors.black,
          ),
        ),
      ],
    );
  }
}
