import 'package:hive/hive.dart';
import 'package:real_amis/data/models/league/league_model.dart';

abstract interface class LeagueLocalDataSource {
  void uploadLocalLeagues({required List<LeagueModel> leagues});
  List<LeagueModel> loadLeagues();
}

class LeagueLocalDataSourceImpl implements LeagueLocalDataSource {
  final Box box;
  LeagueLocalDataSourceImpl(this.box);

  @override
  List<LeagueModel> loadLeagues() {
    List<LeagueModel> leagues = [];
    box.read(() {
      for (int i = 0; i < box.length; i++) {
        leagues.add(LeagueModel.fromJson(box.get(i.toString())));
      }
    });
    return leagues;
  }

  @override
  void uploadLocalLeagues({required List<LeagueModel> leagues}) {
    box.clear();
    box.write(() {
      for (int i = 0; i < leagues.length; i++) {
        box.put(i.toString(), leagues[i].toJson());
      }
    });
  }
}
