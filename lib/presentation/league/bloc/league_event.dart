part of 'league_bloc.dart';

@immutable
sealed class LeagueEvent {}

final class LeagueUpload extends LeagueEvent {
  final String name;
  final String year;

  LeagueUpload({required this.name, required this.year});
}

final class LeagueFetchAllLeagues extends LeagueEvent {}

final class LeagueUpdate extends LeagueEvent {
  final LeagueEntity league;
  final String? name;
  final String? year;

  LeagueUpdate({required this.league, this.name, this.year});
}

final class LeagueDelete extends LeagueEvent {
  final String leagueId;
  LeagueDelete({required this.leagueId});
}
