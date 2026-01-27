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
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is TeamEntity && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;
}
