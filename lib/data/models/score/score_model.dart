import 'package:real_amis/domain/entities/score/score_entity.dart';

class ScoreModel extends ScoreEntity {
  ScoreModel({
    required super.id,
    required super.teamId,
    required super.leagueId,
    required super.score,
  });

  factory ScoreModel.fromJson(Map<String, dynamic> json) {
    return ScoreModel(
      id: json['id'] as String? ?? '',
      teamId: json['team_id'] as String? ?? '',
      leagueId: json['league_id'] as String? ?? '',
      score: json['score'] as int? ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {'id': id, 'team_id': teamId, 'league_id': leagueId, 'score': score};
  }

  ScoreModel copyWith({
    String? id,
    String? teamId,
    String? leagueId,
    int? score,
  }) {
    return ScoreModel(
      id: id ?? this.id,
      teamId: teamId ?? this.teamId,
      leagueId: leagueId ?? this.leagueId,
      score: score ?? this.score,
    );
  }
}
