import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:real_amis/domain/entities/score/score_entity.dart';
import 'package:real_amis/domain/usecases/score/get_all_scores.dart';
import 'package:real_amis/domain/usecases/score/get_scores_by_league.dart';
import 'package:real_amis/domain/usecases/score/upload_score.dart';
import 'package:real_amis/domain/usecases/score/update_score.dart';
import 'package:real_amis/core/usecase/usecase.dart';
import 'package:real_amis/presentation/score/providers/score_provider.dart';

final scoreNotifierProvider =
    AsyncNotifierProvider<ScoreNotifier, List<ScoreEntity>>(
      () => ScoreNotifier(),
    );

class ScoreNotifier extends AsyncNotifier<List<ScoreEntity>> {
  late GetAllScores _getAllScores;
  late GetScoresByLeague _getScoresByLeague;
  late UploadScore _uploadScore;
  late UpdateScore _updateScore;

  @override
  FutureOr<List<ScoreEntity>> build() async {
    _getAllScores = ref.read(getAllScoresProvider);
    _getScoresByLeague = ref.read(getScoresByLeagueProvider);
    _uploadScore = ref.read(uploadScoreProvider);
    _updateScore = ref.read(updateScoreProvider);

    return fetchAllScores();
  }

  Future<List<ScoreEntity>> fetchAllScores() async {
    final res = await _getAllScores(NoParams());
    final data = res.fold((l) => throw Exception(l.message), (r) => r);
    state = AsyncData(data);
    return data;
  }

  Future<void> fetchScoresByLeague(String leagueId) async {
    state = const AsyncLoading();
    final res = await _getScoresByLeague(
      GetScoresByLeagueParams(leagueId: leagueId),
    );
    state = res.fold(
      (l) => AsyncError(l.message, StackTrace.current),
      (r) => AsyncData(r),
    );
  }

  Future<void> uploadScore(ScoreEntity score) async {
    state = const AsyncLoading();
    final res = await _uploadScore(
      UploadScoreParams(
        leagueId: score.leagueId,
        teamId: score.teamId,
        score: score.score,
      ),
    );
    state = res.fold(
      (l) => AsyncError(l.message, StackTrace.current),
      (_) => AsyncData([...?state.value, score]),
    );
  }

  Future<void> updateScore(ScoreEntity score) async {
    state = const AsyncLoading();
    final res = await _updateScore(
      UpdateScoreParams(
        scoreEntity: score,
        leagueId: score.leagueId,
        teamId: score.teamId,
        score: score.score,
      ),
    );
    state = res.fold((l) => AsyncError(l.message, StackTrace.current), (_) {
      final current = state.value ?? [];
      final updatedList = [
        for (final s in current)
          if (s.id == score.id) score else s,
      ];
      return AsyncData(updatedList);
    });
  }
}
