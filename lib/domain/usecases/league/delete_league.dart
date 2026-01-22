import 'package:dartz/dartz.dart';
import 'package:real_amis/core/errors/failure.dart';
import 'package:real_amis/core/usecase/usecase.dart';
import 'package:real_amis/domain/entities/league/league_entity.dart';
import 'package:real_amis/domain/repositories/league/league_repository.dart';

class DeleteLeague implements UseCase<LeagueEntity, String> {
  final LeagueRepository leagueRepository;
  DeleteLeague(this.leagueRepository);

  @override
  Future<Either<Failure, LeagueEntity>> call(String leagueId) async {
    return await leagueRepository.deleteLeague(leagueId: leagueId);
  }
}
