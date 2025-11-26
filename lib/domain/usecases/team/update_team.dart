import 'dart:io';

import 'package:dartz/dartz.dart';
import 'package:real_amis/core/errors/failure.dart';
import 'package:real_amis/core/usecase/usecase.dart';
import 'package:real_amis/domain/entities/team/team_entity.dart';
import 'package:real_amis/domain/repositories/team/team_repository.dart';

class UpdateTeam implements UseCase<TeamEntity, UpdateTeamParams> {
  final TeamRepository teamRepository;
  UpdateTeam(this.teamRepository);

  @override
  Future<Either<Failure, TeamEntity>> call(UpdateTeamParams params) async {
    return await teamRepository.updateTeam(
      team: params.team,
      name: params.name,
      image: params.image,
    );
  }
}

class UpdateTeamParams {
  final TeamEntity team;
  final String? name;
  final File? image;

  UpdateTeamParams({required this.team, required this.name, this.image});
}
