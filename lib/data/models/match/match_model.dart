import 'package:real_amis/data/models/team/team_model.dart';
import 'package:real_amis/domain/entities/match/match_entity.dart';

class MatchModel extends MatchEntity {
  MatchModel({
    required super.id,
    required super.updatedAt,
    required super.matchDate,
    required super.homeTeamId,
    required super.awayTeamId,
    super.homeTeamScore,
    super.awayTeamScore,
    super.matchDay,
    super.homeTeam,
    super.awayTeam,
  });

  Map<String, dynamic> toJson() {
    return <String, dynamic>{
      'id': id,
      'updated_at': updatedAt.toIso8601String(),
      'match_date': matchDate.toIso8601String(),
      'home_team_id': homeTeamId,
      'away_team_id': awayTeamId,
      'home_team_score': homeTeamScore,
      'away_team_score': awayTeamScore,
      'match_day': matchDay,
    };
  }

  factory MatchModel.fromJson(Map<String, dynamic> map) {
    return MatchModel(
      id: map['id'] ?? '',
      updatedAt: map['updated_at'] == null
          ? DateTime.now()
          : DateTime.parse(map['updated_at']),
      matchDate: map['match_date'] == null
          ? DateTime.now()
          : DateTime.parse(map['match_date']),
      homeTeamId: map['home_team_id'] ?? '',
      awayTeamId: map['away_team_id'] ?? '',
      homeTeamScore: map['home_team_score'] ?? '',
      awayTeamScore: map['away_team_score'] ?? '',
      matchDay: map['match_day'] ?? '',
      homeTeam: map['HomeTeam'] != null
          ? TeamModel.fromJson(map['HomeTeam'] as Map<String, dynamic>)
          : null,
      awayTeam: map['AwayTeam'] != null
          ? TeamModel.fromJson(map['AwayTeam'] as Map<String, dynamic>)
          : null,
    );
  }

  MatchModel copyWith({
    String? id,
    DateTime? updatedAt,
    DateTime? matchDate,
    String? homeTeamId,
    String? awayTeamId,
    int? homeTeamScore,
    int? awayTeamScore,
    String? matchDay,
    TeamModel? homeTeam,
    TeamModel? awayTeam,
  }) {
    return MatchModel(
      id: id ?? this.id,
      updatedAt: updatedAt ?? this.updatedAt,
      matchDate: matchDate ?? this.matchDate,
      homeTeamId: homeTeamId ?? this.homeTeamId,
      awayTeamId: awayTeamId ?? this.awayTeamId,
      homeTeamScore: homeTeamScore ?? this.homeTeamScore,
      awayTeamScore: awayTeamScore ?? this.awayTeamScore,
      matchDay: matchDay ?? this.matchDay,
      homeTeam: homeTeam ?? this.homeTeam,
      awayTeam: awayTeam ?? this.awayTeam,
    );
  }
}
