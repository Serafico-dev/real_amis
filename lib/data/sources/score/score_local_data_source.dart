import 'package:hive/hive.dart';
import 'package:real_amis/data/models/score/score_model.dart';

abstract interface class ScoreLocalDataSource {
  void uploadLocalScores({required List<ScoreModel> scores});

  List<ScoreModel> loadScores();

  List<ScoreModel> loadScoresByLeague({required String leagueId});
}

class ScoreLocalDataSourceImpl implements ScoreLocalDataSource {
  final Box box;
  ScoreLocalDataSourceImpl(this.box);

  @override
  List<ScoreModel> loadScores() {
    final scores = <ScoreModel>[];
    for (int i = 0; i < box.length; i++) {
      final json = box.get(i.toString());
      if (json != null) {
        scores.add(ScoreModel.fromJson(json));
      }
    }
    return scores;
  }

  @override
  List<ScoreModel> loadScoresByLeague({required String leagueId}) {
    return loadScores().where((score) => score.leagueId == leagueId).toList();
  }

  @override
  void uploadLocalScores({required List<ScoreModel> scores}) {
    box.clear();
    for (int i = 0; i < scores.length; i++) {
      box.put(i.toString(), scores[i].toJson());
    }
  }
}
