import 'dart:io';

import 'package:dartz/dartz.dart';
import 'package:real_amis/core/errors/failure.dart';
import 'package:real_amis/domain/entities/player/player_entity.dart';
import 'package:real_amis/domain/entities/player/player_role.dart';

abstract interface class PlayerRepository {
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
  });

  Future<Either<Failure, List<PlayerEntity>>> getAllPlayers();

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
  });

  Future<Either<Failure, PlayerEntity>> deletePlayer({
    required String playerId,
  });
}
