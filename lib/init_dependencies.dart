import 'package:flutter/foundation.dart';
import 'package:flutter_localization/flutter_localization.dart';
import 'package:get_it/get_it.dart';
import 'package:hive/hive.dart';
import 'package:hydrated_bloc/hydrated_bloc.dart';
import 'package:internet_connection_checker_plus/internet_connection_checker_plus.dart';
import 'package:path_provider/path_provider.dart';
import 'package:real_amis/core/cubits/app_user/app_user_cubit.dart';
import 'package:real_amis/core/auth/auth_session_listener.dart';
import 'package:real_amis/core/notifications/birthday_notification_service.dart';
import 'package:real_amis/core/secrets/app_secrets.dart';
import 'package:real_amis/core/network/connection_checker.dart';
import 'package:real_amis/core/utils/secure_storage.dart';
import 'package:real_amis/data/repositories/auth/auth_repository_impl.dart';
import 'package:real_amis/data/repositories/event/event_repository_impl.dart';
import 'package:real_amis/data/repositories/leagues/league_repository_impl.dart';
import 'package:real_amis/data/repositories/match/match_repository_impl.dart';
import 'package:real_amis/data/repositories/player/player_repository_impl.dart';
import 'package:real_amis/data/repositories/score/score_repository_impl.dart';
import 'package:real_amis/data/repositories/team/team_repository_impl.dart';
import 'package:real_amis/data/sources/auth/auth_supabase_data_source.dart';
import 'package:real_amis/data/sources/event/event_local_data_source.dart';
import 'package:real_amis/data/sources/event/event_supabase_data_source.dart';
import 'package:real_amis/data/sources/league/league_local_data_source.dart';
import 'package:real_amis/data/sources/league/league_supabase_data_source.dart';
import 'package:real_amis/data/sources/match/match_local_data_source.dart';
import 'package:real_amis/data/sources/match/match_supabase_data_source.dart';
import 'package:real_amis/data/sources/player/player_local_data_source.dart';
import 'package:real_amis/data/sources/player/player_supabase_data_source.dart';
import 'package:real_amis/data/sources/score/score_local_data_source.dart';
import 'package:real_amis/data/sources/score/score_supabase_data_source.dart';
import 'package:real_amis/data/sources/team/team_local_data_source.dart';
import 'package:real_amis/data/sources/team/team_supabase_data_source.dart';
import 'package:real_amis/domain/repositories/auth/auth_repository.dart';
import 'package:real_amis/domain/repositories/event/event_repository.dart';
import 'package:real_amis/domain/repositories/league/league_repository.dart';
import 'package:real_amis/domain/repositories/match/match_repository.dart';
import 'package:real_amis/domain/repositories/player/player_repository.dart';
import 'package:real_amis/domain/repositories/score/score_repository.dart';
import 'package:real_amis/domain/repositories/team/team_repository.dart';
import 'package:real_amis/domain/usecases/auth/change_password.dart';
import 'package:real_amis/domain/usecases/auth/password_reset.dart';
import 'package:real_amis/domain/usecases/auth/password_reset_complete.dart';
import 'package:real_amis/domain/usecases/auth/user_delete.dart';
import 'package:real_amis/domain/usecases/auth/user_login.dart';
import 'package:real_amis/domain/usecases/auth/user_logout.dart';
import 'package:real_amis/domain/usecases/auth/user_sign_up.dart';
import 'package:real_amis/domain/usecases/event/delete_event.dart';
import 'package:real_amis/domain/usecases/event/get_all_events.dart';
import 'package:real_amis/domain/usecases/event/get_events_by_match.dart';
import 'package:real_amis/domain/usecases/event/update_event.dart';
import 'package:real_amis/domain/usecases/event/upload_event.dart';
import 'package:real_amis/domain/usecases/league/delete_league.dart';
import 'package:real_amis/domain/usecases/league/get_all_leagues.dart';
import 'package:real_amis/domain/usecases/league/update_league.dart';
import 'package:real_amis/domain/usecases/league/upload_league.dart';
import 'package:real_amis/domain/usecases/match/delete_match.dart';
import 'package:real_amis/domain/usecases/match/get_all_matches.dart';
import 'package:real_amis/domain/usecases/match/update_match.dart';
import 'package:real_amis/domain/usecases/match/upload_match.dart';
import 'package:real_amis/domain/usecases/player/delete_player.dart';
import 'package:real_amis/domain/usecases/player/get_all_players.dart';
import 'package:real_amis/domain/usecases/player/update_player.dart';
import 'package:real_amis/domain/usecases/player/upload_player.dart';
import 'package:real_amis/domain/usecases/score/delete_score.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/data/latest_all.dart' as tz;
import 'package:timezone/timezone.dart' as tz;
import 'package:real_amis/domain/usecases/score/get_all_scores.dart';
import 'package:real_amis/domain/usecases/score/get_scores_by_league.dart';
import 'package:real_amis/domain/usecases/score/update_score.dart';
import 'package:real_amis/domain/usecases/score/upload_score.dart';
import 'package:real_amis/domain/usecases/team/delete_team.dart';
import 'package:real_amis/domain/usecases/team/get_all_teams.dart';
import 'package:real_amis/domain/usecases/team/update_team.dart';
import 'package:real_amis/domain/usecases/team/upload_team.dart';
import 'package:real_amis/presentation/auth/bloc/auth_bloc.dart';
import 'package:real_amis/presentation/choose_mode/bloc/theme_cubit.dart';
import 'package:real_amis/presentation/event/bloc/event_bloc.dart';
import 'package:real_amis/presentation/league/bloc/league_bloc.dart';
import 'package:real_amis/presentation/match/bloc/match_bloc.dart';
import 'package:real_amis/presentation/player/bloc/player_bloc.dart';
import 'package:real_amis/presentation/score/bloc/score_bloc.dart';
import 'package:real_amis/presentation/team/bloc/team_bloc.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

