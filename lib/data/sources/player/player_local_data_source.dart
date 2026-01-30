import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive/hive.dart';
import 'package:real_amis/data/models/player/player_model.dart';

/// Provider sicuro della box Hive per i giocatori
final playerBoxProvider = Provider<Box>((ref) {
  const boxName = 'playersBox';
  if (!Hive.isBoxOpen(boxName)) {
    throw Exception(
      "Box '$boxName' non aperta! Assicurati di chiamare Hive.openBox('$boxName') in initDependencies() prima di leggere questo provider.",
    );
  }
  return Hive.box(boxName);
});

/// Interfaccia per il local data source dei giocatori
abstract interface class PlayerLocalDataSource {
  void uploadLocalPlayers({required List<PlayerModel> players});
  List<PlayerModel> loadPlayers();
}

/// Provider del local data source dei giocatori
final playerLocalDataSourceProvider = Provider<PlayerLocalDataSource>((ref) {
  return PlayerLocalDataSourceImpl(ref.read(playerBoxProvider));
});

/// Implementazione concreta del local data source dei giocatori
class PlayerLocalDataSourceImpl implements PlayerLocalDataSource {
  final Box box;

  PlayerLocalDataSourceImpl(this.box);

  @override
  List<PlayerModel> loadPlayers() {
    final players = <PlayerModel>[];
    for (int i = 0; i < box.length; i++) {
      final data = box.get(i.toString());
      if (data != null) {
        players.add(PlayerModel.fromJson(Map<String, dynamic>.from(data)));
      }
    }
    return players;
  }

  @override
  void uploadLocalPlayers({required List<PlayerModel> players}) {
    box.clear();
    for (int i = 0; i < players.length; i++) {
      box.put(i.toString(), players[i].toJson());
    }
  }
}
