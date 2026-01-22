part of 'league_bloc.dart';

@immutable
sealed class LeagueState {}

final class LeagueInitial extends LeagueState {}

final class LeagueLoading extends LeagueState {}

final class LeagueFailure extends LeagueState {
  final String error;
  LeagueFailure(this.error);
}

final class LeagueUploadSuccess extends LeagueState {}

final class LeagueDisplaySuccess extends LeagueState {
  final List<LeagueEntity> leagues;
  LeagueDisplaySuccess(this.leagues);
}

final class LeagueUpdateSuccess extends LeagueState {
  final LeagueEntity updatedLeague;
  LeagueUpdateSuccess(this.updatedLeague);
}

final class LeagueDeleteSuccess extends LeagueState {}
