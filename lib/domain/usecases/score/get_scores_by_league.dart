import 'package:dartz/dartz.dart';
import 'package:real_amis/core/errors/failure.dart';
import 'package:real_amis/core/usecase/usecase.dart';
import 'package:real_amis/domain/entities/score/score_entity.dart';
import 'package:real_amis/domain/repositories/score/score_repository.dart';

class GetScoresByLeague implements UseCase<List<ScoreEntity>, LeagueIdParams> {
  final ScoreRepository repository;
  GetScoresByLeague(this.repository);

  @override
  Future<Either<Failure, List<ScoreEntity>>> call(LeagueIdParams params) {
    return repository.getScoresByLeague(leagueId: params.leagueId);
  }
}

class LeagueIdParams {
  final String leagueId;
  LeagueIdParams(this.leagueId);
}
