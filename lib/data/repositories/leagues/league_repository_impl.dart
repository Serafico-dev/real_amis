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
    List<String>? teamIds,
  }) async {
    try {
      if (!await connectionChecker.isConnected) {
        return left(Failure(Constants.noConnectionErrorMessage));
      }

      final leagueModel = LeagueModel(
        id: Uuid().v1(),
        name: name,
        year: year,
        teamIds: teamIds ?? [],
      );

      final uploadedLeague = await leagueSupabaseDataSource.uploadLeague(
        leagueModel,
      );

      if (teamIds != null) {
        for (var teamId in teamIds) {
          await leagueSupabaseDataSource.addTeamToLeague(
            uploadedLeague.id,
            teamId,
          );
        }
      }

      return right(uploadedLeague);
    } on ServerException catch (e) {
      return left(Failure(e.message));
    }
  }

  @override
  Future<Either<Failure, List<LeagueEntity>>> getAllLeagues() async {
    try {
      if (!await connectionChecker.isConnected) {
        final leagues = leagueLocalDataSource.loadLeagues();
        return right(leagues);
      }

      final leagues = await leagueSupabaseDataSource.getAllLeagues();
      final leaguesWithTeams = <LeagueModel>[];

      for (var league in leagues) {
        final teamIds = await leagueSupabaseDataSource.getTeamIdsByLeague(
          league.id,
        );
        leaguesWithTeams.add(league.copyWith(teamIds: teamIds));
      }

      leagueLocalDataSource.uploadLocalLeagues(leagues: leaguesWithTeams);

      return right(leaguesWithTeams);
    } on ServerException catch (e) {
      return left(Failure(e.message));
    }
  }

  @override
  Future<Either<Failure, LeagueEntity>> updateLeague({
    required LeagueEntity league,
    String? name,
    String? year,
    List<String>? teamIds,
  }) async {
    try {
      if (!await connectionChecker.isConnected) {
        return left(Failure(Constants.noConnectionErrorMessage));
      }

      final updatedModel = LeagueModel(
        id: league.id,
        name: name ?? league.name,
        year: year ?? league.year,
      );

      await leagueSupabaseDataSource.updateLeague(updatedModel);

      List<String> finalTeamIds = league.teamIds;

      if (teamIds != null) {
        final existingTeamIds = await leagueSupabaseDataSource
            .getTeamIdsByLeague(league.id);

        final oldSet = existingTeamIds.toSet();
        final newSet = teamIds.toSet();

        final toRemove = oldSet.difference(newSet);
        final toAdd = newSet.difference(oldSet);

        for (final teamId in toRemove) {
          await leagueSupabaseDataSource.removeTeamFromLeague(
            league.id,
            teamId,
          );
        }

        for (final teamId in toAdd) {
          await leagueSupabaseDataSource.addTeamToLeague(league.id, teamId);
        }

        finalTeamIds = teamIds;
      }

      return right(updatedModel.copyWith(teamIds: finalTeamIds));
    } on ServerException catch (e) {
      return left(Failure(e.message));
    }
  }

  @override
  Future<Either<Failure, LeagueEntity>> deleteLeague({
    required String leagueId,
  }) async {
    try {
      if (!await connectionChecker.isConnected) {
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
