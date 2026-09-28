import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_localization/flutter_localization.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:real_amis/core/configs/theme/app_theme.dart';
import 'package:real_amis/init_dependencies.dart';
import 'package:real_amis/presentation/splash/pages/splash.dart';
import 'package:real_amis/presentation/choose_mode/providers/theme_provider.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await FlutterLocalization.instance.ensureInitialized();
  await initDependencies();

  runApp(const ProviderScope(child: MainApp()));
}

class MainApp extends ConsumerWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final themeMode = ref.watch(themeNotifierProvider);
    final supportedLocales = const [Locale('en', 'US'), Locale('it', 'IT')];
    final localizationDelegates = [
      GlobalMaterialLocalizations.delegate,
      GlobalWidgetsLocalizations.delegate,
      GlobalCupertinoLocalizations.delegate,
      ...localization.localizationsDelegates,
    ];

    return MaterialApp(
      theme: AppTheme.light(),
      darkTheme: AppTheme.dark(),
      themeMode: themeMode,
      supportedLocales: supportedLocales,
      localizationsDelegates: localizationDelegates,
      debugShowCheckedModeBanner: false,
      home: const SplashPage(),
    );
  }
}

/*
  TODO:
  - Notifica ad ogni evento (richiede notifiche push/realtime, non locali - da valutare separatamente)
*/
