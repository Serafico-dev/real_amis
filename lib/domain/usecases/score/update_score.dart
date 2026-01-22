import 'package:dartz/dartz.dart';
import 'package:real_amis/core/errors/failure.dart';
import 'package:real_amis/core/usecase/usecase.dart';
import 'package:real_amis/domain/entities/score/score_entity.dart';
import 'package:real_amis/domain/repositories/score/score_repository.dart';

class UpdateScore implements UseCase<ScoreEntity, UpdateScoreParams> {
  final ScoreRepository scoreRepository;
  UpdateScore(this.scoreRepository);

  @override
  Future<Either<Failure, ScoreEntity>> call(UpdateScoreParams params) async {
    return await scoreRepository.updateScore(
      scoreEntity: params.scoreEntity,
      leagueId: params.leagueId,
      teamId: params.teamId,
      score: params.score,
    );
  }
}

class UpdateScoreParams {
  final ScoreEntity scoreEntity;
  final String? leagueId;
  final String? teamId;
  final int? score;

  UpdateScoreParams({
    required this.scoreEntity,
    this.leagueId,
    this.teamId,
    this.score,
  });
}
