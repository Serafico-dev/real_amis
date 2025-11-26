import 'dart:io';

import 'package:dartz/dartz.dart';
import 'package:real_amis/core/errors/failure.dart';
import 'package:real_amis/core/usecase/usecase.dart';
import 'package:real_amis/domain/entities/player/player_entity.dart';
import 'package:real_amis/domain/entities/player/player_role.dart';
import 'package:real_amis/domain/repositories/player/player_repository.dart';

class UploadPlayer implements UseCase<PlayerEntity, UploadPlayerParams> {
  final PlayerRepository playerRepository;
  UploadPlayer(this.playerRepository);

  @override
  Future<Either<Failure, PlayerEntity>> call(UploadPlayerParams params) async {
    return await playerRepository.uploadPlayer(
      userName: params.userName,
      fullName: params.fullName,
      image: params.image,
      role: params.role,
      attendances: params.attendances,
      goals: params.goals,
      yellowCards: params.yellowCards,
      redCards: params.redCards,
      active: params.active,
    );
  }
}

class UploadPlayerParams {
  final String userName;
  final String fullName;
  final File image;
  final PlayerRole role;
  final int? attendances;
  final int? goals;
  final int? yellowCards;
  final int? redCards;
  final bool active;

  UploadPlayerParams({
    required this.userName,
    required this.fullName,
    required this.image,
    required this.role,
    this.attendances,
    this.goals,
    this.yellowCards,
    this.redCards,
    required this.active,
  });
}
