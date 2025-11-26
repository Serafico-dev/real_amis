import 'package:dartz/dartz.dart';
import 'package:real_amis/core/errors/failure.dart';
import 'package:real_amis/core/usecase/usecase.dart';
import 'package:real_amis/domain/entities/team/team_entity.dart';
import 'package:real_amis/domain/repositories/team/team_repository.dart';

class GetAllTeams implements UseCase<List<TeamEntity>, NoParams> {
  final TeamRepository teamRepository;
  GetAllTeams(this.teamRepository);

  @override
  Future<Either<Failure, List<TeamEntity>>> call(NoParams params) async {
    return await teamRepository.getAllTeams();
  }
}
