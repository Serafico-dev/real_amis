class TeamEntity {
  final String id;
  final DateTime updatedAt;
  final String name;
  final String imageUrl;

  TeamEntity({
    required this.id,
    required this.updatedAt,
    required this.name,
    required this.imageUrl,
  });

  @override
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is TeamEntity && runtimeType == other.runtimeType && id == other.id;

  @override
  int get hashCode => id.hashCode;
}
