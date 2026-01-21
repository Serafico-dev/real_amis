import 'package:flutter/material.dart';

class AppColors {
  // =========================================================
  // BRAND (logo – NON usare direttamente per background pieni)
  // =========================================================
  static const Color logoRed  = Color(0xFF871B2B);
  static const Color logoBlue = Color(0xFF113073);
  static const Color logoGold = Color(0xFFB8A678);
  static const Color logoTeal = Color(0xFF7698A2);

  // =========================================================
  // SEMANTIC COLORS (UI-driven, non brand-driven)
  // =========================================================

  /// Primary actions (CTA, selected, highlights)
  static const Color primary = logoRed;

  /// Secondary actions / links
  static const Color secondary = logoBlue;

  /// Informational / neutral accent (dark theme friendly)
  static const Color tertiary = logoTeal;

  /// Special highlights (badges, trophies, premium)
  static const Color accent = logoGold;

  // =========================================================
  // BACKGROUNDS
  // =========================================================

  /// Main app background (light)
  static const Color bgLight = Color(0xFFF4F6F8);

  /// Card / surface on light background
  static const Color cardLight = Color(0xFFFFFFFF);

  /// Main app background (dark)
  static const Color bgDark = Color(0xFF121417);

  /// Card / surface on dark background
  static const Color cardDark = Color(0xFF1B1F24);

  // =========================================================
  // TEXT (WCAG compliant)
  // =========================================================

  // Light theme
  static const Color textLightPrimary   = Color(0xFF111111); // AAA
  static const Color textLightSecondary = Color(0xFF5A5F66); // AA

  // Dark theme
  static const Color textDarkPrimary    = Color(0xFFEDEDED); // AAA
  static const Color textDarkSecondary  = Color(0xFFB5BAC1); // AA

  // =========================================================
  // ICONS
  // =========================================================
  static const Color iconLight = textLightPrimary;
  static const Color iconDark  = textDarkPrimary;

  // =========================================================
  // INPUT FIELDS
  // =========================================================

  static const Color inputBorderLight = Color(0xFFCED4DA);
  static const Color inputBorderDark  = Color(0xFF3A4048);

  static const Color inputFillLight = Color(0x0D7698A2); // teal @ 5%
  static const Color inputFillDark  = Color(0x1A7698A2); // teal @ 10%

  static const Color inputTextLight = textLightPrimary;
  static const Color inputTextDark  = textDarkPrimary;

  // =========================================================
  // BUTTONS
  // =========================================================

  static const Color buttonPrimaryLight = primary;
  static const Color buttonPrimaryDark  = primary;

  static const Color buttonSecondaryLight = secondary;
  static const Color buttonSecondaryDark  = secondary;

  static const Color buttonDisabled = Color(0xFF9EA3A8);

  // =========================================================
  // DIVIDERS & BORDERS
  // =========================================================

  static const Color dividerLight = Color(0xFFE0E3E7);
  static const Color dividerDark  = Color(0xFF2A2F36);

  // =========================================================
  // SHADOWS / ELEVATION
  // =========================================================

  static const Color shadowLight = Color.fromRGBO(0, 0, 0, 0.06);
  static const Color shadowDark  = Color.fromRGBO(0, 0, 0, 0.6);

  // =========================================================
  // MATCH CARD / ALTERNATING LIST COLORS
  // =========================================================

  /// Alternating card colors (index-based, theme-safe)
  static Color matchCardColor({
    required bool isDarkMode,
    required bool isEven,
    double alpha = 0.25,
  }) {
    if (isDarkMode) {
      // dark: grey / blue-teal (NO red!)
      return (isEven ? cardDark : tertiary).withValues(alpha: alpha);
    } else {
      // light: white / soft red
      return (isEven ? cardLight : primary).withValues(alpha: alpha);
    }
  }
}
