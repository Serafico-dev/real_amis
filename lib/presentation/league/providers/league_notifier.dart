import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:real_amis/core/usecase/usecase.dart';
import 'package:real_amis/domain/entities/league/league_entity.dart';
import 'package:real_amis/domain/usecases/league/delete_league.dart';
import 'package:real_amis/domain/usecases/league/get_all_leagues.dart';
import 'package:real_amis/domain/usecases/league/update_league.dart';
import 'package:real_amis/domain/usecases/league/upload_league.dart';
import 'package:real_amis/presentation/league/providers/league_provider.dart';

final leagueNotifierProvider =
    AsyncNotifierProvider<LeagueNotifier, List<LeagueEntity>>(
      LeagueNotifier.new,
    );

class LeagueNotifier extends AsyncNotifier<List<LeagueEntity>> {
  late final GetAllLeagues _getAllLeagues;
  late final UploadLeague _uploadLeague;
  late final UpdateLeague _updateLeague;
  late final DeleteLeague _deleteLeague;

  @override
  FutureOr<List<LeagueEntity>> build() async {
    _getAllLeagues = ref.read(getAllLeaguesProvider);
    _uploadLeague = ref.read(uploadLeagueProvider);
    _updateLeague = ref.read(updateLeagueProvider);
    _deleteLeague = ref.read(deleteLeagueProvider);

    return _loadLeagues();
  }

  Future<List<LeagueEntity>> _loadLeagues() async {
    final result = await _getAllLeagues(NoParams());
    return result.fold((failure) => throw failure, (leagues) => leagues);
  }

  Future<void> fetchAllLeagues() async {
    state = const AsyncLoading();
    final result = await _getAllLeagues(NoParams());

    result.fold(
      (failure) => state = AsyncError(failure, StackTrace.current),
      (leagues) => state = AsyncData(leagues),
    );
  }

  Future<void> uploadLeague({
    required String name,
    required String year,
    required List<String> teamIds,
  }) async {
    final result = await _uploadLeague(
      UploadLeagueParams(name: name, year: year, teamIds: teamIds),
    );

    result.fold((failure) => state = AsyncError(failure, StackTrace.current), (
      league,
    ) {
      final current = state.value ?? [];
      state = AsyncData([...current, league]);
    });
  }

  Future<void> updateLeague({
    required LeagueEntity league,
    String? name,
    String? year,
    List<String>? teamIds,
  }) async {
    final result = await _updateLeague(
      UpdateLeagueParams(
        league: league,
        name: name,
        year: year,
        teamIds: teamIds,
      ),
    );

    result.fold((failure) => state = AsyncError(failure, StackTrace.current), (
      updated,
    ) {
      final current = state.value ?? [];
      final updatedList = [
        for (final l in current)
          if (l.id == updated.id) updated else l,
      ];
      state = AsyncData(updatedList);
    });
  }

  Future<void> deleteLeague(String leagueId) async {
    final result = await _deleteLeague(leagueId);

    result.fold((failure) => state = AsyncError(failure, StackTrace.current), (
      deleted,
    ) {
      final current = state.value ?? [];
      state = AsyncData(current.where((l) => l.id != deleted.id).toList());
    });
  }
}
