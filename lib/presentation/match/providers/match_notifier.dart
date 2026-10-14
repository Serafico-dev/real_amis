import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';
import 'package:real_amis/core/errors/failure.dart';
import 'package:real_amis/core/notifications/match_notification_service.dart';
import 'package:real_amis/core/secrets/app_secrets.dart';
import 'package:real_amis/data/sources/player/player_supabase_data_source.dart';
import 'package:real_amis/domain/entities/event/event_entity.dart';
import 'package:real_amis/domain/entities/event/event_type.dart';
import 'package:real_amis/domain/entities/match/match_entity.dart';
import 'package:real_amis/domain/usecases/event/get_events_by_match.dart';
import 'package:real_amis/domain/usecases/match/update_match.dart';
import 'package:real_amis/domain/usecases/match/upload_match.dart';
import 'package:real_amis/core/usecase/usecase.dart';
import 'package:real_amis/presentation/event/providers/event_provider.dart';
import 'package:real_amis/presentation/event/utils/event_player_resolver.dart';
import 'package:real_amis/presentation/match/providers/match_provider.dart';
import 'package:real_amis/presentation/player/providers/player_notifier.dart';

/// Esito di un'operazione su una partita.
class MatchActionResult {
  /// Messaggio d'errore; `null` se l'operazione è riuscita.
  final String? error;

  /// Avviso non bloccante: l'operazione è riuscita, ma qualche statistica
  /// potrebbe non essere stata aggiornata.
  final String? warning;

  const MatchActionResult({this.error, this.warning});

  bool get ok => error == null;
}

final matchNotifierProvider =
    StateNotifierProvider<MatchNotifier, AsyncValue<List<MatchEntity>>>(
      (ref) => MatchNotifier(ref),
    );

class MatchNotifier extends StateNotifier<AsyncValue<List<MatchEntity>>> {
  final Ref ref;

  MatchNotifier(this.ref) : super(const AsyncLoading());

  Future<void> fetchAllMatches() async {
    state = const AsyncLoading();
    final res = await ref.read(getAllMatchesProvider)(NoParams());
    state = res.fold(
      (failure) => AsyncError(failure.message, StackTrace.current),
      (matches) {
        _scheduleMatchReminders(matches);
        return AsyncData(matches);
      },
    );
  }

  void _scheduleMatchReminders(List<MatchEntity> matches) {
    final service = ref.read(matchNotificationServiceProvider);
    for (final match in matches) {
      service.scheduleMatchReminder(
        matchId: match.id,
        matchDate: match.matchDate,
        played: match.played,
        homeTeamName: match.homeTeam?.name,
        awayTeamName: match.awayTeam?.name,
      );
    }
  }

  Future<void> uploadMatch(UploadMatchParams params) async {
    state = const AsyncLoading();
    final res = await ref.read(uploadMatchProvider)(params);
    res.fold(
      (failure) => state = AsyncError(failure.message, StackTrace.current),
      (_) async => fetchAllMatches(),
    );
  }

  Future<MatchActionResult> updateMatch(UpdateMatchParams params) async {
    final res = await ref.read(updateMatchProvider)(params);

    final failure = res.fold<Failure?>((f) => f, (_) => null);
    if (failure != null) return MatchActionResult(error: failure.message);
    final updatedMatch = res.fold<MatchEntity?>((_) => null, (m) => m);
    if (updatedMatch == null) {
      return const MatchActionResult(error: 'Aggiornamento non riuscito');
    }

    final current = state.value ?? [];
    final updatedList = [
      for (final m in current)
        if (m.id == updatedMatch.id) updatedMatch else m,
    ];
    state = AsyncData(updatedList);
    ref
        .read(matchNotificationServiceProvider)
        .scheduleMatchReminder(
          matchId: updatedMatch.id,
          matchDate: updatedMatch.matchDate,
          played: updatedMatch.played,
          homeTeamName: updatedMatch.homeTeam?.name,
          awayTeamName: updatedMatch.awayTeam?.name,
        );

    final warning = await _syncAttendancesAfterEdit(params.match, updatedMatch);
    return MatchActionResult(warning: warning);
  }

  /// Se la partita risulta già giocata, le presenze sono già state conteggiate:
  /// quando cambia l'elenco dei convocati aggiungo una presenza a chi entra e
  /// ne tolgo una a chi esce.
  Future<String?> _syncAttendancesAfterEdit(
    MatchEntity before,
    MatchEntity after,
  ) async {
    if (!before.played || !after.played) return null;

    final oldIds = before.calledUpIds.toSet();
    final newIds = after.calledUpIds.toSet();
    final added = newIds.difference(oldIds);
    final removed = oldIds.difference(newIds);
    if (added.isEmpty && removed.isEmpty) return null;

    try {
      final players = await loadPlayersForStats(ref);
      final known = players.map((p) => p.id).toSet();
      final ds = ref.read(playerSupabaseDataSourceProvider);

      await Future.wait([
        for (final id in added.where(known.contains))
          ds.incrementPlayerStats(playerId: id, attendancesDelta: 1),
        for (final id in removed.where(known.contains))
          ds.incrementPlayerStats(playerId: id, attendancesDelta: -1),
      ]);
      await ref.read(playerNotifierProvider.notifier).fetchAllPlayers();
    } catch (e) {
      return 'Partita aggiornata, ma non sono riuscito ad aggiornare le '
          'presenze dei giocatori ($e)';
    }
    return null;
  }

