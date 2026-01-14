import 'dart:io';

import 'package:dartz/dartz.dart';
import 'package:real_amis/core/errors/failure.dart';
import 'package:real_amis/domain/entities/team/team_entity.dart';

abstract interface class TeamRepository {
  Future<Either<Failure, TeamEntity>> uploadTeam({
    required String name,
    required File image,
    int? score,
  });

  Future<Either<Failure, List<TeamEntity>>> getAllTeams();

  Future<Either<Failure, TeamEntity>> updateTeam({
    required TeamEntity team,
    String? name,
    File? image,
    int? score,
  });

  Future<Either<Failure, TeamEntity>> deleteTeam({required String teamId});
}
