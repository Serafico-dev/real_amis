import 'package:real_amis/domain/entities/league/league_entity.dart';
import 'package:real_amis/domain/entities/team/team_entity.dart';

class MatchEntity {
  final String id;
  final DateTime updatedAt;
  final DateTime matchDate;
  final String homeTeamId;
  final String awayTeamId;
  final int? homeTeamScore;
  final int? awayTeamScore;
  final String? matchDay;
  final TeamEntity? homeTeam;
  final TeamEntity? awayTeam;
  final String? leagueId;
  final LeagueEntity? league;

  MatchEntity({
    required this.id,
    required this.updatedAt,
    required this.matchDate,
    required this.homeTeamId,
    required this.awayTeamId,
    this.homeTeamScore,
    this.awayTeamScore,
    this.matchDay,
    this.homeTeam,
    this.awayTeam,
    this.leagueId,
    this.league,
  });

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is MatchEntity && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;
}
