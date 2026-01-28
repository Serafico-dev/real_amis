class LeagueEntity {
  final String id;
  final String name;
  final String year;
  final List<String> teamIds;

  LeagueEntity({
    required this.id,
    required this.name,
    required this.year,
    required this.teamIds,
  });

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is LeagueEntity &&
          runtimeType == other.runtimeType &&
          id == other.id;

  @override
  int get hashCode => id.hashCode;
}
