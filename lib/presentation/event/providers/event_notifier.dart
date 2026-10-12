import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';
import 'package:real_amis/core/errors/failure.dart';
import 'package:real_amis/core/secrets/app_secrets.dart';
import 'package:real_amis/data/sources/player/player_supabase_data_source.dart';
import 'package:real_amis/domain/entities/event/event_entity.dart';
import 'package:real_amis/domain/entities/event/event_type.dart';
import 'package:real_amis/domain/entities/match/match_entity.dart';
import 'package:real_amis/domain/entities/player/player_entity.dart';
import 'package:real_amis/domain/usecases/event/get_events_by_match.dart';
import 'package:real_amis/domain/usecases/event/update_event.dart';
import 'package:real_amis/domain/usecases/event/upload_event.dart';
import 'package:real_amis/core/usecase/usecase.dart';
import 'package:real_amis/presentation/event/providers/event_provider.dart';
import 'package:real_amis/presentation/match/providers/match_notifier.dart';
import 'package:real_amis/presentation/player/providers/player_notifier.dart';

/// Esito di una modifica/eliminazione di un evento.
class EventActionResult {
  /// Messaggio d'errore; `null` se l'operazione è riuscita.
  final String? error;

  /// Avviso non bloccante: l'operazione è riuscita, ma le statistiche del
  /// giocatore potrebbero non essere state aggiornate.
  final String? warning;

  const EventActionResult({this.error, this.warning});

  bool get ok => error == null;
}

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

  Future<EventActionResult> updateEvent(UpdateEventParams params) async {
    final before = params.event;
    final res = await ref.read(updateEventProvider)(params);

    final failure = res.fold<Failure?>((f) => f, (_) => null);
    if (failure != null) {
      return EventActionResult(error: failure.message);
    }
    final after = res.fold<EventEntity?>((_) => null, (e) => e);
    if (after == null) {
      return const EventActionResult(error: 'Aggiornamento non riuscito');
    }

    final current = state.value ?? [];
    final List<EventEntity> updatedList = [
      for (final e in current)
        if (e.id == after.id) after else e,
    ];
    state = AsyncData(updatedList);

    final warning = await _syncStatsAfterEdit(before, after);
    return EventActionResult(warning: warning);
  }

  Future<EventActionResult> deleteEvent(EventEntity event) async {
    final res = await ref.read(deleteEventProvider)(event.id);

    final failure = res.fold<Failure?>((f) => f, (_) => null);
    if (failure != null) {
      return EventActionResult(error: failure.message);
    }

    // L'evento non c'è più: tolgo la sua "traccia" dalle statistiche.
    String? warning;
    final playerId = _resolvePlayerId(event);
    if (playerId != null) {
      try {
        await _applyStatDelta(
          ref.read(playerSupabaseDataSourceProvider),
          playerId,
          event.eventType,
          delta: -1,
        );
        await ref.read(playerNotifierProvider.notifier).fetchAllPlayers();
      } catch (e) {
        warning =
            'Evento eliminato, ma non sono riuscito ad aggiornare le '
            'statistiche del giocatore ($e)';
      }
    } else {
      warning = _unresolvedPlayerWarning(event, playerId);
    }

    await fetchEventsByMatch();
    return EventActionResult(warning: warning);
  }

  /// Dopo una modifica, riallinea i contatori del giocatore: toglie l'evento
  /// "vecchio" e aggiunge quello "nuovo", solo se qualcosa è cambiato.
  Future<String?> _syncStatsAfterEdit(
    EventEntity before,
    EventEntity after,
  ) async {
    final beforeId = _resolvePlayerId(before);
    final afterId = _resolvePlayerId(after);

    if (beforeId == afterId && before.eventType == after.eventType) {
      return null;
    }

    try {
      final ds = ref.read(playerSupabaseDataSourceProvider);
      if (beforeId != null) {
        await _applyStatDelta(ds, beforeId, before.eventType, delta: -1);
      }
      if (afterId != null) {
        await _applyStatDelta(ds, afterId, after.eventType, delta: 1);
      }
      if (beforeId != null || afterId != null) {
        await ref.read(playerNotifierProvider.notifier).fetchAllPlayers();
      }
    } catch (e) {
      return 'Evento salvato, ma non sono riuscito ad aggiornare le '
          'statistiche del giocatore ($e)';
    }

    return _unresolvedPlayerWarning(before, beforeId) ??
        _unresolvedPlayerWarning(after, afterId);
  }

  /// Ricava il giocatore del Real Amis a cui è attribuito l'evento.
  ///
  /// Gli eventi salvano solo il nome del giocatore, quindi lo cerco tra i
  /// giocatori; se ci sono omonimi provo a distinguerli con i convocati della
  /// partita. Restituisce `null` per eventi della squadra avversaria, per gli
  /// autogoal e per nomi non riconosciuti.
  String? _resolvePlayerId(EventEntity event) {
    if (event.teamId != AppSecrets.realAmisTeamId) return null;
    if (event.isOwnGoal) return null;

    final name = event.player.trim().toLowerCase();
    final players =
        ref.read(playerNotifierProvider).value ?? const <PlayerEntity>[];
    final sameName = players
        .where((p) => p.fullName.trim().toLowerCase() == name)
        .toList();

    if (sameName.length == 1) return sameName.first.id;
    if (sameName.isEmpty) return null;

    final matches =
        ref.read(matchNotifierProvider).value ?? const <MatchEntity>[];
    final match = matches.where((m) => m.id == event.matchId).firstOrNull;
    if (match == null) return null;

    final calledUp = sameName
        .where((p) => match.calledUpIds.contains(p.id))
        .toList();
    return calledUp.length == 1 ? calledUp.first.id : null;
  }

  /// Avviso per un evento del Real Amis (non autogoal) il cui giocatore non è
  /// stato riconosciuto, quindi senza statistiche da aggiornare.
  String? _unresolvedPlayerWarning(EventEntity event, String? resolvedId) {
    if (resolvedId != null) return null;
    if (event.teamId != AppSecrets.realAmisTeamId || event.isOwnGoal) {
      return null;
    }
    return 'Non ho riconosciuto "${event.player}" tra i giocatori: le sue '
        'statistiche non sono state aggiornate.';
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
