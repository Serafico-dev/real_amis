import 'package:dartz/dartz.dart';
import 'package:real_amis/core/errors/failure.dart';
import 'package:real_amis/core/usecase/usecase.dart';
import 'package:real_amis/domain/entities/league/league_entity.dart';
import 'package:real_amis/domain/repositories/league/league_repository.dart';

class UploadLeague implements UseCase<LeagueEntity, UploadLeagueParams> {
  final LeagueRepository leagueRepository;
  UploadLeague(this.leagueRepository);

  @override
  Future<Either<Failure, LeagueEntity>> call(UploadLeagueParams params) async {
    return await leagueRepository.uploadLeague(
      name: params.name,
      year: params.year,
    );
  }
}

class UploadLeagueParams {
  final String name;
  final String year;

  UploadLeagueParams({required this.name, required this.year});
}
