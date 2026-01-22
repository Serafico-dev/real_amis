import 'package:dartz/dartz.dart';
import 'package:real_amis/core/errors/failure.dart';
import 'package:real_amis/core/usecase/usecase.dart';
import 'package:real_amis/domain/entities/league/league_entity.dart';
import 'package:real_amis/domain/repositories/league/league_repository.dart';

class GetAllLeagues implements UseCase<List<LeagueEntity>, NoParams> {
  final LeagueRepository leagueRepository;
  GetAllLeagues(this.leagueRepository);

  @override
  Future<Either<Failure, List<LeagueEntity>>> call(NoParams params) async {
    return await leagueRepository.getAllLeagues();
  }
}
