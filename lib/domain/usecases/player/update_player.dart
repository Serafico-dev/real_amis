import 'dart:io';

import 'package:dartz/dartz.dart';
import 'package:real_amis/core/errors/failure.dart';
import 'package:real_amis/core/notifications/birthday_notification_service.dart';
import 'package:real_amis/core/usecase/usecase.dart';
import 'package:real_amis/domain/entities/player/player_entity.dart';
import 'package:real_amis/domain/entities/player/player_role.dart';
import 'package:real_amis/domain/repositories/player/player_repository.dart';

class UpdatePlayer implements UseCase<PlayerEntity, UpdatePlayerParams> {
  final PlayerRepository playerRepository;
  final BirthdayNotificationService birthdayService;

  UpdatePlayer(this.playerRepository, this.birthdayService);

  @override
  Future<Either<Failure, PlayerEntity>> call(UpdatePlayerParams params) async {
    final oldBirthday = params.player.birthday;

    final result = await playerRepository.updatePlayer(
      player: params.player,
      userName: params.userName,
      fullName: params.fullName,
      image: params.image,
      role: params.role,
      attendances: params.attendances,
      goals: params.goals,
      yellowCards: params.yellowCards,
      redCards: params.redCards,
      active: params.active,
      birthday: params.birthday,
    );

    return await result.fold((failure) async => Left(failure), (player) async {
      final newBirthday = player.birthday;

      if (newBirthday == null) {
        await birthdayService.cancel(player.id);
      } else if (oldBirthday != newBirthday) {
        await birthdayService.scheduleBirthday(
          playerId: player.id,
          fullName: player.fullName,
          birthday: newBirthday,
        );
      }

      return Right(player);
    });
  }
}

class UpdatePlayerParams {
  final PlayerEntity player;
  final String? userName;
  final String? fullName;
  final File? image;
  final PlayerRole? role;
  final int? attendances;
  final int? goals;
  final int? yellowCards;
  final int? redCards;
  final bool? active;
  final DateTime? birthday;

  UpdatePlayerParams({
    required this.player,
    this.userName,
    this.fullName,
    this.image,
    this.role,
    this.attendances,
    this.goals,
    this.yellowCards,
    this.redCards,
    this.active,
    this.birthday,
  });
}
