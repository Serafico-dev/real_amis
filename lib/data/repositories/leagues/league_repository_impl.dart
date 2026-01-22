import 'package:dartz/dartz.dart';
import 'package:real_amis/core/constants/constants.dart';
import 'package:real_amis/core/errors/exceptions.dart';
import 'package:real_amis/core/errors/failure.dart';
import 'package:real_amis/core/network/connection_checker.dart';
import 'package:real_amis/data/models/league/league_model.dart';
import 'package:real_amis/data/sources/league/league_local_data_source.dart';
import 'package:real_amis/data/sources/league/league_supabase_data_source.dart';
import 'package:real_amis/domain/entities/league/league_entity.dart';
import 'package:real_amis/domain/repositories/league/league_repository.dart';
import 'package:uuid/uuid.dart';

class LeagueRepositoryImpl implements LeagueRepository {
  final LeagueSupabaseDataSource leagueSupabaseDataSource;
  final LeagueLocalDataSource leagueLocalDataSource;
  final ConnectionChecker connectionChecker;

  LeagueRepositoryImpl(
    this.leagueSupabaseDataSource,
    this.leagueLocalDataSource,
    this.connectionChecker,
  );

  @override
  Future<Either<Failure, LeagueEntity>> uploadLeague({
    required String name,
    required String year,
  }) async {
    try {
      if (!await (connectionChecker.isConnected)) {
        return left(Failure(Constants.noConnectionErrorMessage));
      }
      LeagueModel leagueModel = LeagueModel(
        id: Uuid().v1(),
        name: name,
        year: year,
      );
      await leagueSupabaseDataSource.uploadLeague(leagueModel);
      return right(leagueModel);
    } on ServerException catch (e) {
      return left(Failure(e.message));
    }
  }

  @override
  Future<Either<Failure, List<LeagueEntity>>> getAllLeagues() async {
    try {
      if (!await (connectionChecker.isConnected)) {
        final leagues = leagueLocalDataSource.loadLeagues();
        return right(leagues);
      }
      final leagues = await leagueSupabaseDataSource.getAllLeagues();
      leagueLocalDataSource.uploadLocalLeagues(leagues: leagues);
      return right(leagues);
    } on ServerException catch (e) {
      return left(Failure(e.message));
    }
  }

  @override
  Future<Either<Failure, LeagueEntity>> updateLeague({
    required LeagueEntity league,
    String? name,
    String? year,
  }) async {
    try {
      if (!await (connectionChecker.isConnected)) {
        return left(Failure(Constants.noConnectionErrorMessage));
      }
      LeagueModel leagueModel = LeagueModel(
        id: league.id,
        name: name ?? league.name,
        year: year ?? league.year,
      );
      await leagueSupabaseDataSource.updateLeague(leagueModel);
      return right(leagueModel);
    } on ServerException catch (e) {
      return left(Failure(e.message));
    }
  }

  @override
  Future<Either<Failure, LeagueEntity>> deleteLeague({
    required String leagueId,
  }) async {
    try {
      if (!await (connectionChecker.isConnected)) {
        return left(Failure(Constants.noConnectionErrorMessage));
      }
      final deletedLeague = await leagueSupabaseDataSource.deleteLeague(
        leagueId: leagueId,
      );
      return right(deletedLeague);
    } on ServerException catch (e) {
      return left(Failure(e.message));
    }
  }
}
