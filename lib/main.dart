import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_localization/flutter_localization.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:real_amis/core/configs/theme/app_theme.dart';
import 'package:real_amis/init_dependencies.dart';
import 'package:real_amis/presentation/auth/providers/app_user_notifier.dart';
import 'package:real_amis/presentation/auth/providers/app_user_provider.dart';
import 'package:real_amis/presentation/splash/pages/splash.dart';
import 'package:real_amis/presentation/splash/pages/splash_logged_in.dart';
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
    final userAsync = ref.watch(appUserProvider);

    final supportedLocales = const [Locale('en', 'US'), Locale('it', 'IT')];
    final localizationDelegates = [
      GlobalMaterialLocalizations.delegate,
      GlobalWidgetsLocalizations.delegate,
      GlobalCupertinoLocalizations.delegate,
      ...localization.localizationsDelegates,
    ];

    return userAsync.when(
      data: (userState) {
        final home = userState.isLoggedIn
            ? const SplashLoggedInPage()
            : const SplashPage();

        return MaterialApp(
          theme: AppTheme.light(),
          darkTheme: AppTheme.dark(),
          themeMode: themeMode,
          supportedLocales: supportedLocales,
          localizationsDelegates: localizationDelegates,
          debugShowCheckedModeBanner: false,
          home: home,
        );
      },
      loading: () => MaterialApp(
        theme: AppTheme.light(),
        darkTheme: AppTheme.dark(),
        themeMode: themeMode,
        supportedLocales: supportedLocales,
        localizationsDelegates: localizationDelegates,
        debugShowCheckedModeBanner: false,
        home: const Scaffold(body: Center(child: CircularProgressIndicator())),
      ),
      error: (_, _) => MaterialApp(
        theme: AppTheme.light(),
        darkTheme: AppTheme.dark(),
        themeMode: themeMode,
        supportedLocales: supportedLocales,
        localizationsDelegates: localizationDelegates,
        debugShowCheckedModeBanner: false,
        home: const Scaffold(
          body: Center(child: Text('Errore durante il caricamento utente')),
        ),
      ),
    );
  }
}

/*
  TODO:
  - Inviare notifiche per partita imminente
  - Notifica ad ogni evento?
  - Implementare scelta giocatori convocati alla creazione di una partita con contatore presenze
  - Implementare scelta giocatori real amis per eventi e contatore relativo (goal, cartellini)
*/
