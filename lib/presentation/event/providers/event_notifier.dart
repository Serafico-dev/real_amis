import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';
import 'package:real_amis/data/sources/player/player_supabase_data_source.dart';
import 'package:real_amis/domain/entities/event/event_entity.dart';
import 'package:real_amis/domain/entities/event/event_type.dart';
import 'package:real_amis/domain/usecases/event/get_events_by_match.dart';
import 'package:real_amis/domain/usecases/event/update_event.dart';
import 'package:real_amis/domain/usecases/event/upload_event.dart';
import 'package:real_amis/core/usecase/usecase.dart';
import 'package:real_amis/presentation/event/providers/event_provider.dart';
import 'package:real_amis/presentation/player/providers/player_notifier.dart';

final eventNotifierProvider =
    StateNotifierProvider.family<
      EventNotifier,
      AsyncValue<List<EventEntity>>,
      String
    >((ref, matchId) => EventNotifier(ref, matchId));

class EventNotifier extends StateNotifier<AsyncValue<List<EventEntity>>> {
  final Ref ref;
  final String matchId;

  EventNotifier(this.ref, this.matchId) : super(const AsyncLoading()) {
    fetchEventsByMatch();
  }

  Future<void> fetchEventsByMatch() async {
    state = const AsyncLoading();
    final res = await ref.read(getEventsByMatchProvider)(
      MatchIdParams(matchId),
    );
    state = res.fold(
      (failure) => AsyncError(failure.message, StackTrace.current),
      (events) => AsyncData(events),
    );
  }

  Future<void> fetchAllEvents() async {
    state = const AsyncLoading();
    final res = await ref.read(getAllEventsProvider)(NoParams());
    state = res.fold(
      (failure) => AsyncError(failure.message, StackTrace.current),
      (events) => AsyncData(events),
    );
  }

  Future<void> uploadEvent(UploadEventParams params) async {
    state = const AsyncLoading();
    final res = await ref.read(uploadEventProvider)(params);
    res.fold(
      (failure) => state = AsyncError(failure.message, StackTrace.current),
      (_) async {
        if (params.playerId != null) {
          final playerDataSource = ref.read(playerSupabaseDataSourceProvider);
          await _applyStatDelta(
            playerDataSource,
            params.playerId!,
            params.eventType,
            delta: 1,
          );
          await ref.read(playerNotifierProvider.notifier).fetchAllPlayers();
        }
        fetchEventsByMatch();
      },
    );
  }

  Future<void> updateEvent(UpdateEventParams params) async {
    final res = await ref.read(updateEventProvider)(params);
    res.fold(
      (failure) => state = AsyncError(failure.message, StackTrace.current),
      (updatedEvent) {
        final current = state.value ?? [];
        final List<EventEntity> updatedList = [
          for (final e in current)
            if (e.id == updatedEvent.id) updatedEvent else e,
        ];
        state = AsyncData(updatedList);
      },
    );
  }

  Future<void> deleteEvent(
    String eventId, {
    String? playerId,
    EventType? eventType,
  }) async {
    state = const AsyncLoading();
    final res = await ref.read(deleteEventProvider)(eventId);
    res.fold(
      (failure) => state = AsyncError(failure.message, StackTrace.current),
      (_) async {
        if (playerId != null && eventType != null) {
          final playerDataSource = ref.read(playerSupabaseDataSourceProvider);
          await _applyStatDelta(
            playerDataSource,
            playerId,
            eventType,
            delta: -1,
          );
          await ref.read(playerNotifierProvider.notifier).fetchAllPlayers();
        }
        fetchEventsByMatch();
      },
    );
  }

  Future<void> _applyStatDelta(
    PlayerSupabaseDataSource ds,
    String playerId,
    EventType eventType, {
    required int delta,
  }) async {
    switch (eventType) {
      case EventType.goal:
        await ds.incrementPlayerStats(playerId: playerId, goalsDelta: delta);
      case EventType.giallo:
        await ds.incrementPlayerStats(
          playerId: playerId,
          yellowCardsDelta: delta,
        );
      case EventType.rosso:
        await ds.incrementPlayerStats(playerId: playerId, redCardsDelta: delta);
    }
  }
}
