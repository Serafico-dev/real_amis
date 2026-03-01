import 'package:real_amis/domain/entities/history/club_section_entity.dart';
import 'package:real_amis/domain/entities/history/club_timeline_entity.dart';

abstract class ClubHistoryRepository {
  Future<List<ClubSectionEntity>> getSections();
  Future<void> updateSection(ClubSectionEntity section);
  Future<void> addSection(String title, String content, int sortOrder);
  Future<void> deleteSection(String id);
  Future<void> reorderSections(List<ClubSectionEntity> sections);
  Future<List<ClubTimelineEntity>> getTimeline();
  Future<void> upsertTimelineItem(ClubTimelineEntity item);
  Future<void> deleteTimelineItem(String id);
}
