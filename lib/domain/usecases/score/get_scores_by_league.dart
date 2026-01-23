import 'package:dartz/dartz.dart';
import 'package:real_amis/core/errors/failure.dart';
import 'package:real_amis/core/usecase/usecase.dart';
import 'package:real_amis/domain/entities/score/score_entity.dart';
import 'package:real_amis/domain/repositories/score/score_repository.dart';

class GetScoresByLeague
    implements UseCase<List<ScoreEntity>, GetScoresByLeagueParams> {
  final ScoreRepository repository;
  GetScoresByLeague(this.repository);

  @override
  Future<Either<Failure, List<ScoreEntity>>> call(
    GetScoresByLeagueParams params,
  ) {
    return repository.getScoresByLeague(leagueId: params.leagueId);
  }
}

class GetScoresByLeagueParams {
  final String leagueId;
  GetScoresByLeagueParams({required this.leagueId});
}
