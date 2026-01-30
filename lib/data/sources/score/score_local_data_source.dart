import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive/hive.dart';
import 'package:real_amis/data/models/score/score_model.dart';

/// Provider sicuro della box Hive per i punteggi
final scoreBoxProvider = Provider<Box>((ref) {
  const boxName = 'scoresBox';
  if (!Hive.isBoxOpen(boxName)) {
    throw Exception(
      "Box '$boxName' non aperta! Assicurati di chiamare Hive.openBox('$boxName') in initDependencies() prima di leggere questo provider.",
    );
  }
  return Hive.box(boxName);
});

/// Interfaccia per il local data source dei punteggi
abstract interface class ScoreLocalDataSource {
  void uploadLocalScores({required List<ScoreModel> scores});
  List<ScoreModel> loadScores();
  List<ScoreModel> loadScoresByLeague({required String leagueId});
}

/// Provider del local data source dei punteggi
final scoreLocalDataSourceProvider = Provider<ScoreLocalDataSource>((ref) {
  return ScoreLocalDataSourceImpl(ref.read(scoreBoxProvider));
});

/// Implementazione concreta del local data source dei punteggi
class ScoreLocalDataSourceImpl implements ScoreLocalDataSource {
  final Box box;

  ScoreLocalDataSourceImpl(this.box);

  @override
  List<ScoreModel> loadScores() {
    final scores = <ScoreModel>[];
    for (int i = 0; i < box.length; i++) {
      final json = box.get(i.toString());
      if (json != null) {
        scores.add(ScoreModel.fromJson(Map<String, dynamic>.from(json)));
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
