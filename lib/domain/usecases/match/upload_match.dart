import 'package:dartz/dartz.dart';
import 'package:real_amis/core/errors/failure.dart';
import 'package:real_amis/core/usecase/usecase.dart';
import 'package:real_amis/domain/entities/match/match_entity.dart';
import 'package:real_amis/domain/repositories/match/match_repository.dart';

class UploadMatch implements UseCase<MatchEntity, UploadMatchParams> {
  final MatchRepository matchRepository;
  UploadMatch(this.matchRepository);

  @override
  Future<Either<Failure, MatchEntity>> call(UploadMatchParams params) async {
    return await matchRepository.uploadMatch(
      matchDate: params.matchDate,
      homeTeamId: params.homeTeamId,
      awayTeamId: params.awayTeamId,
      homeTeamScore: params.homeTeamScore,
      awayTeamScore: params.awayTeamScore,
      matchDay: params.matchDay,
    );
  }
}

class UploadMatchParams {
  final DateTime matchDate;
  final String homeTeamId;
  final String awayTeamId;
  final int? homeTeamScore;
  final int? awayTeamScore;
  final String? matchDay;

  UploadMatchParams({
    required this.matchDate,
    required this.homeTeamId,
    required this.awayTeamId,
    this.homeTeamScore,
    this.awayTeamScore,
    this.matchDay,
  });
}
