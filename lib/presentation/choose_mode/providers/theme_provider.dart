import 'package:flutter/material.dart';
import 'package:flutter_riverpod/legacy.dart';
import 'theme_notifier.dart';

final themeNotifierProvider = StateNotifierProvider<ThemeNotifier, ThemeMode>(
  (ref) => ThemeNotifier(),
);
