part of 'score_bloc.dart';

@immutable
sealed class ScoreEvent {}

final class ScoreUpload extends ScoreEvent {
  final String leagueId;
  final String teamId;
  final int score;

  ScoreUpload({
    required this.leagueId,
    required this.teamId,
    required this.score,
  });
}

final class ScoreFetchAllScores extends ScoreEvent {}

final class ScoreUpdate extends ScoreEvent {
  final ScoreEntity scoreEntity;
  final String? leagueId;
  final String? teamId;
  final int? score;

  ScoreUpdate({
    required this.scoreEntity,
    this.leagueId,
    this.teamId,
    this.score,
  });
}

final class ScoreDelete extends ScoreEvent {
  final String scoreId;
  ScoreDelete({required this.scoreId});
}
