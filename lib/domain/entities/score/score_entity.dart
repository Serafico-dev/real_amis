class ScoreEntity {
  final String id;
  final String teamId;
  final String leagueId;
  final int score;

  ScoreEntity({
    required this.id,
    required this.teamId,
    required this.leagueId,
    required this.score,
  });

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is ScoreEntity && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;
}
