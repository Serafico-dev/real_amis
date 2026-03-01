import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:real_amis/domain/entities/history/club_section_entity.dart';
import 'package:real_amis/domain/entities/history/club_timeline_entity.dart';
import 'package:real_amis/domain/repositories/history/club_history_repository.dart';
import 'package:uuid/uuid.dart';

class ClubHistoryRepositoryImpl implements ClubHistoryRepository {
  final SupabaseClient _supabase;

  ClubHistoryRepositoryImpl(this._supabase);

  @override
  Future<List<ClubSectionEntity>> getSections() async {
    final data = await _supabase
        .from('club_history')
        .select()
        .order('sort_order', ascending: true);
    return (data as List)
        .map(
          (e) => ClubSectionEntity(
            id: e['id'],
            sectionKey: e['section_key'],
            title: e['title'],
            content: e['content'],
            sortOrder: e['sort_order'],
            isFixed: e['is_fixed'],
          ),
        )
        .toList();
  }

  @override
  Future<void> addSection(String title, String content, int sortOrder) async {
    await _supabase.from('club_history').insert({
      'section_key': const Uuid().v4(),
      'title': title,
      'content': content,
      'sort_order': sortOrder,
      'is_fixed': false,
    });
  }

  @override
  Future<void> deleteSection(String id) async {
    await _supabase.from('club_history').delete().eq('id', id);
  }

  @override
  Future<void> reorderSections(List<ClubSectionEntity> sections) async {
    await Future.wait(
      sections.asMap().entries.map(
        (entry) => _supabase
            .from('club_history')
            .update({'sort_order': entry.key})
            .eq('id', entry.value.id),
      ),
    );
  }

  @override
  Future<void> updateSection(ClubSectionEntity section) async {
    await _supabase
        .from('club_history')
        .update({
          'title': section.title,
          'content': section.content,
          'updated_at': DateTime.now().toIso8601String(),
        })
        .eq('id', section.id);
  }

  @override
  Future<List<ClubTimelineEntity>> getTimeline() async {
    final data = await _supabase
        .from('club_timeline')
        .select()
        .order('sort_order', ascending: true);
    return (data as List)
        .map(
          (e) => ClubTimelineEntity(
            id: e['id'],
            year: e['year'],
            eventDescription: e['event_description'],
            sortOrder: e['sort_order'],
          ),
        )
        .toList();
  }

  @override
  Future<void> upsertTimelineItem(ClubTimelineEntity item) async {
    await _supabase.from('club_timeline').upsert({
      'id': item.id.isNotEmpty ? item.id : const Uuid().v4(),
      'year': item.year,
      'event_description': item.eventDescription,
      'sort_order': item.sortOrder,
    });
  }

  @override
  Future<void> deleteTimelineItem(String id) async {
    await _supabase.from('club_timeline').delete().eq('id', id);
  }
}
