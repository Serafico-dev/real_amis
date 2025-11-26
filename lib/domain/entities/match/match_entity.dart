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
  });
}
