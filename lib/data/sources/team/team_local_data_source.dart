import 'package:hive/hive.dart';
import 'package:real_amis/data/models/team/team_model.dart';

abstract interface class TeamLocalDataSource {
  void uploadLocalTeams({required List<TeamModel> teams});
  List<TeamModel> loadTeams();
}

class TeamLocalDataSourceImpl implements TeamLocalDataSource {
  final Box box;
  TeamLocalDataSourceImpl(this.box);

  @override
  List<TeamModel> loadTeams() {
    List<TeamModel> teams = [];
    box.read(() {
      for (int i = 0; i < box.length; i++) {
        teams.add(TeamModel.fromJson(box.get(i.toString())));
      }
    });
    return teams;
  }

  @override
  void uploadLocalTeams({required List<TeamModel> teams}) {
    box.clear();
    box.write(() {
      for (int i = 0; i < teams.length; i++) {
        box.put(i.toString(), teams[i].toJson());
      }
    });
  }
}
