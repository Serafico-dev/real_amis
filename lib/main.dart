import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_localization/flutter_localization.dart';
import 'package:real_amis/common/cubits/app_user/app_user_cubit.dart';
import 'package:real_amis/core/configs/locale/local_language.dart';
import 'package:real_amis/core/configs/theme/app_theme.dart';
import 'package:real_amis/init_dependencies.dart';
import 'package:real_amis/presentation/auth/bloc/auth_bloc.dart';
import 'package:real_amis/presentation/choose_mode/bloc/theme_cubit.dart';
import 'package:real_amis/presentation/event/bloc/event_bloc.dart';
import 'package:real_amis/presentation/match/bloc/match_bloc.dart';
import 'package:real_amis/presentation/player/bloc/player_bloc.dart';
import 'package:real_amis/presentation/splash/pages/splash.dart';
import 'package:real_amis/presentation/splash/pages/splash_logged_in.dart';
import 'package:real_amis/presentation/team/bloc/team_bloc.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await FlutterLocalization.instance.ensureInitialized();
  await initDependencies();

  runApp(
    MultiBlocProvider(
      providers: [
        BlocProvider(create: (_) => serviceLocator<ThemeCubit>()),
        BlocProvider(create: (_) => serviceLocator<AppUserCubit>()),
        BlocProvider(create: (_) => serviceLocator<AuthBloc>()),
        BlocProvider(create: (_) => serviceLocator<PlayerBloc>()),
        BlocProvider(create: (_) => serviceLocator<MatchBloc>()),
        BlocProvider(create: (_) => serviceLocator<TeamBloc>()),
        BlocProvider(create: (_) => serviceLocator<EventBloc>()),
      ],
      child: MainApp(),
    ),
  );
}

class MainApp extends StatefulWidget {
  const MainApp({super.key});

  static MaterialPageRoute route() =>
      MaterialPageRoute(builder: (context) => const MainApp());

  @override
  State<MainApp> createState() => _MainAppState();
}

class _MainAppState extends State<MainApp> {
  @override
  void initState() {
    super.initState();
    localization.init(
      mapLocales: [
        const MapLocale('en', AppLocale.english),
        const MapLocale('it', AppLocale.italian),
      ],
      initLanguageCode: 'it',
    );
    localization.onTranslatedLanguage = _onTranslatedLanguage;
    context.read<AuthBloc>().add(AuthIsUserLoggedIn());
  }

  @override
  void dispose() {
    localization.onTranslatedLanguage = null;
    super.dispose();
  }

  void _onTranslatedLanguage(Locale? locale) {
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ThemeCubit, ThemeMode>(
      builder: (context, mode) => MaterialApp(
        theme: AppTheme.lightTheme,
        darkTheme: AppTheme.darkTheme,
        themeMode: mode,
        supportedLocales: localization.supportedLocales,
        localizationsDelegates: localization.localizationsDelegates,
        debugShowCheckedModeBanner: false,
        home: BlocSelector<AppUserCubit, AppUserState, bool>(
          selector: (state) {
            return state is AppUserLoggedIn;
          },
          builder: (context, isLoggedIn) {
            if (isLoggedIn) {
              return SplashLoggedInPage();
            }
            return const SplashPage();
          },
        ),
      ),
    );
  }
}

/*
To Do:
- Gestire meglio eliminazione squadre (problema quando sono in match già creati)
- Refactor generale (mancano le cartelle: event, history, main, match, player e team)
- Aggiornare design
*/
