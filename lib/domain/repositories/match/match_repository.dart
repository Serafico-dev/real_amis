import 'package:dartz/dartz.dart';
import 'package:real_amis/core/errors/failure.dart';
import 'package:real_amis/domain/entities/match/match_entity.dart';

abstract interface class MatchRepository {
  Future<Either<Failure, MatchEntity>> uploadMatch({
    required DateTime matchDate,
    required String homeTeamId,
    required String awayTeamId,
    String? matchDay,
    required String leagueId,
  });

  Future<Either<Failure, List<MatchEntity>>> getAllMatches();

  Future<Either<Failure, MatchEntity>> updateMatch({
    required MatchEntity match,
    DateTime? matchDate,
    String? homeTeamId,
    String? awayTeamId,
    String? matchDay,
    String? leagueId,
  });

  Future<Either<Failure, MatchEntity>> deleteMatch({required String matchId});
}
