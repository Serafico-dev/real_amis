part of 'match_bloc.dart';

@immutable
sealed class MatchEvent {}

final class MatchUpload extends MatchEvent {
  final DateTime matchDate;
  final String homeTeamId;
  final String awayTeamId;
  final int? homeTeamScore;
  final int? awayTeamScore;
  final String? matchDay;
  final TeamEntity? homeTeam;
  final TeamEntity? awayTeam;

  MatchUpload({
    required this.matchDate,
    required this.homeTeamId,
    required this.awayTeamId,
    this.homeTeamScore,
    this.awayTeamScore,
    this.matchDay,
    this.homeTeam,
    this.awayTeam,
  });
}

final class MatchFetchAllMatches extends MatchEvent {}

final class MatchUpdate extends MatchEvent {
  final MatchEntity match;
  final DateTime? matchDate;
  final String? homeTeamId;
  final String? awayTeamId;
  final int? homeTeamScore;
  final int? awayTeamScore;
  final String? matchDay;

  MatchUpdate({
    required this.match,
    this.matchDate,
    this.homeTeamId,
    this.awayTeamId,
    this.homeTeamScore,
    this.awayTeamScore,
    this.matchDay,
  });
}

final class MatchDelete extends MatchEvent {
  final String matchId;
  MatchDelete({required this.matchId});
}
