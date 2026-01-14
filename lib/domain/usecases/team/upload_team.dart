import 'dart:io';

import 'package:dartz/dartz.dart';
import 'package:real_amis/core/errors/failure.dart';
import 'package:real_amis/core/usecase/usecase.dart';
import 'package:real_amis/domain/entities/team/team_entity.dart';
import 'package:real_amis/domain/repositories/team/team_repository.dart';

class UploadTeam implements UseCase<TeamEntity, UploadTeamParams> {
  final TeamRepository teamRepository;
  UploadTeam(this.teamRepository);

  @override
  Future<Either<Failure, TeamEntity>> call(UploadTeamParams params) async {
    return await teamRepository.uploadTeam(
      name: params.name,
      image: params.image,
      score: params.score,
    );
  }
}

class UploadTeamParams {
  final String name;
  final File image;
  final int? score;

  UploadTeamParams({required this.name, required this.image, this.score});
}
