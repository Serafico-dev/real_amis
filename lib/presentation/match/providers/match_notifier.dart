import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';
import 'package:real_amis/data/sources/player/player_supabase_data_source.dart';
import 'package:real_amis/domain/entities/match/match_entity.dart';
import 'package:real_amis/domain/usecases/match/update_match.dart';
import 'package:real_amis/domain/usecases/match/upload_match.dart';
import 'package:real_amis/core/usecase/usecase.dart';
import 'package:real_amis/presentation/auth/providers/app_user_provider.dart';
import 'package:real_amis/presentation/auth/providers/app_user_state.dart';
import 'package:real_amis/presentation/match/providers/match_provider.dart';
import 'package:real_amis/presentation/player/providers/player_notifier.dart';

final matchNotifierProvider =
    StateNotifierProvider<MatchNotifier, AsyncValue<List<MatchEntity>>>(
      (ref) => MatchNotifier(ref),
    );

class MatchNotifier extends StateNotifier<AsyncValue<List<MatchEntity>>> {
  final Ref ref;

  MatchNotifier(this.ref) : super(const AsyncLoading());

  Future<void> fetchAllMatches() async {
    state = const AsyncLoading();
    final user = ref.read(appUserProvider).value?.user;
    if (user == null) {
      state = const AsyncData([]);
      return;
    }

    final res = await ref.read(getAllMatchesProvider)(NoParams());
    state = res.fold(
      (failure) => AsyncError(failure.message, StackTrace.current),
      (matches) => AsyncData(matches),
    );
  }

  Future<void> uploadMatch(UploadMatchParams params) async {
    state = const AsyncLoading();
    final res = await ref.read(uploadMatchProvider)(params);
    res.fold(
      (failure) => state = AsyncError(failure.message, StackTrace.current),
      (_) async => fetchAllMatches(),
    );
  }

  Future<void> updateMatch(UpdateMatchParams params) async {
    final res = await ref.read(updateMatchProvider)(params);
    res.fold(
      (failure) => state = AsyncError(failure.message, StackTrace.current),
      (updatedMatch) {
        final current = state.value ?? [];
        final updatedList = [
          for (final m in current)
            if (m.id == updatedMatch.id) updatedMatch else m,
        ];
        state = AsyncData(updatedList);
      },
    );
  }

  Future<void> deleteMatch(String matchId) async {
    state = const AsyncLoading();
    final res = await ref.read(deleteMatchProvider)(matchId);
    res.fold(
      (failure) => state = AsyncError(failure.message, StackTrace.current),
      (_) async => fetchAllMatches(),
    );
  }

  Future<void> markAsPlayed(MatchEntity match) async {
    if (match.calledUpIds.isEmpty) return;

    final playerDataSource = ref.read(playerSupabaseDataSourceProvider);

    await Future.wait(
      match.calledUpIds.map(
        (id) => playerDataSource.incrementPlayerStats(
          playerId: id,
          attendancesDelta: 1,
        ),
      ),
    );

    await ref.read(updateMatchProvider)(
      UpdateMatchParams(
        match: match,
        matchDate: match.matchDate,
        homeTeamId: match.homeTeamId,
        awayTeamId: match.awayTeamId,
        matchDay: match.matchDay,
        leagueId: match.leagueId!,
        calledUpIds: match.calledUpIds,
        played: true,
      ),
    );

    await Future.wait([
      fetchAllMatches(),
      ref.read(playerNotifierProvider.notifier).fetchAllPlayers(),
    ]);
  }
}
