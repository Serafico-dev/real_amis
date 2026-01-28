import 'package:real_amis/data/models/league/league_model.dart';
import 'package:real_amis/data/models/team/team_model.dart';
import 'package:real_amis/domain/entities/match/match_entity.dart';
import 'package:real_amis/domain/entities/league/league_entity.dart';

class MatchModel extends MatchEntity {
  MatchModel({
    required super.id,
    required super.updatedAt,
    required super.matchDate,
    required super.homeTeamId,
    required super.awayTeamId,
    super.matchDay,
    super.homeTeam,
    super.awayTeam,
    required super.leagueId,
    super.league,
  });

  Map<String, dynamic> toJson() {
    return <String, dynamic>{
      'id': id,
      'updated_at': updatedAt.toIso8601String(),
      'match_date': matchDate.toIso8601String(),
      'home_team_id': homeTeamId,
      'away_team_id': awayTeamId,
      'match_day': matchDay ?? '',
      'league_id': leagueId,
    };
  }

  factory MatchModel.fromJson(Map<String, dynamic> map) {
    return MatchModel(
      id: map['id'] as String? ?? '',
      updatedAt: map['updated_at'] != null
          ? DateTime.tryParse(map['updated_at'].toString()) ?? DateTime.now()
          : DateTime.now(),
      matchDate: map['match_date'] != null
          ? DateTime.tryParse(map['match_date'].toString()) ?? DateTime.now()
          : DateTime.now(),
      homeTeamId: map['home_team_id'] as String? ?? '',
      awayTeamId: map['away_team_id'] as String? ?? '',
      matchDay: map['match_day']?.toString() ?? '',
      homeTeam: map['home_team'] != null
          ? TeamModel.fromJson(map['home_team'] as Map<String, dynamic>)
          : null,
      awayTeam: map['away_team'] != null
          ? TeamModel.fromJson(map['away_team'] as Map<String, dynamic>)
          : null,

      leagueId: map['league_id'] as String? ?? '',
      league: map['League'] != null
          ? LeagueModel.fromJson(map['League'] as Map<String, dynamic>)
          : null,
    );
  }

  MatchModel copyWith({
    String? id,
    DateTime? updatedAt,
    DateTime? matchDate,
    String? homeTeamId,
    String? awayTeamId,
    String? matchDay,
    TeamModel? homeTeam,
    TeamModel? awayTeam,
    String? leagueId,
    LeagueEntity? league,
  }) {
    return MatchModel(
      id: id ?? this.id,
      updatedAt: updatedAt ?? this.updatedAt,
      matchDate: matchDate ?? this.matchDate,
      homeTeamId: homeTeamId ?? this.homeTeamId,
      awayTeamId: awayTeamId ?? this.awayTeamId,
      matchDay: matchDay ?? this.matchDay,
      homeTeam: homeTeam ?? this.homeTeam,
      awayTeam: awayTeam ?? this.awayTeam,
      leagueId: leagueId ?? this.leagueId,
      league: league ?? this.league,
    );
  }
}
