import 'package:dartz/dartz.dart';
import 'package:real_amis/core/errors/failure.dart';
import 'package:real_amis/domain/entities/league/league_entity.dart';

abstract interface class LeagueRepository {
  Future<Either<Failure, LeagueEntity>> uploadLeague({
    required String name,
    required String year,
  });

  Future<Either<Failure, List<LeagueEntity>>> getAllLeagues();

  Future<Either<Failure, LeagueEntity>> updateLeague({
    required LeagueEntity league,
    String? name,
    String? year,
  });

  Future<Either<Failure, LeagueEntity>> deleteLeague({
    required String leagueId,
  });
}
