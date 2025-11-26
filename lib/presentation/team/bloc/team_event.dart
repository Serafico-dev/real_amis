part of 'team_bloc.dart';

@immutable
sealed class TeamEvent {}

final class TeamUpload extends TeamEvent {
  final String name;
  final File image;

  TeamUpload({required this.name, required this.image});
}

final class TeamFetchAllTeams extends TeamEvent {}

final class TeamUpdate extends TeamEvent {
  final TeamEntity team;
  final String? name;
  final File? image;

  TeamUpdate({required this.team, this.name, this.image});
}

final class TeamDelete extends TeamEvent {
  final String teamId;
  TeamDelete({required this.teamId});
}
