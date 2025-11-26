import 'package:hive/hive.dart';
import 'package:real_amis/data/models/player/player_model.dart';

abstract interface class PlayerLocalDataSource {
  void uploadLocalPlayers({required List<PlayerModel> players});
  List<PlayerModel> loadPlayers();
}

class PlayerLocalDataSourceImpl implements PlayerLocalDataSource {
  final Box box;
  PlayerLocalDataSourceImpl(this.box);

  @override
  List<PlayerModel> loadPlayers() {
    List<PlayerModel> players = [];
    box.read(() {
      for (int i = 0; i < box.length; i++) {
        players.add(PlayerModel.fromJson(box.get(i.toString())));
      }
    });
    return players;
  }

  @override
  void uploadLocalPlayers({required List<PlayerModel> players}) {
    box.clear();
    box.write(() {
      for (int i = 0; i < players.length; i++) {
        box.put(i.toString(), players[i].toJson());
      }
    });
  }
}
