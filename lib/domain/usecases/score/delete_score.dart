import 'package:dartz/dartz.dart';
import 'package:real_amis/core/errors/failure.dart';
import 'package:real_amis/core/usecase/usecase.dart';
import 'package:real_amis/domain/entities/score/score_entity.dart';
import 'package:real_amis/domain/repositories/score/score_repository.dart';

class DeleteScore implements UseCase<ScoreEntity, String> {
  final ScoreRepository scoreRepository;
  DeleteScore(this.scoreRepository);

  @override
  Future<Either<Failure, ScoreEntity>> call(String scoreId) async {
    return await scoreRepository.deleteScore(scoreId: scoreId);
  }
}
