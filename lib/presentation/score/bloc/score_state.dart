part of 'score_bloc.dart';

@immutable
sealed class ScoreState {}

final class ScoreInitial extends ScoreState {}

final class ScoreLoading extends ScoreState {}

final class ScoreFailure extends ScoreState {
  final String error;
  ScoreFailure(this.error);
}

final class ScoreUploadSuccess extends ScoreState {}

final class ScoreDisplaySuccess extends ScoreState {
  final List<ScoreEntity> scores;
  ScoreDisplaySuccess(this.scores);
}

final class ScoreUpdateSuccess extends ScoreState {
  final ScoreEntity updatedScore;
  ScoreUpdateSuccess(this.updatedScore);
}

final class ScoreDeleteSuccess extends ScoreState {}
