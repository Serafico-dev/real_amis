import 'package:dartz/dartz.dart';
import 'package:real_amis/core/constants/constants.dart';
import 'package:real_amis/core/errors/exceptions.dart';
import 'package:real_amis/core/errors/failure.dart';
import 'package:real_amis/core/network/connection_checker.dart';
import 'package:real_amis/data/models/score/score_model.dart';
import 'package:real_amis/data/sources/score/score_local_data_source.dart';
import 'package:real_amis/data/sources/score/score_supabase_data_source.dart';
import 'package:real_amis/domain/entities/score/score_entity.dart';
import 'package:real_amis/domain/repositories/score/score_repository.dart';
import 'package:uuid/uuid.dart';

class ScoreRepositoryImpl implements ScoreRepository {
  final ScoreSupabaseDataSource scoreSupabaseDataSource;
  final ScoreLocalDataSource scoreLocalDataSource;
  final ConnectionChecker connectionChecker;

  ScoreRepositoryImpl(
    this.scoreSupabaseDataSource,
    this.scoreLocalDataSource,
    this.connectionChecker,
  );

  @override
  Future<Either<Failure, ScoreEntity>> uploadScore({
    required String leagueId,
    required String teamId,
    required int score,
  }) async {
    try {
      if (!await (connectionChecker.isConnected)) {
        return left(Failure(Constants.noConnectionErrorMessage));
      }
      ScoreModel scoreModel = ScoreModel(
        id: Uuid().v1(),
        leagueId: leagueId,
        teamId: teamId,
        score: score,
      );
      await scoreSupabaseDataSource.uploadScore(scoreModel);
      return right(scoreModel);
    } on ServerException catch (e) {
      return left(Failure(e.message));
    }
  }

  @override
  Future<Either<Failure, List<ScoreEntity>>> getAllScores() async {
    try {
      if (!await (connectionChecker.isConnected)) {
        final scores = scoreLocalDataSource.loadScores();
        return right(scores);
      }
      final scores = await scoreSupabaseDataSource.getAllScores();
      scoreLocalDataSource.uploadLocalScores(scores: scores);
      return right(scores);
    } on ServerException catch (e) {
      return left(Failure(e.message));
    }
  }

  @override
  Future<Either<Failure, List<ScoreEntity>>> getScoresByLeague({
    required String leagueId,
  }) async {
    try {
      if (!await connectionChecker.isConnected) {
        final scores = scoreLocalDataSource.loadScoresByLeague(
          leagueId: leagueId,
        );
        return right(scores);
      }

      final scores = await scoreSupabaseDataSource.getScoresByLeague(
        leagueId: leagueId,
      );

      scoreLocalDataSource.uploadLocalScores(scores: scores);

      return right(scores);
    } on ServerException catch (e) {
      return left(Failure(e.message));
    }
  }

  @override
  Future<Either<Failure, ScoreEntity>> updateScore({
    required ScoreEntity scoreEntity,
    String? leagueId,
    String? teamId,
    int? score,
  }) async {
    try {
      if (!await (connectionChecker.isConnected)) {
        return left(Failure(Constants.noConnectionErrorMessage));
      }
      ScoreModel scoreModel = ScoreModel(
        id: scoreEntity.id,
        leagueId: leagueId ?? scoreEntity.leagueId,
        teamId: teamId ?? scoreEntity.teamId,
        score: score ?? scoreEntity.score,
      );
      await scoreSupabaseDataSource.updateScore(scoreModel);
      return right(scoreModel);
    } on ServerException catch (e) {
      return left(Failure(e.message));
    }
  }

  @override
  Future<Either<Failure, ScoreEntity>> deleteScore({
    required String scoreId,
  }) async {
    try {
      if (!await (connectionChecker.isConnected)) {
        return left(Failure(Constants.noConnectionErrorMessage));
      }
      final deletedScore = await scoreSupabaseDataSource.deleteScore(
        scoreId: scoreId,
      );
      return right(deletedScore);
    } on ServerException catch (e) {
      return left(Failure(e.message));
    }
  }
}
