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
    final leagues = <LeagueModel>[];
    for (int i = 0; i < box.length; i++) {
      final json = box.get(i.toString());
      if (json != null) {
        leagues.add(LeagueModel.fromJson(json));
      }
    }
    return leagues;
  }

  @override
  void uploadLocalLeagues({required List<LeagueModel> leagues}) {
    box.clear();
    for (int i = 0; i < leagues.length; i++) {
      box.put(i.toString(), leagues[i].toJson());
    }
  }
}
