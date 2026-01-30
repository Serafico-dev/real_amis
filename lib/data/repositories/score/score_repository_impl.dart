import 'package:dartz/dartz.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:real_amis/core/constants/constants.dart';
import 'package:real_amis/core/errors/exceptions.dart';
import 'package:real_amis/core/errors/failure.dart';
import 'package:real_amis/core/network/connection_checker.dart';
import 'package:real_amis/core/providers/connection_checker_provider.dart';
import 'package:real_amis/data/models/score/score_model.dart';
import 'package:real_amis/data/sources/score/score_local_data_source.dart';
import 'package:real_amis/data/sources/score/score_supabase_data_source.dart';
import 'package:real_amis/domain/entities/score/score_entity.dart';
import 'package:real_amis/domain/repositories/score/score_repository.dart';
import 'package:uuid/uuid.dart';

final scoreRepositoryProvider = Provider<ScoreRepository>((ref) {
  return ScoreRepositoryImpl(
    ref.read(scoreSupabaseDataSourceProvider),
    ref.read(scoreLocalDataSourceProvider),
    ref.read(connectionCheckerProvider),
  );
});

class ScoreRepositoryImpl implements ScoreRepository {
  final ScoreSupabaseDataSource scoreSupabaseDataSource;
  final ScoreLocalDataSource scoreLocalDataSource;
  final ConnectionChecker connectionChecker;

  ScoreRepositoryImpl(
    this.scoreSupabaseDataSource,
    this.scoreLocalDataSource,
    this.connectionChecker,
  );

  ScoreEntity _toEntity(ScoreModel model) {
    return ScoreEntity(
      id: model.id,
      leagueId: model.leagueId,
      teamId: model.teamId,
      score: model.score,
    );
  }

  @override
  Future<Either<Failure, ScoreEntity>> uploadScore({
    required String leagueId,
    required String teamId,
    required int score,
  }) async {
    try {
      if (!await connectionChecker.isConnected) {
        return left(Failure(Constants.noConnectionErrorMessage));
      }

      final scoreModel = ScoreModel(
        id: Uuid().v1(),
        leagueId: leagueId,
        teamId: teamId,
        score: score,
      );

      final uploadedScore = await scoreSupabaseDataSource.uploadScore(
        scoreModel,
      );
      return right(_toEntity(uploadedScore));
    } on ServerException catch (e) {
      return left(Failure(e.message));
    }
  }

  @override
  Future<Either<Failure, List<ScoreEntity>>> getAllScores() async {
    try {
      List<ScoreModel> scores;
      if (!await connectionChecker.isConnected) {
        scores = scoreLocalDataSource.loadScores();
      } else {
        scores = await scoreSupabaseDataSource.getAllScores();
        scoreLocalDataSource.uploadLocalScores(scores: scores);
      }

      return right(scores.map(_toEntity).toList());
    } on ServerException catch (e) {
      return left(Failure(e.message));
    }
  }

  @override
  Future<Either<Failure, List<ScoreEntity>>> getScoresByLeague({
    required String leagueId,
  }) async {
    try {
      List<ScoreModel> scores;
      if (!await connectionChecker.isConnected) {
        scores = scoreLocalDataSource.loadScoresByLeague(leagueId: leagueId);
      } else {
        scores = await scoreSupabaseDataSource.getScoresByLeague(
          leagueId: leagueId,
        );
        scoreLocalDataSource.uploadLocalScores(scores: scores);
      }

      return right(scores.map(_toEntity).toList());
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
      if (!await connectionChecker.isConnected) {
        return left(Failure(Constants.noConnectionErrorMessage));
      }

      final scoreModel = ScoreModel(
        id: scoreEntity.id,
        leagueId: leagueId ?? scoreEntity.leagueId,
        teamId: teamId ?? scoreEntity.teamId,
        score: score ?? scoreEntity.score,
      );

      final updatedScore = await scoreSupabaseDataSource.updateScore(
        scoreModel,
      );
      return right(_toEntity(updatedScore));
    } on ServerException catch (e) {
      return left(Failure(e.message));
    }
  }

  @override
  Future<Either<Failure, ScoreEntity>> deleteScore({
    required String scoreId,
  }) async {
    try {
      if (!await connectionChecker.isConnected) {
        return left(Failure(Constants.noConnectionErrorMessage));
      }

      final deletedScore = await scoreSupabaseDataSource.deleteScore(
        scoreId: scoreId,
      );
      return right(_toEntity(deletedScore));
    } on ServerException catch (e) {
      return left(Failure(e.message));
    }
  }
}
