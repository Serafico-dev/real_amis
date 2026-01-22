import 'package:dartz/dartz.dart';
import 'package:real_amis/core/errors/failure.dart';
import 'package:real_amis/domain/entities/score/score_entity.dart';

abstract interface class ScoreRepository {
  Future<Either<Failure, ScoreEntity>> uploadScore({
    required String leagueId,
    required String teamId,
    required int score,
  });

  Future<Either<Failure, List<ScoreEntity>>> getAllScores();

  Future<Either<Failure, List<ScoreEntity>>> getScoresByLeague({
    required String leagueId,
  });

  Future<Either<Failure, ScoreEntity>> updateScore({
    required ScoreEntity scoreEntity,
    String? leagueId,
    String? teamId,
    int? score,
  });

  Future<Either<Failure, ScoreEntity>> deleteScore({required String scoreId});
}
