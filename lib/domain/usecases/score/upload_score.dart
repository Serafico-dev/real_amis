import 'package:dartz/dartz.dart';
import 'package:real_amis/core/errors/failure.dart';
import 'package:real_amis/core/usecase/usecase.dart';
import 'package:real_amis/domain/entities/score/score_entity.dart';
import 'package:real_amis/domain/repositories/score/score_repository.dart';

class UploadScore implements UseCase<ScoreEntity, UploadScoreParams> {
  final ScoreRepository scoreRepository;
  UploadScore(this.scoreRepository);

  @override
  Future<Either<Failure, ScoreEntity>> call(UploadScoreParams params) async {
    return await scoreRepository.uploadScore(
      leagueId: params.leagueId,
      teamId: params.teamId,
      score: params.score,
    );
  }
}

class UploadScoreParams {
  final String leagueId;
  final String teamId;
  final int score;

  UploadScoreParams({
    required this.leagueId,
    required this.teamId,
    required this.score,
  });
}
