import 'package:real_amis/core/errors/exceptions.dart';
import 'package:real_amis/data/models/score/score_model.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

abstract interface class ScoreSupabaseDataSource {
  Future<ScoreModel> uploadScore(ScoreModel score);
  Future<List<ScoreModel>> getAllScores();
  Future<List<ScoreModel>> getScoresByLeague({required String leagueId});
  Future<ScoreModel> updateScore(ScoreModel score);
  Future<ScoreModel> deleteScore({required String scoreId});
}

class ScoreSupabaseDataSourceImpl implements ScoreSupabaseDataSource {
  final SupabaseClient supabaseClient;
  ScoreSupabaseDataSourceImpl(this.supabaseClient);

  @override
  Future<ScoreModel> uploadScore(ScoreModel score) async {
    try {
      final scoreData = await supabaseClient
          .from('scores')
          .insert(score.toJson())
          .select();
      return ScoreModel.fromJson(scoreData.first);
    } on PostgrestException catch (e) {
      throw ServerException(e.message);
    } catch (e) {
      throw ServerException(e.toString());
    }
  }

  @override
  Future<List<ScoreModel>> getAllScores() async {
    try {
      final scores = await supabaseClient.from('scores').select();
      return scores.map((score) => ScoreModel.fromJson(score)).toList();
    } on PostgrestException catch (e) {
      throw ServerException(e.message);
    } catch (e) {
      throw ServerException(e.toString());
    }
  }

  @override
  Future<List<ScoreModel>> getScoresByLeague({required String leagueId}) async {
    final res = await supabaseClient
        .from('scores')
        .select()
        .eq('league_id', leagueId);

    return (res as List).map((e) => ScoreModel.fromJson(e)).toList();
  }

  @override
  Future<ScoreModel> updateScore(ScoreModel score) async {
    try {
      final scoreData = await supabaseClient
          .from('scores')
          .update(score.toJson())
          .eq('id', score.id)
          .select();
      return ScoreModel.fromJson(scoreData.first);
    } on PostgrestException catch (e) {
      throw ServerException(e.message);
    } catch (e) {
      throw ServerException(e.toString());
    }
  }

  @override
  Future<ScoreModel> deleteScore({required String scoreId}) async {
    try {
      await supabaseClient.storage.from('scores').remove([scoreId]);
      final scoreData = await supabaseClient
          .from('scores')
          .delete()
          .eq('id', scoreId)
          .select();
      return ScoreModel.fromJson(scoreData.first);
    } on PostgrestException catch (e) {
      throw ServerException(e.message);
    } catch (e) {
      throw ServerException(e.toString());
    }
  }
}
