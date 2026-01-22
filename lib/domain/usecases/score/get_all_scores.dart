import 'package:dartz/dartz.dart';
import 'package:real_amis/core/errors/failure.dart';
import 'package:real_amis/core/usecase/usecase.dart';
import 'package:real_amis/domain/entities/score/score_entity.dart';
import 'package:real_amis/domain/repositories/score/score_repository.dart';

class GetAllScores implements UseCase<List<ScoreEntity>, NoParams> {
  final ScoreRepository scoreRepository;
  GetAllScores(this.scoreRepository);

  @override
  Future<Either<Failure, List<ScoreEntity>>> call(NoParams params) async {
    return await scoreRepository.getAllScores();
  }
}
