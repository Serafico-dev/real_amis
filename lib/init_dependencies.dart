import 'package:flutter/foundation.dart';
import 'package:flutter_localization/flutter_localization.dart';
import 'package:get_it/get_it.dart';
import 'package:hive/hive.dart';
import 'package:hydrated_bloc/hydrated_bloc.dart';
import 'package:internet_connection_checker_plus/internet_connection_checker_plus.dart';
import 'package:path_provider/path_provider.dart';
import 'package:real_amis/common/cubits/app_user/app_user_cubit.dart';
import 'package:real_amis/core/secrets/app_secrets.dart';
import 'package:real_amis/core/network/connection_checker.dart';
import 'package:real_amis/data/repositories/auth/auth_repository_impl.dart';
import 'package:real_amis/data/repositories/match/match_repository_impl.dart';
import 'package:real_amis/data/repositories/player/player_repository_impl.dart';
import 'package:real_amis/data/repositories/team/team_repository_impl.dart';
import 'package:real_amis/data/sources/auth/auth_supabase_data_source.dart';
import 'package:real_amis/data/sources/match/match_local_data_source.dart';
import 'package:real_amis/data/sources/match/match_supabase_data_source.dart';
import 'package:real_amis/data/sources/player/player_local_data_source.dart';
import 'package:real_amis/data/sources/player/player_supabase_data_source.dart';
import 'package:real_amis/data/sources/team/team_local_data_source.dart';
import 'package:real_amis/data/sources/team/team_supabase_data_source.dart';
import 'package:real_amis/domain/repositories/auth/auth_repository.dart';
import 'package:real_amis/domain/repositories/match/match_repository.dart';
import 'package:real_amis/domain/repositories/player/player_repository.dart';
import 'package:real_amis/domain/repositories/team/team_repository.dart';
import 'package:real_amis/domain/usecases/auth/current_user.dart';
import 'package:real_amis/domain/usecases/auth/password_reset.dart';
import 'package:real_amis/domain/usecases/auth/password_reset_complete.dart';
import 'package:real_amis/domain/usecases/auth/user_login.dart';
import 'package:real_amis/domain/usecases/auth/user_logout.dart';
import 'package:real_amis/domain/usecases/auth/user_sign_up.dart';
import 'package:real_amis/domain/usecases/match/delete_match.dart';
import 'package:real_amis/domain/usecases/match/get_all_matches.dart';
import 'package:real_amis/domain/usecases/match/update_match.dart';
import 'package:real_amis/domain/usecases/match/upload_match.dart';
import 'package:real_amis/domain/usecases/player/delete_player.dart';
import 'package:real_amis/domain/usecases/player/get_all_players.dart';
import 'package:real_amis/domain/usecases/player/update_player.dart';
import 'package:real_amis/domain/usecases/player/upload_player.dart';
import 'package:real_amis/domain/usecases/team/delete_team.dart';
import 'package:real_amis/domain/usecases/team/get_all_teams.dart';
import 'package:real_amis/domain/usecases/team/update_team.dart';
import 'package:real_amis/domain/usecases/team/upload_team.dart';
import 'package:real_amis/presentation/auth/bloc/auth_bloc.dart';
import 'package:real_amis/presentation/choose_mode/bloc/theme_cubit.dart';
import 'package:real_amis/presentation/match/bloc/match_bloc.dart';
import 'package:real_amis/presentation/player/bloc/player_bloc.dart';
import 'package:real_amis/presentation/team/bloc/team_bloc.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

final serviceLocator = GetIt.instance;
final FlutterLocalization localization = FlutterLocalization.instance;

Future<void> initDependencies() async {
  _initAuth();
  _initPlayer();
  _initMatch();
  _initTeam();

  final supabase = await Supabase.initialize(
    url: AppSecrets.url,
    anonKey: AppSecrets.anonKey,
  );

  HydratedBloc.storage = await HydratedStorage.build(
    storageDirectory: kIsWeb
        ? HydratedStorageDirectory.web
        : HydratedStorageDirectory((await getTemporaryDirectory()).path),
  );

  Hive.defaultDirectory = (await getApplicationDocumentsDirectory()).path;

  serviceLocator.registerLazySingleton(() => supabase.client);
  serviceLocator.registerLazySingleton(() => Hive.box(name: 'localStorage'));
  serviceLocator.registerFactory(() => InternetConnection());

  // core
  serviceLocator.registerLazySingleton(() => AppUserCubit());
  serviceLocator.registerLazySingleton(() => ThemeCubit());
  serviceLocator.registerFactory<ConnectionChecker>(
    () => ConnectionCheckerImpl(serviceLocator()),
  );
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
  serviceLocator.registerFactory(() => CurrentUser(serviceLocator()));
  serviceLocator.registerFactory(() => UserLogout(serviceLocator()));
  serviceLocator.registerFactory(() => PasswordReset(serviceLocator()));
  serviceLocator.registerFactory(() => PasswordResetComplete(serviceLocator()));
  // Bloc
  serviceLocator.registerLazySingleton(
    () => AuthBloc(
      userSignUp: serviceLocator(),
      userLogin: serviceLocator(),
      currentUser: serviceLocator(),
      userLogout: serviceLocator(),
      passwordReset: serviceLocator(),
      passwordResetComplete: serviceLocator(),
      appUserCubit: serviceLocator(),
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
  serviceLocator.registerFactory(() => UploadPlayer(serviceLocator()));
  serviceLocator.registerFactory(() => GetAllPlayers(serviceLocator()));
  serviceLocator.registerFactory(() => UpdatePlayer(serviceLocator()));
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
