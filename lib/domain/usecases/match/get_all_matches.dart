import 'package:dartz/dartz.dart';
import 'package:real_amis/core/errors/failure.dart';
import 'package:real_amis/core/usecase/usecase.dart';
import 'package:real_amis/domain/entities/match/match_entity.dart';
import 'package:real_amis/domain/repositories/match/match_repository.dart';

class GetAllMatches implements UseCase<List<MatchEntity>, NoParams> {
  final MatchRepository matchRepository;
  GetAllMatches(this.matchRepository);

  @override
  Future<Either<Failure, List<MatchEntity>>> call(NoParams params) async {
    return await matchRepository.getAllMatches();
  }
}
