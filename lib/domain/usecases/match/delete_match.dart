import 'package:dartz/dartz.dart';
import 'package:real_amis/core/errors/failure.dart';
import 'package:real_amis/core/usecase/usecase.dart';
import 'package:real_amis/domain/entities/match/match_entity.dart';
import 'package:real_amis/domain/repositories/match/match_repository.dart';

class DeleteMatch implements UseCase<MatchEntity, String> {
  final MatchRepository matchRepository;
  DeleteMatch(this.matchRepository);

  @override
  Future<Either<Failure, MatchEntity>> call(String matchId) async {
    return await matchRepository.deleteMatch(matchId: matchId);
  }
}