final serviceLocator = GetIt.instance;
final FlutterLocalization localization = FlutterLocalization.instance;

final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
    FlutterLocalNotificationsPlugin();

Future<void> initDependencies() async {
  Hive.defaultDirectory = (await getApplicationDocumentsDirectory()).path;

  await initNotifications();

  final supabase = await Supabase.initialize(
    url: AppSecrets.url,
    anonKey: AppSecrets.anonKey,
  );
  serviceLocator.registerLazySingleton(() => supabase.client);

  HydratedBloc.storage = await HydratedStorage.build(
    storageDirectory: kIsWeb
        ? HydratedStorageDirectory.web
        : HydratedStorageDirectory((await getTemporaryDirectory()).path),
  );

  serviceLocator.registerLazySingleton(() => Hive.box(name: 'localStorage'));
  serviceLocator.registerFactory(() => InternetConnection());

  final secureStorage = SecureStorage();
  serviceLocator.registerLazySingleton<SecureStorage>(() => secureStorage);

  // core
  serviceLocator.registerLazySingleton(
    () => AppUserCubit(serviceLocator<AuthSupabaseDataSource>()),
  );

  serviceLocator.registerLazySingleton(() => ThemeCubit());

  serviceLocator.registerLazySingleton(
    () => AuthSessionListener(
      supabase: serviceLocator<SupabaseClient>(),
      appUserCubit: serviceLocator<AppUserCubit>(),
    ),
  );

  serviceLocator.registerFactory<ConnectionChecker>(
    () => ConnectionCheckerImpl(serviceLocator()),
  );

  _initAuth();
  _initEvent();
  _initLeague();
  _initMatch();
  _initPlayer();
  _initScore();
  _initTeam();

  serviceLocator<AuthSessionListener>().start();
}

void _initAuth() {
  // Datasource
  serviceLocator.registerFactory<AuthSupabaseDataSource>(
    () => AuthSupabaseDataSourceImpl(serviceLocator()),
  );
  // Repository
  serviceLocator.registerFactory<AuthRepository>(
    () => AuthRepositoryImpl(serviceLocator(), serviceLocator()),
  );
  // Usecases
  serviceLocator.registerFactory(() => UserSignUp(serviceLocator()));
  serviceLocator.registerFactory(() => UserLogin(serviceLocator()));
  serviceLocator.registerFactory(() => UserLogout(serviceLocator()));
  serviceLocator.registerFactory(() => PasswordReset(serviceLocator()));
  serviceLocator.registerFactory(() => PasswordResetComplete(serviceLocator()));
  serviceLocator.registerFactory(() => ChangePassword(serviceLocator()));
  serviceLocator.registerFactory(() => UserDelete(serviceLocator()));
  // Bloc
  serviceLocator.registerLazySingleton(
    () => AuthBloc(
      userSignUp: serviceLocator(),
      userLogin: serviceLocator(),
      userLogout: serviceLocator(),
      passwordReset: serviceLocator(),
      passwordResetComplete: serviceLocator(),
      changePassword: serviceLocator(),
      userDelete: serviceLocator(),
      appUserCubit: serviceLocator(),
    ),
  );
}

