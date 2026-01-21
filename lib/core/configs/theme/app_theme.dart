import 'package:flutter/material.dart';
import 'app_colors.dart';

class AppTheme {
  static ThemeData light() {
    final base = ThemeData.light();
    return base.copyWith(
      primaryColor: AppColors.primary,
      scaffoldBackgroundColor: AppColors.bgLight,
      cardColor: AppColors.cardLight,
      dividerColor: AppColors.dividerLight,
      shadowColor: AppColors.shadowLight,
      appBarTheme: AppBarTheme(
        backgroundColor: AppColors.primary,
        foregroundColor: AppColors.textDarkPrimary,
        elevation: 2,
        centerTitle: true,
      ),
      floatingActionButtonTheme: FloatingActionButtonThemeData(
        backgroundColor: AppColors.accent,
        foregroundColor: AppColors.textDarkPrimary,
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.buttonPrimaryLight,
          foregroundColor: AppColors.textDarkPrimary,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: AppColors.buttonSecondaryLight,
          side: BorderSide(color: AppColors.buttonSecondaryLight),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(foregroundColor: AppColors.primary),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: AppColors.inputFillLight,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(color: AppColors.inputBorderLight),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(color: AppColors.primary),
        ),
      ),
      textTheme: base.textTheme.copyWith(
        bodyMedium: TextStyle(color: AppColors.textLightPrimary),
        bodySmall: TextStyle(color: AppColors.textLightSecondary),
      ),
      iconTheme: IconThemeData(color: AppColors.iconLight),
      colorScheme: ColorScheme.light(
        primary: AppColors.primary,
        secondary: AppColors.secondary,
        tertiary: AppColors.tertiary,
        inverseSurface: AppColors.bgLight,
        surface: AppColors.cardLight,
        error: Colors.red.shade700,
        onPrimary: AppColors.textDarkPrimary,
        onSecondary: AppColors.textDarkPrimary,
        onInverseSurface: AppColors.textLightPrimary,
        onSurface: AppColors.textLightPrimary,
        onError: Colors.white,
      ),
    );
  }

  static ThemeData dark() {
    final base = ThemeData.dark();
    return base.copyWith(
      primaryColor: AppColors.primary,
      scaffoldBackgroundColor: AppColors.bgDark,
      cardColor: AppColors.cardDark,
      dividerColor: AppColors.dividerDark,
      shadowColor: AppColors.shadowDark,
      appBarTheme: AppBarTheme(
        backgroundColor: AppColors.primary,
        foregroundColor: AppColors.textDarkPrimary,
        elevation: 2,
        centerTitle: true,
      ),
      floatingActionButtonTheme: FloatingActionButtonThemeData(
        backgroundColor: AppColors.accent,
        foregroundColor: AppColors.textDarkPrimary,
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.buttonPrimaryDark,
          foregroundColor: AppColors.textDarkPrimary,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: AppColors.buttonSecondaryDark,
          side: BorderSide(color: AppColors.buttonSecondaryDark),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(foregroundColor: AppColors.primary),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: AppColors.inputFillDark,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(color: AppColors.inputBorderDark),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(color: AppColors.primary),
        ),
      ),
      textTheme: base.textTheme.copyWith(
        bodyMedium: TextStyle(color: AppColors.textDarkPrimary),
        bodySmall: TextStyle(color: AppColors.textDarkSecondary),
      ),
      iconTheme: IconThemeData(color: AppColors.iconDark),
      colorScheme: ColorScheme.dark(
        primary: AppColors.primary,
        secondary: AppColors.secondary,
        tertiary: AppColors.tertiary,
        inverseSurface: AppColors.bgDark,
        surface: AppColors.cardDark,
        error: Colors.red.shade400,
        onPrimary: AppColors.textDarkPrimary,
        onSecondary: AppColors.textDarkPrimary,
        onInverseSurface: AppColors.textDarkPrimary,
        onSurface: AppColors.textDarkPrimary,
        onError: Colors.white,
      ),
    );
  }
}
