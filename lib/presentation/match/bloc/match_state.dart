part of 'match_bloc.dart';

@immutable
sealed class MatchState {}

final class MatchInitial extends MatchState {}

final class MatchLoading extends MatchState {}

final class MatchFailure extends MatchState {
  final String error;
  MatchFailure(this.error);
}

final class MatchUploadSuccess extends MatchState {}

final class MatchDisplaySuccess extends MatchState {
  final List<MatchEntity> matches;
  MatchDisplaySuccess(this.matches);
}

final class MatchUpdateSuccess extends MatchState {
  final MatchEntity updatedMatch;
  MatchUpdateSuccess(this.updatedMatch);
}

final class MatchDeleteSuccess extends MatchState {}
