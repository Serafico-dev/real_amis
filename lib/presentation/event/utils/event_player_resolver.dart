import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:real_amis/core/secrets/app_secrets.dart';
import 'package:real_amis/domain/entities/event/event_entity.dart';
import 'package:real_amis/domain/entities/match/match_entity.dart';
import 'package:real_amis/domain/entities/player/player_entity.dart';
import 'package:real_amis/presentation/player/providers/player_notifier.dart';

/// Ricava il giocatore del Real Amis a cui è attribuito un evento.
///
/// Gli eventi salvano solo il nome del giocatore, quindi lo cerco tra i
/// giocatori; se ci sono omonimi provo a distinguerli con i convocati della
/// [match]. Restituisce `null` per eventi della squadra avversaria, per gli
/// autogoal e per nomi non riconosciuti.
String? resolveEventPlayerId({
  required EventEntity event,
  required List<PlayerEntity> players,
  MatchEntity? match,
}) {
  if (event.teamId != AppSecrets.realAmisTeamId) return null;
  if (event.isOwnGoal) return null;

  final name = event.player.trim().toLowerCase();
  final sameName = players
      .where((p) => p.fullName.trim().toLowerCase() == name)
      .toList();

  if (sameName.length == 1) return sameName.first.id;
  if (sameName.isEmpty || match == null) return null;

  final calledUp = sameName
      .where((p) => match.calledUpIds.contains(p.id))
      .toList();
  return calledUp.length == 1 ? calledUp.first.id : null;
}

/// Elenco dei giocatori pronto all'uso; se non è ancora stato caricato lo
/// scarico, così il riconoscimento dei nomi non fallisce a vuoto.
Future<List<PlayerEntity>> loadPlayersForStats(Ref ref) async {
  final current = ref.read(playerNotifierProvider).value;
  if (current != null && current.isNotEmpty) return current;
  await ref.read(playerNotifierProvider.notifier).fetchAllPlayers();
  return ref.read(playerNotifierProvider).value ?? const <PlayerEntity>[];
}
