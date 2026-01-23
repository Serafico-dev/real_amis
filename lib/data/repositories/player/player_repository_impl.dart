import 'dart:io';

import 'package:dartz/dartz.dart';
import 'package:real_amis/core/constants/constants.dart';
import 'package:real_amis/core/errors/exceptions.dart';
import 'package:real_amis/core/errors/failure.dart';
import 'package:real_amis/core/network/connection_checker.dart';
import 'package:real_amis/data/models/player/player_model.dart';
import 'package:real_amis/data/sources/player/player_local_data_source.dart';
import 'package:real_amis/data/sources/player/player_supabase_data_source.dart';
import 'package:real_amis/domain/entities/player/player_entity.dart';
import 'package:real_amis/domain/entities/player/player_role.dart';
import 'package:real_amis/domain/repositories/player/player_repository.dart';
import 'package:uuid/uuid.dart';

class PlayerRepositoryImpl implements PlayerRepository {
  final PlayerSupabaseDataSource playerSupabaseDataSource;
  final PlayerLocalDataSource playerLocalDataSource;
  final ConnectionChecker connectionChecker;

  PlayerRepositoryImpl(
    this.playerSupabaseDataSource,
    this.playerLocalDataSource,
    this.connectionChecker,
  );

  @override
  Future<Either<Failure, PlayerEntity>> uploadPlayer({
    required String userName,
    required String fullName,
    required File image,
    required PlayerRole role,
    int? attendances,
    int? goals,
    int? yellowCards,
    int? redCards,
    required bool active,
    DateTime? birthday,
  }) async {
    try {
      if (!await (connectionChecker.isConnected)) {
        return left(Failure(Constants.noConnectionErrorMessage));
      }
      PlayerModel playerModel = PlayerModel(
        id: Uuid().v1(),
        updatedAt: DateTime.now(),
        userName: userName,
        fullName: fullName,
        imageUrl: '',
        role: role,
        attendances: attendances,
        goals: goals,
        yellowCards: yellowCards,
        redCards: redCards,
        active: active,
        birthday: birthday,
      );

      final imageUrl = await playerSupabaseDataSource.uploadPlayerImage(
        image: image,
        player: playerModel,
      );

      playerModel = playerModel.copyWith(imageUrl: imageUrl);
      final uploadedPlayer = await playerSupabaseDataSource.uploadPlayer(
        playerModel,
      );
      return right(uploadedPlayer);
    } on ServerException catch (e) {
      return left(Failure(e.message));
    }
  }

  @override
  Future<Either<Failure, List<PlayerEntity>>> getAllPlayers() async {
    try {
      if (!await (connectionChecker.isConnected)) {
        final players = playerLocalDataSource.loadPlayers();
        return right(players);
      }
      final players = await playerSupabaseDataSource.getAllPlayers();
      playerLocalDataSource.uploadLocalPlayers(players: players);
      return right(players);
    } on ServerException catch (e) {
      return left(Failure(e.message));
    }
  }

  @override
  Future<Either<Failure, PlayerEntity>> updatePlayer({
    required PlayerEntity player,
    String? userName,
    String? fullName,
    File? image,
    PlayerRole? role,
    int? attendances,
    int? goals,
    int? yellowCards,
    int? redCards,
    bool? active,
    DateTime? birthday,
  }) async {
    try {
      if (!await (connectionChecker.isConnected)) {
        return left(Failure(Constants.noConnectionErrorMessage));
      }
      PlayerModel playerModel = PlayerModel(
        id: player.id,
        updatedAt: DateTime.now(),
        userName: userName ?? player.userName,
        fullName: fullName ?? player.fullName,
        imageUrl: player.imageUrl,
        role: role ?? player.role,
        attendances: attendances ?? player.attendances,
        goals: goals ?? player.goals,
        yellowCards: yellowCards ?? player.yellowCards,
        redCards: redCards ?? player.redCards,
        active: active ?? player.active,
        birthday: birthday ?? player.birthday,
      );

      final imageUrl = await playerSupabaseDataSource.updatePlayerImage(
        image: image,
        player: playerModel,
      );

      playerModel = playerModel.copyWith(imageUrl: imageUrl);
      final updatedPlayer = await playerSupabaseDataSource.updatePlayer(
        playerModel,
      );
      return right(updatedPlayer);
    } on ServerException catch (e) {
      return left(Failure(e.message));
    }
  }

  @override
  Future<Either<Failure, PlayerEntity>> deletePlayer({
    required String playerId,
  }) async {
    try {
      if (!await (connectionChecker.isConnected)) {
        return left(Failure(Constants.noConnectionErrorMessage));
      }
      final deletedPlayer = await playerSupabaseDataSource.deletePlayer(
        playerId: playerId,
      );
      return right(deletedPlayer);
    } on ServerException catch (e) {
      return left(Failure(e.message));
    }
  }
}
