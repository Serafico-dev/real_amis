import 'package:flutter/material.dart';
import 'package:hydrated_bloc/hydrated_bloc.dart';

class ThemeCubit extends HydratedCubit<ThemeMode> {
  ThemeCubit() : super(ThemeMode.system);

  void updateTheme(ThemeMode themeMode) => emit(themeMode);

  void toggleLightDark() {
    final current = state;
    if (current == ThemeMode.light) {
      emit(ThemeMode.dark);
    } else {
      emit(ThemeMode.light);
    }
  }

  void setSystem() => emit(ThemeMode.system);

  @override
  ThemeMode? fromJson(Map<String, dynamic> json) {
    try {
      final raw = json['theme'];
      if (raw is int && raw >= 0 && raw < ThemeMode.values.length) {
        return ThemeMode.values[raw];
      } else if (raw is String) {
        switch (raw.toLowerCase()) {
          case 'light':
            return ThemeMode.light;
          case 'dark':
            return ThemeMode.dark;
          case 'system':
          default:
            return ThemeMode.system;
        }
      }
    } catch (_) {}
    return ThemeMode.system;
  }

  @override
  Map<String, dynamic>? toJson(ThemeMode state) {
    try {
      return {'theme': state.index};
    } catch (_) {
      return {'theme': ThemeMode.system.index};
    }
  }
}
