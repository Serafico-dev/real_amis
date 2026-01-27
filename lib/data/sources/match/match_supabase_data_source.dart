import 'package:real_amis/core/errors/exceptions.dart';
import 'package:real_amis/data/models/match/match_model.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

abstract interface class MatchSupabaseDataSource {
  Future<MatchModel> uploadMatch(MatchModel match);
  Future<List<MatchModel>> getAllMatches();
  Future<MatchModel> updateMatch(MatchModel match);
  Future<MatchModel> deleteMatch({required String matchId});
}

class MatchSupabaseDataSourceImpl implements MatchSupabaseDataSource {
  final SupabaseClient supabaseClient;
  MatchSupabaseDataSourceImpl(this.supabaseClient);

  @override
  Future<MatchModel> uploadMatch(MatchModel match) async {
    try {
      final matchData = await supabaseClient
          .from('matches')
          .insert(match.toJson())
          .select();
      return MatchModel.fromJson(matchData.first);
    } on PostgrestException catch (e) {
      throw ServerException(e.message);
    } catch (e) {
      throw ServerException(e.toString());
    }
  }

  @override
  Future<List<MatchModel>> getAllMatches() async {
    try {
      final matches = await supabaseClient
          .from('matches')
          .select(
            '*, home_team:home_team_id(id,name,image_url), away_team:away_team_id(id,name,image_url)',
          );
      return (matches as List)
          .map((match) => MatchModel.fromJson(match as Map<String, dynamic>))
          .toList();
    } on PostgrestException catch (e) {
      throw ServerException(e.message);
    } catch (e) {
      throw ServerException(e.toString());
    }
  }

  @override
  Future<MatchModel> updateMatch(MatchModel match) async {
    try {
      final matchData = await supabaseClient
          .from('matches')
          .update(match.toJson())
          .eq('id', match.id)
          .select();
      return MatchModel.fromJson(matchData.first);
    } on PostgrestException catch (e) {
      throw ServerException(e.message);
    } catch (e) {
      throw ServerException(e.toString());
    }
  }

  @override
  Future<MatchModel> deleteMatch({required String matchId}) async {
    try {
      final matchData = await supabaseClient
          .from('matches')
          .delete()
          .eq('id', matchId)
          .select();
      return MatchModel.fromJson(matchData.first);
    } on PostgrestException catch (e) {
      throw ServerException(e.message);
    } catch (e) {
      throw ServerException(e.toString());
    }
  }
}
