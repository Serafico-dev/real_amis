import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive/hive.dart';
import 'package:real_amis/data/models/team/team_model.dart';

final teamBoxProvider = Provider<Box>((ref) {
  const boxName = 'teamsBox';
  if (!Hive.isBoxOpen(boxName)) {
    throw Exception(
      "Box '$boxName' non aperta! Assicurati di chiamare Hive.openBox('$boxName') in initDependencies() prima di leggere questo provider.",
    );
  }
  return Hive.box(boxName);
});

abstract interface class TeamLocalDataSource {
  void uploadLocalTeams({required List<TeamModel> teams});
  List<TeamModel> loadTeams();
}

final teamLocalDataSourceProvider = Provider<TeamLocalDataSource>((ref) {
  return TeamLocalDataSourceImpl(ref.read(teamBoxProvider));
});

class TeamLocalDataSourceImpl implements TeamLocalDataSource {
  final Box box;

  TeamLocalDataSourceImpl(this.box);

  @override
  List<TeamModel> loadTeams() {
    final teams = <TeamModel>[];
    for (int i = 0; i < box.length; i++) {
      final data = box.get(i.toString());
      if (data != null) {
        teams.add(TeamModel.fromJson(Map<String, dynamic>.from(data)));
      }
    }
    return teams;
  }

  @override
  void uploadLocalTeams({required List<TeamModel> teams}) {
    box.clear();
    for (int i = 0; i < teams.length; i++) {
      box.put(i.toString(), teams[i].toJson());
    }
  }
}
