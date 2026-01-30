import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:real_amis/data/repositories/score/score_repository_impl.dart';
import 'package:real_amis/domain/usecases/score/delete_score.dart';
import 'package:real_amis/domain/usecases/score/get_all_scores.dart';
import 'package:real_amis/domain/usecases/score/get_scores_by_league.dart';
import 'package:real_amis/domain/usecases/score/update_score.dart';
import 'package:real_amis/domain/usecases/score/upload_score.dart';

final getAllScoresProvider = Provider<GetAllScores>((ref) {
  return GetAllScores(ref.read(scoreRepositoryProvider));
});

final getScoresByLeagueProvider = Provider<GetScoresByLeague>((ref) {
  return GetScoresByLeague(ref.read(scoreRepositoryProvider));
});

final uploadScoreProvider = Provider<UploadScore>((ref) {
  return UploadScore(ref.read(scoreRepositoryProvider));
});

final updateScoreProvider = Provider<UpdateScore>((ref) {
  return UpdateScore(ref.read(scoreRepositoryProvider));
});

final deleteScoreProvider = Provider<DeleteScore>((ref) {
  return DeleteScore(ref.read(scoreRepositoryProvider));
});