  /// Elimina una partita riallineando le statistiche dei giocatori: toglie le
  /// presenze (se la partita risultava giocata) e i gol/cartellini dei suoi
  /// eventi. Gli eventi vengono eliminati dal DB insieme alla partita.
  Future<MatchActionResult> deleteMatch(MatchEntity match) async {
    final previous = state;

    // Gli eventi vanno letti PRIMA di eliminare la partita: dopo non ci sono più.
    final eventsRes = await ref.read(getEventsByMatchProvider)(
      MatchIdParams(match.id),
    );
    final events = eventsRes.fold<List<EventEntity>?>((_) => null, (e) => e);
    if (events == null) {
      return const MatchActionResult(
        error:
            'Non riesco a leggere gli eventi della partita, riprova tra poco.',
      );
    }

    state = const AsyncLoading();
    final res = await ref.read(deleteMatchProvider)(match.id);
    final failure = res.fold<Failure?>((f) => f, (_) => null);
    if (failure != null) {
      state = previous;
      return MatchActionResult(error: failure.message);
    }

    ref.read(matchNotificationServiceProvider).cancel(match.id);

    final warning = await _revertStatsForDeletedMatch(match, events);
    await fetchAllMatches();
    return MatchActionResult(warning: warning);
  }

  /// Annulla l'effetto della partita sui contatori: una presenza per ogni
  /// convocato (solo se era stata segnata come giocata) e gol/gialli/rossi
  /// degli eventi attribuiti a giocatori del Real Amis.
  Future<String?> _revertStatsForDeletedMatch(
    MatchEntity match,
    List<EventEntity> events,
  ) async {
    final players = await loadPlayersForStats(ref);

    // id giocatore -> [presenze, gol, gialli, rossi] da sottrarre.
    final deltas = <String, List<int>>{};
    List<int> slot(String id) => deltas.putIfAbsent(id, () => [0, 0, 0, 0]);

    if (match.played) {
      final knownIds = players.map((p) => p.id).toSet();
      for (final id in match.calledUpIds) {
        if (knownIds.contains(id)) slot(id)[0] -= 1;
      }
    }

    final unresolved = <String>{};
    for (final event in events) {
      final playerId = resolveEventPlayerId(
        event: event,
        players: players,
        match: match,
      );
      if (playerId == null) {
        if (event.teamId == AppSecrets.realAmisTeamId && !event.isOwnGoal) {
          unresolved.add(event.player);
        }
        continue;
      }
      switch (event.eventType) {
        case EventType.goal:
          slot(playerId)[1] -= 1;
        case EventType.giallo:
          slot(playerId)[2] -= 1;
        case EventType.rosso:
          slot(playerId)[3] -= 1;
      }
    }

    try {
      final ds = ref.read(playerSupabaseDataSourceProvider);
      await Future.wait(
        deltas.entries
            .where((e) => e.value.any((d) => d != 0))
            .map(
              (e) => ds.incrementPlayerStats(
                playerId: e.key,
                attendancesDelta: e.value[0],
                goalsDelta: e.value[1],
                yellowCardsDelta: e.value[2],
                redCardsDelta: e.value[3],
              ),
            ),
      );
      await ref.read(playerNotifierProvider.notifier).fetchAllPlayers();
    } catch (e) {
      return 'Partita eliminata, ma non sono riuscito ad aggiornare le '
          'statistiche dei giocatori ($e)';
    }

    if (unresolved.isNotEmpty) {
      return 'Partita eliminata. Non ho riconosciuto ${unresolved.join(', ')} '
          'tra i giocatori: le loro statistiche non sono state aggiornate.';
    }
    return null;
  }

  /// Partite per cui è in corso "segna come giocata": evita che un doppio tap
  /// incrementi due volte le presenze.
  final Set<String> _markingAsPlayed = {};

  /// Segna la partita come giocata e incrementa le presenze dei convocati.
  Future<MatchActionResult> markAsPlayed(MatchEntity match) async {
    if (match.played) {
      return const MatchActionResult(
        error: 'La partita è già stata segnata come giocata',
      );
    }
    if (match.calledUpIds.isEmpty) {
      return const MatchActionResult(
        error: 'Nessun convocato per questa partita',
      );
    }
    if (!_markingAsPlayed.add(match.id)) {
      return const MatchActionResult(error: 'Operazione già in corso');
    }

    try {
      // Prima segno la partita come giocata: se questo passaggio fallisce non
      // ho ancora toccato le presenze, quindi si può riprovare senza doppioni.
      final res = await ref.read(updateMatchProvider)(
        UpdateMatchParams(
          match: match,
          matchDate: match.matchDate,
          homeTeamId: match.homeTeamId,
          awayTeamId: match.awayTeamId,
          matchDay: match.matchDay,
          leagueId: match.leagueId!,
          calledUpIds: match.calledUpIds,
          played: true,
        ),
      );
      final failure = res.fold<Failure?>((f) => f, (_) => null);
      if (failure != null) return MatchActionResult(error: failure.message);

      String? warning;
      try {
        final playerDataSource = ref.read(playerSupabaseDataSourceProvider);
        await Future.wait(
          match.calledUpIds.map(
            (id) => playerDataSource.incrementPlayerStats(
              playerId: id,
              attendancesDelta: 1,
            ),
          ),
        );
      } catch (e) {
        warning =
            'Partita segnata come giocata, ma non sono riuscito ad '
            'aggiornare tutte le presenze ($e)';
      }

      await Future.wait([
        fetchAllMatches(),
        ref.read(playerNotifierProvider.notifier).fetchAllPlayers(),
      ]);
      return MatchActionResult(warning: warning);
    } finally {
      _markingAsPlayed.remove(match.id);
    }
  }
}
