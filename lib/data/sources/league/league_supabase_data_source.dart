import 'package:real_amis/core/errors/exceptions.dart';
import 'package:real_amis/data/models/league/league_model.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

abstract interface class LeagueSupabaseDataSource {
  Future<LeagueModel> uploadLeague(LeagueModel league);
  Future<List<LeagueModel>> getAllLeagues();
  Future<LeagueModel> updateLeague(LeagueModel league);
  Future<LeagueModel> deleteLeague({required String leagueId});
}

class LeagueSupabaseDataSourceImpl implements LeagueSupabaseDataSource {
  final SupabaseClient supabaseClient;
  LeagueSupabaseDataSourceImpl(this.supabaseClient);

  @override
  Future<LeagueModel> uploadLeague(LeagueModel league) async {
    try {
      final leagueData = await supabaseClient
          .from('leagues')
          .insert(league.toJson())
          .select();
      return LeagueModel.fromJson(leagueData.first);
    } on PostgrestException catch (e) {
      throw ServerException(e.message);
    } catch (e) {
      throw ServerException(e.toString());
    }
  }

  @override
  Future<List<LeagueModel>> getAllLeagues() async {
    try {
      final leagues = await supabaseClient.from('leagues').select();
      return leagues.map((league) => LeagueModel.fromJson(league)).toList();
    } on PostgrestException catch (e) {
      throw ServerException(e.message);
    } catch (e) {
      throw ServerException(e.toString());
    }
  }

  @override
  Future<LeagueModel> updateLeague(LeagueModel league) async {
    try {
      final leagueData = await supabaseClient
          .from('leagues')
          .update(league.toJson())
          .eq('id', league.id)
          .select();
      return LeagueModel.fromJson(leagueData.first);
    } on PostgrestException catch (e) {
      throw ServerException(e.message);
    } catch (e) {
      throw ServerException(e.toString());
    }
  }

  @override
  Future<LeagueModel> deleteLeague({required String leagueId}) async {
    try {
      await supabaseClient.storage.from('leagues').remove([leagueId]);
      final leagueData = await supabaseClient
          .from('leagues')
          .delete()
          .eq('id', leagueId)
          .select();
      return LeagueModel.fromJson(leagueData.first);
    } on PostgrestException catch (e) {
      throw ServerException(e.message);
    } catch (e) {
      throw ServerException(e.toString());
    }
  }
}
