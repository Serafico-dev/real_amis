part of 'team_bloc.dart';

@immutable
sealed class TeamState {}

final class TeamInitial extends TeamState {}

final class TeamLoading extends TeamState {}

final class TeamFailure extends TeamState {
  final String error;
  TeamFailure(this.error);
}

final class TeamUploadSuccess extends TeamState {}

final class TeamDisplaySuccess extends TeamState {
  final List<TeamEntity> teams;
  TeamDisplaySuccess(this.teams);
}

final class TeamUpdateSuccess extends TeamState {
  final TeamEntity updatedTeam;
  TeamUpdateSuccess(this.updatedTeam);
}

final class TeamDeleteSuccess extends TeamState {}
