import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:real_amis/data/repositories/leagues/league_repository_impl.dart';
import 'package:real_amis/domain/usecases/league/delete_league.dart';
import 'package:real_amis/domain/usecases/league/get_all_leagues.dart';
import 'package:real_amis/domain/usecases/league/update_league.dart';
import 'package:real_amis/domain/usecases/league/upload_league.dart';

final getAllLeaguesProvider = Provider<GetAllLeagues>((ref) {
  return GetAllLeagues(ref.read(leagueRepositoryProvider));
});

final uploadLeagueProvider = Provider<UploadLeague>((ref) {
  return UploadLeague(ref.read(leagueRepositoryProvider));
});

final updateLeagueProvider = Provider<UpdateLeague>((ref) {
  return UpdateLeague(ref.read(leagueRepositoryProvider));
});

final deleteLeagueProvider = Provider<DeleteLeague>((ref) {
  return DeleteLeague(ref.read(leagueRepositoryProvider));
});
