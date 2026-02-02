import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive/hive.dart';
import 'package:real_amis/data/models/league/league_model.dart';

final leagueBoxProvider = Provider<Box>((ref) {
  const boxName = 'leaguesBox';
  if (!Hive.isBoxOpen(boxName)) {
    throw Exception(
      "Box '$boxName' non aperta! Assicurati di chiamare Hive.openBox('$boxName') in initDependencies() prima di leggere questo provider.",
    );
  }
  return Hive.box(boxName);
});

abstract interface class LeagueLocalDataSource {
  void uploadLocalLeagues({required List<LeagueModel> leagues});
  List<LeagueModel> loadLeagues();
}

final leagueLocalDataSourceProvider = Provider<LeagueLocalDataSource>((ref) {
  return LeagueLocalDataSourceImpl(ref.read(leagueBoxProvider));
});

class LeagueLocalDataSourceImpl implements LeagueLocalDataSource {
  final Box box;

  LeagueLocalDataSourceImpl(this.box);

  @override
  List<LeagueModel> loadLeagues() {
    final leagues = <LeagueModel>[];
    for (int i = 0; i < box.length; i++) {
      final json = box.get(i.toString());
      if (json != null) {
        leagues.add(LeagueModel.fromJson(Map<String, dynamic>.from(json)));
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
