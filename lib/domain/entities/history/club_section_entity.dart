class ClubSectionEntity {
  final String id;
  final String sectionKey;
  final String title;
  final String content;
  final int sortOrder;
  final bool isFixed;

  const ClubSectionEntity({
    required this.id,
    required this.sectionKey,
    required this.title,
    required this.content,
    required this.sortOrder,
    required this.isFixed,
  });
}
