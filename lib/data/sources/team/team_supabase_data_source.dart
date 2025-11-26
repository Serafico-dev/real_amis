import 'dart:io';

import 'package:real_amis/core/errors/exceptions.dart';
import 'package:real_amis/data/models/team/team_model.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

abstract interface class TeamSupabaseDataSource {
  Future<TeamModel> uploadTeam(TeamModel team);
  Future<String> uploadTeamImage({
    required File image,
    required TeamModel team,
  });
  Future<List<TeamModel>> getAllTeams();
  Future<TeamModel> updateTeam(TeamModel team);
  Future<String> updateTeamImage({File? image, required TeamModel team});
  Future<TeamModel> deleteTeam({required String teamId});
}

class TeamSupabaseDataSourceImpl implements TeamSupabaseDataSource {
  final SupabaseClient supabaseClient;
  TeamSupabaseDataSourceImpl(this.supabaseClient);

  @override
  Future<TeamModel> uploadTeam(TeamModel team) async {
    try {
      final teamData = await supabaseClient
          .from('teams')
          .insert(team.toJson())
          .select();
      return TeamModel.fromJson(teamData.first);
    } on PostgrestException catch (e) {
      throw ServerException(e.message);
    } catch (e) {
      throw ServerException(e.toString());
    }
  }

  @override
  Future<String> uploadTeamImage({
    required File image,
    required TeamModel team,
  }) async {
    try {
      await supabaseClient.storage.from('teams').upload(team.id, image);
      return supabaseClient.storage.from('teams').getPublicUrl(team.id);
    } on StorageException catch (e) {
      throw ServerException(e.message);
    } catch (e) {
      throw ServerException(e.toString());
    }
  }

  @override
  Future<List<TeamModel>> getAllTeams() async {
    try {
      final teams = await supabaseClient.from('teams').select();
      return teams.map((team) => TeamModel.fromJson(team)).toList();
    } on PostgrestException catch (e) {
      throw ServerException(e.message);
    } catch (e) {
      throw ServerException(e.toString());
    }
  }

  @override
  Future<TeamModel> updateTeam(TeamModel team) async {
    try {
      final teamData = await supabaseClient
          .from('teams')
          .update(team.toJson())
          .eq('id', team.id)
          .select();
      return TeamModel.fromJson(teamData.first);
    } on PostgrestException catch (e) {
      throw ServerException(e.message);
    } catch (e) {
      throw ServerException(e.toString());
    }
  }

  @override
  Future<String> updateTeamImage({File? image, required TeamModel team}) async {
    try {
      if (image != null) {
        await supabaseClient.storage.from('teams').upload(team.id, image);
        return supabaseClient.storage.from('teams').getPublicUrl(team.id);
      } else {
        final res = await supabaseClient
            .from('teams')
            .select('image_url')
            .eq('id', team.id);
        return res.first['image_url'];
      }
    } on StorageException catch (e) {
      throw ServerException(e.message);
    } catch (e) {
      throw ServerException(e.toString());
    }
  }

  @override
  Future<TeamModel> deleteTeam({required String teamId}) async {
    try {
      await supabaseClient.storage.from('teams').remove([teamId]);
      final teamData = await supabaseClient
          .from('teams')
          .delete()
          .eq('id', teamId)
          .select();
      return TeamModel.fromJson(teamData.first);
    } on PostgrestException catch (e) {
      throw ServerException(e.message);
    } catch (e) {
      throw ServerException(e.toString());
    }
  }
}
