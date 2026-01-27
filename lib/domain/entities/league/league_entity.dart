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
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is LeagueEntity && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;
}
