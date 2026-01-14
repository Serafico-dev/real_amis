class TeamEntity {
  final String id;
  final DateTime updatedAt;
  final String name;
  final String imageUrl;
  final int? score;

  TeamEntity({
    required this.id,
    required this.updatedAt,
    required this.name,
    required this.imageUrl,
    this.score,
  });
}
