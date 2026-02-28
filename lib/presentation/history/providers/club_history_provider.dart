import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:real_amis/data/repositories/history/club_history_repository_impl.dart';
import 'package:real_amis/domain/entities/history/club_section_entity.dart';
import 'package:real_amis/domain/entities/history/club_timeline_entity.dart';

final clubHistoryRepositoryProvider = Provider(
  (ref) => ClubHistoryRepositoryImpl(Supabase.instance.client),
);

final clubSectionsProvider = FutureProvider<List<ClubSectionEntity>>((ref) {
  return ref.watch(clubHistoryRepositoryProvider).getSections();
});

final clubTimelineProvider = FutureProvider<List<ClubTimelineEntity>>((ref) {
  return ref.watch(clubHistoryRepositoryProvider).getTimeline();
});