Future<void> initNotifications() async {
  tz.initializeTimeZones();
  tz.setLocalLocation(tz.getLocation('Europe/Rome'));

  const androidSettings = AndroidInitializationSettings('@mipmap/ic_launcher');
  const iosSettings = DarwinInitializationSettings();
  const settings = InitializationSettings(
    android: androidSettings,
    iOS: iosSettings,
  );

  await flutterLocalNotificationsPlugin.initialize(settings);

  final birthdayService = BirthdayNotificationService(
    flutterLocalNotificationsPlugin,
  );
  await birthdayService.init();

  serviceLocator.registerLazySingleton<BirthdayNotificationService>(
    () => birthdayService,
  );
}

void _initEvent() {
  // Datasource
  serviceLocator.registerFactory<EventSupabaseDataSource>(
    () => EventSupabaseDataSourceImpl(serviceLocator()),
  );
  serviceLocator.registerFactory<EventLocalDataSource>(
    () => EventLocalDataSourceImpl(serviceLocator()),
  );
  // Repository
  serviceLocator.registerFactory<EventRepository>(
    () => EventRepositoryImpl(
      serviceLocator(),
      serviceLocator(),
      serviceLocator(),
    ),
  );
  // Usecases
  serviceLocator.registerFactory(() => UploadEvent(serviceLocator()));
  serviceLocator.registerFactory(() => GetAllEvents(serviceLocator()));
  serviceLocator.registerFactory(() => GetEventsByMatch(serviceLocator()));
  serviceLocator.registerFactory(() => UpdateEvent(serviceLocator()));
  serviceLocator.registerFactory(() => DeleteEvent(serviceLocator()));

  // Bloc
  serviceLocator.registerLazySingleton(
    () => EventBloc(
      uploadEvent: serviceLocator(),
      getAllEvents: serviceLocator(),
      getEventsByMatch: serviceLocator(),
      updateEvent: serviceLocator(),
      deleteEvent: serviceLocator(),
    ),
  );
}

void _initLeague() {
  // Datasource
  serviceLocator.registerFactory<LeagueSupabaseDataSource>(
    () => LeagueSupabaseDataSourceImpl(serviceLocator()),
  );
  serviceLocator.registerFactory<LeagueLocalDataSource>(
    () => LeagueLocalDataSourceImpl(serviceLocator()),
  );
  // Repository
  serviceLocator.registerFactory<LeagueRepository>(
    () => LeagueRepositoryImpl(
      serviceLocator(),
      serviceLocator(),
      serviceLocator(),
    ),
  );
  // Usecases
  serviceLocator.registerFactory(() => UploadLeague(serviceLocator()));
  serviceLocator.registerFactory(() => GetAllLeagues(serviceLocator()));
  serviceLocator.registerFactory(() => UpdateLeague(serviceLocator()));
  serviceLocator.registerFactory(() => DeleteLeague(serviceLocator()));

  // Bloc
  serviceLocator.registerLazySingleton(
    () => LeagueBloc(
      uploadLeague: serviceLocator(),
      getAllLeagues: serviceLocator(),
      updateLeague: serviceLocator(),
      deleteLeague: serviceLocator(),
    ),
  );
}

void _initMatch() {
  // Datasource
  serviceLocator.registerFactory<MatchSupabaseDataSource>(
    () => MatchSupabaseDataSourceImpl(serviceLocator()),
  );
  serviceLocator.registerFactory<MatchLocalDataSource>(
    () => MatchLocalDataSourceImpl(serviceLocator()),
  );
  // Repository
  serviceLocator.registerFactory<MatchRepository>(
    () => MatchRepositoryImpl(
      serviceLocator(),
      serviceLocator(),
      serviceLocator(),
    ),
  );
  // Usecases
  serviceLocator.registerFactory(() => UploadMatch(serviceLocator()));
  serviceLocator.registerFactory(() => GetAllMatches(serviceLocator()));
  serviceLocator.registerFactory(() => UpdateMatch(serviceLocator()));
  serviceLocator.registerFactory(() => DeleteMatch(serviceLocator()));

  // Bloc
  serviceLocator.registerLazySingleton(
    () => MatchBloc(
      uploadMatch: serviceLocator(),
      getAllMatches: serviceLocator(),
      updateMatch: serviceLocator(),
      deleteMatch: serviceLocator(),
    ),
  );
}

