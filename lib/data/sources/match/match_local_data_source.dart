import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive/hive.dart';
import 'package:real_amis/data/models/match/match_model.dart';

final matchBoxProvider = Provider<Box>((ref) {
  const boxName = 'matchesBox';
  if (!Hive.isBoxOpen(boxName)) {
    throw Exception(
      "Box '$boxName' non aperta! Assicurati di chiamare Hive.openBox('$boxName') in initDependencies() prima di leggere questo provider.",
    );
  }
  return Hive.box(boxName);
});

abstract interface class MatchLocalDataSource {
  void uploadLocalMatches({required List<MatchModel> matches});
  List<MatchModel> loadMatches();
}

final matchLocalDataSourceProvider = Provider<MatchLocalDataSource>((ref) {
  return MatchLocalDataSourceImpl(ref.read(matchBoxProvider));
});

class MatchLocalDataSourceImpl implements MatchLocalDataSource {
  final Box box;

  MatchLocalDataSourceImpl(this.box);

  @override
  List<MatchModel> loadMatches() {
    final matches = <MatchModel>[];
    for (int i = 0; i < box.length; i++) {
      final data = box.get(i.toString());
      if (data != null) {
        matches.add(MatchModel.fromJson(Map<String, dynamic>.from(data)));
      }
    }
    return matches;
  }

  @override
  void uploadLocalMatches({required List<MatchModel> matches}) {
    box.clear();
    for (int i = 0; i < matches.length; i++) {
      box.put(i.toString(), matches[i].toJson());
    }
  }
}
