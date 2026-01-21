import 'package:flutter/material.dart';

class AppColors {
  // --- Core logo colors ---
  static const Color logoRed = Color(0xFF871B2B);
  static const Color logoBlue = Color(0xFF113073);
  static const Color logoGold = Color(0xFFB8A678);
  static const Color logoTeal = Color(0xFF7698A2);

  // --- Primary / secondary for app theme ---
  static const Color primary = logoRed;
  static const Color secondary = logoBlue;
  static const Color tertiary = logoTeal;
  static const Color accent = logoGold;

  // --- Background colors ---
  static const Color bgLight = Color(0xFFF5F5F5);
  static const Color bgDark = Color(0xFF121212);
  static const Color cardLight = Colors.white;
  static const Color cardDark = Color(0xFF1E1E1E);

  // --- Text colors ---
  static const Color textLightPrimary = Color(0xFF111111);
  static const Color textLightSecondary = Color(0xFF555555);
  static const Color textDarkPrimary = Color(0xFFFFFFFF);
  static const Color textDarkSecondary = Color(0xFFCCCCCC);

  // --- Input fields ---
  static const Color inputBorderLight = Color(0xFFB0B0B0);
  static const Color inputBorderDark = Color(0xFF555555);
  static const Color inputFillLight = Color.fromRGBO(118, 152, 162, 0.1);
  static const Color inputFillDark = Color.fromRGBO(118, 152, 162, 0.2);
  static const Color inputTextLight = textLightPrimary;
  static const Color inputTextDark = textDarkPrimary;

  // --- Buttons ---
  static const Color buttonPrimary = primary;
  static const Color buttonPrimaryDark = primary;
  static const Color buttonSecondary = secondary;
  static const Color buttonSecondaryDark = secondary;
  static const Color buttonDisabled = Color(0xFFB0B0B0);

  // --- Accent colors for tags, badges, icons ---
  static const Color tagRed = logoRed;
  static const Color tagBlue = logoBlue;
  static const Color tagGold = logoGold;
  static const Color tagTeal = logoTeal;
  static const Color badgeRed = logoRed;
  static const Color badgeBlue = logoBlue;
  static const Color badgeGold = logoGold;
  static const Color badgeTeal = logoTeal;
  static const Color iconPrimary = textLightPrimary;
  static const Color iconDark = textDarkPrimary;

  // --- Dividers and borders ---
  static const Color dividerLight = Color(0xFFDDDDDD);
  static const Color dividerDark = Color(0xFF333333);

  // --- Shadows ---
  static const Color shadowLight = Color.fromRGBO(0, 0, 0, 0.05);
  static const Color shadowDark = Color.fromRGBO(0, 0, 0, 0.5);

  static Color matchCardColor(bool isDarkMode, bool isEven) {
    if (isDarkMode) {
      return isEven
          ? AppColors.cardDark.withValues(alpha: 0.25)
          : AppColors.tertiary.withValues(alpha: 0.25);
    } else {
      return isEven
          ? AppColors.cardLight.withValues(alpha: 0.25)
          : AppColors.primary.withValues(alpha: 0.25);
    }
  }
}