void _initPlayer() {
  // Datasource
  serviceLocator.registerFactory<PlayerSupabaseDataSource>(
    () => PlayerSupabaseDataSourceImpl(serviceLocator()),
  );
  serviceLocator.registerFactory<PlayerLocalDataSource>(
    () => PlayerLocalDataSourceImpl(serviceLocator()),
  );
  // Repository
  serviceLocator.registerFactory<PlayerRepository>(
    () => PlayerRepositoryImpl(
      serviceLocator(),
      serviceLocator(),
      serviceLocator(),
    ),
  );
  // Usecases
  serviceLocator.registerFactory(
    () => UploadPlayer(
      serviceLocator(),
      serviceLocator<BirthdayNotificationService>(),
    ),
  );
  serviceLocator.registerFactory(() => GetAllPlayers(serviceLocator()));
  serviceLocator.registerFactory(
    () => UpdatePlayer(
      serviceLocator(),
      serviceLocator<BirthdayNotificationService>(),
    ),
  );
  serviceLocator.registerFactory(() => DeletePlayer(serviceLocator()));

  // Bloc
  serviceLocator.registerLazySingleton(
    () => PlayerBloc(
      uploadPlayer: serviceLocator(),
      getAllPlayers: serviceLocator(),
      updatePlayer: serviceLocator(),
      deletePlayer: serviceLocator(),
    ),
  );
}

void _initScore() {
  // Datasource
  serviceLocator.registerFactory<ScoreSupabaseDataSource>(
    () => ScoreSupabaseDataSourceImpl(serviceLocator()),
  );
  serviceLocator.registerFactory<ScoreLocalDataSource>(
    () => ScoreLocalDataSourceImpl(serviceLocator()),
  );
  // Repository
  serviceLocator.registerFactory<ScoreRepository>(
    () => ScoreRepositoryImpl(
      serviceLocator(),
      serviceLocator(),
      serviceLocator(),
    ),
  );
  // Usecases
  serviceLocator.registerFactory(() => UploadScore(serviceLocator()));
  serviceLocator.registerFactory(() => GetAllScores(serviceLocator()));
  serviceLocator.registerFactory(() => GetScoresByLeague(serviceLocator()));
  serviceLocator.registerFactory(() => UpdateScore(serviceLocator()));
  serviceLocator.registerFactory(() => DeleteScore(serviceLocator()));

  // Bloc
  serviceLocator.registerLazySingleton(
    () => ScoreBloc(
      uploadScore: serviceLocator(),
      getAllScores: serviceLocator(),
      getScoresByLeague: serviceLocator(),
      updateScore: serviceLocator(),
      deleteScore: serviceLocator(),
    ),
  );
}

void _initTeam() {
  // Datasource
  serviceLocator.registerFactory<TeamSupabaseDataSource>(
    () => TeamSupabaseDataSourceImpl(serviceLocator()),
  );
  serviceLocator.registerFactory<TeamLocalDataSource>(
    () => TeamLocalDataSourceImpl(serviceLocator()),
  );
  // Repository
  serviceLocator.registerFactory<TeamRepository>(
    () => TeamRepositoryImpl(
      serviceLocator(),
      serviceLocator(),
      serviceLocator(),
    ),
  );
  // Usecases
  serviceLocator.registerFactory(() => UploadTeam(serviceLocator()));
  serviceLocator.registerFactory(() => GetAllTeams(serviceLocator()));
  serviceLocator.registerFactory(() => UpdateTeam(serviceLocator()));
  serviceLocator.registerFactory(() => DeleteTeam(serviceLocator()));

  // Bloc
  serviceLocator.registerLazySingleton(
    () => TeamBloc(
      uploadTeam: serviceLocator(),
      getAllTeams: serviceLocator(),
      updateTeam: serviceLocator(),
      deleteTeam: serviceLocator(),
    ),
  );
}
