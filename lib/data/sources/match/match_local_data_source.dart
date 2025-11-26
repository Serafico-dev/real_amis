import 'package:hive/hive.dart';
import 'package:real_amis/data/models/match/match_model.dart';

abstract interface class MatchLocalDataSource {
  void uploadLocalMatches({required List<MatchModel> matches});
  List<MatchModel> loadMatches();
}

class MatchLocalDataSourceImpl implements MatchLocalDataSource {
  final Box box;
  MatchLocalDataSourceImpl(this.box);

  @override
  List<MatchModel> loadMatches() {
    List<MatchModel> matches = [];
    box.read(() {
      for (int i = 0; i < box.length; i++) {
        matches.add(MatchModel.fromJson(box.get(i.toString())));
      }
    });
    return matches;
  }

  @override
  void uploadLocalMatches({required List<MatchModel> matches}) {
    box.clear();
    box.write(() {
      for (int i = 0; i < matches.length; i++) {
        box.put(i.toString(), matches[i].toJson());
      }
    });
  }
}
