import 'dart:io';

import 'package:real_amis/core/errors/exceptions.dart';
import 'package:real_amis/data/models/player/player_model.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

abstract interface class PlayerSupabaseDataSource {
  Future<PlayerModel> uploadPlayer(PlayerModel player);
  Future<String> uploadPlayerImage({
    required File image,
    required PlayerModel player,
  });
  Future<List<PlayerModel>> getAllPlayers();
  Future<PlayerModel> updatePlayer(PlayerModel player);
  Future<String> updatePlayerImage({File? image, required PlayerModel player});
  Future<PlayerModel> deletePlayer({required String playerId});
}

class PlayerSupabaseDataSourceImpl implements PlayerSupabaseDataSource {
  final SupabaseClient supabaseClient;
  PlayerSupabaseDataSourceImpl(this.supabaseClient);

  @override
  Future<PlayerModel> uploadPlayer(PlayerModel player) async {
    try {
      final playerData = await supabaseClient
          .from('players')
          .insert(player.toJson())
          .select();
      return PlayerModel.fromJson(playerData.first);
    } on PostgrestException catch (e) {
      throw ServerException(e.message);
    } catch (e) {
      throw ServerException(e.toString());
    }
  }

  @override
  Future<String> uploadPlayerImage({
    required File image,
    required PlayerModel player,
  }) async {
    try {
      await supabaseClient.storage
          .from('player_image')
          .upload(player.id, image);
      return supabaseClient.storage
          .from('player_image')
          .getPublicUrl(player.id);
    } on StorageException catch (e) {
      throw ServerException(e.message);
    } catch (e) {
      throw ServerException(e.toString());
    }
  }

  @override
  Future<List<PlayerModel>> getAllPlayers() async {
    try {
      final players = await supabaseClient.from('players').select();
      return players.map((player) => PlayerModel.fromJson(player)).toList();
    } on PostgrestException catch (e) {
      throw ServerException(e.message);
    } catch (e) {
      throw ServerException(e.toString());
    }
  }

  @override
  Future<PlayerModel> updatePlayer(PlayerModel player) async {
    try {
      final playerData = await supabaseClient
          .from('players')
          .update(player.toJson())
          .eq('id', player.id)
          .select();
      return PlayerModel.fromJson(playerData.first);
    } on PostgrestException catch (e) {
      throw ServerException(e.message);
    } catch (e) {
      throw ServerException(e.toString());
    }
  }

  @override
  Future<String> updatePlayerImage({
    File? image,
    required PlayerModel player,
  }) async {
    try {
      if (image != null) {
        await supabaseClient.storage
            .from('player_image')
            .upload(player.id, image);
        return supabaseClient.storage
            .from('player_image')
            .getPublicUrl(player.id);
      } else {
        final res = await supabaseClient
            .from('players')
            .select('image_url')
            .eq('id', player.id);
        return res.first['image_url'];
      }
    } on StorageException catch (e) {
      throw ServerException(e.message);
    } catch (e) {
      throw ServerException(e.toString());
    }
  }

  @override
  Future<PlayerModel> deletePlayer({required String playerId}) async {
    try {
      await supabaseClient.storage.from('players').remove([playerId]);
      final playerData = await supabaseClient
          .from('players')
          .delete()
          .eq('id', playerId)
          .select();
      return PlayerModel.fromJson(playerData.first);
    } on PostgrestException catch (e) {
      throw ServerException(e.message);
    } catch (e) {
      throw ServerException(e.toString());
    }
  }
}
