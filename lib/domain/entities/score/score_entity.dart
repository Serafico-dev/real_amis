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
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ScoreEntity &&
          runtimeType == other.runtimeType &&
          id == other.id;

  @override
  int get hashCode => id.hashCode;
}
