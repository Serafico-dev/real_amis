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
      matchDay: params.matchDay,
      leagueId: params.leagueId,
    );
  }
}

class UpdateMatchParams {
  final MatchEntity match;
  final DateTime? matchDate;
  final String? homeTeamId;
  final String? awayTeamId;
  final String? matchDay;
  final String? leagueId;

  UpdateMatchParams({
    required this.match,
    this.matchDate,
    this.homeTeamId,
    this.awayTeamId,
    this.matchDay,
    this.leagueId,
  });
}
