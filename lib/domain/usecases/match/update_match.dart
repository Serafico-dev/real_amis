import 'package:dartz/dartz.dart';
import 'package:real_amis/core/errors/failure.dart';
import 'package:real_amis/core/usecase/usecase.dart';
import 'package:real_amis/domain/entities/match/match_entity.dart';
import 'package:real_amis/domain/repositories/match/match_repository.dart';

class UpdateMatch implements UseCase<MatchEntity, UpdateMatchParams> {
  final MatchRepository matchRepository;
  UpdateMatch(this.matchRepository);

  @override
  Future<Either<Failure, MatchEntity>> call(UpdateMatchParams params) async {
    return await matchRepository.updateMatch(
      match: params.match,
      matchDate: params.matchDate,
      homeTeamId: params.homeTeamId,
      awayTeamId: params.awayTeamId,
      homeTeamScore: params.homeTeamScore,
      awayTeamScore: params.awayTeamScore,
      matchDay: params.matchDay,
    );
  }
}

class UpdateMatchParams {
  final MatchEntity match;
  final DateTime? matchDate;
  final String? homeTeamId;
  final String? awayTeamId;
  final int? homeTeamScore;
  final int? awayTeamScore;
  final String? matchDay;

  UpdateMatchParams({
    required this.match,
    this.matchDate,
    this.homeTeamId,
    this.awayTeamId,
    this.homeTeamScore,
    this.awayTeamScore,
    this.matchDay,
  });
}
