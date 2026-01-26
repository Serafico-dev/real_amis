import 'package:real_amis/core/errors/exceptions.dart';
import 'package:real_amis/data/models/league/league_model.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

abstract interface class LeagueSupabaseDataSource {
  Future<LeagueModel> uploadLeague(LeagueModel league);
  Future<List<LeagueModel>> getAllLeagues();
  Future<LeagueModel> updateLeague(LeagueModel league);
  Future<LeagueModel> deleteLeague({required String leagueId});

  Future<List<String>> getTeamIdsByLeague(String leagueId);
  Future<void> addTeamToLeague(String leagueId, String teamId);
  Future<void> removeTeamFromLeague(String leagueId, String teamId);
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
      return (leagues as List)
          .map((league) => LeagueModel.fromJson(league))
          .toList();
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

  @override
  Future<List<String>> getTeamIdsByLeague(String leagueId) async {
    try {
      final response = await supabaseClient
          .from('league_teams')
          .select('team_id')
          .eq('league_id', leagueId);
      return (response as List).map((e) => e['team_id'] as String).toList();
    } on PostgrestException catch (e) {
      throw ServerException(e.message);
    } catch (e) {
      throw ServerException(e.toString());
    }
  }

  @override
  Future<void> addTeamToLeague(String leagueId, String teamId) async {
    try {
      await supabaseClient.from('league_teams').insert({
        'league_id': leagueId,
        'team_id': teamId,
      });
    } on PostgrestException catch (e) {
      throw ServerException(e.message);
    } catch (e) {
      throw ServerException(e.toString());
    }
  }

  @override
  Future<void> removeTeamFromLeague(String leagueId, String teamId) async {
    try {
      await supabaseClient
          .from('league_teams')
          .delete()
          .eq('league_id', leagueId)
          .eq('team_id', teamId);
    } on PostgrestException catch (e) {
      throw ServerException(e.message);
    } catch (e) {
      throw ServerException(e.toString());
    }
  }
}
