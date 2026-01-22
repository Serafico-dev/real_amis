import 'package:dartz/dartz.dart';
import 'package:real_amis/core/errors/failure.dart';
import 'package:real_amis/core/usecase/usecase.dart';
import 'package:real_amis/domain/entities/league/league_entity.dart';
import 'package:real_amis/domain/repositories/league/league_repository.dart';

class UpdateLeague implements UseCase<LeagueEntity, UpdateLeagueParams> {
  final LeagueRepository leagueRepository;
  UpdateLeague(this.leagueRepository);

  @override
  Future<Either<Failure, LeagueEntity>> call(UpdateLeagueParams params) async {
    return await leagueRepository.updateLeague(
      league: params.league,
      name: params.name,
      year: params.year,
    );
  }
}

class UpdateLeagueParams {
  final LeagueEntity league;
  final String? name;
  final String? year;

  UpdateLeagueParams({required this.league, this.name, this.year});
}
