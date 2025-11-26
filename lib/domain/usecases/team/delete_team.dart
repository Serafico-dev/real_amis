import 'package:dartz/dartz.dart';
import 'package:real_amis/core/errors/failure.dart';
import 'package:real_amis/core/usecase/usecase.dart';
import 'package:real_amis/domain/entities/team/team_entity.dart';
import 'package:real_amis/domain/repositories/team/team_repository.dart';

class DeleteTeam implements UseCase<TeamEntity, String> {
  final TeamRepository teamRepository;
  DeleteTeam(this.teamRepository);

  @override
  Future<Either<Failure, TeamEntity>> call(String teamId) async {
    return await teamRepository.deleteTeam(teamId: teamId);
  }
}
