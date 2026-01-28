import 'package:dartz/dartz.dart';
import 'package:real_amis/core/constants/constants.dart';
import 'package:real_amis/core/errors/exceptions.dart';
import 'package:real_amis/core/errors/failure.dart';
import 'package:real_amis/core/network/connection_checker.dart';
import 'package:real_amis/data/models/match/match_model.dart';
import 'package:real_amis/data/models/team/team_model.dart';
import 'package:real_amis/data/sources/match/match_local_data_source.dart';
import 'package:real_amis/data/sources/match/match_supabase_data_source.dart';
import 'package:real_amis/domain/entities/match/match_entity.dart';
import 'package:real_amis/domain/repositories/match/match_repository.dart';
import 'package:uuid/uuid.dart';

class MatchRepositoryImpl implements MatchRepository {
  final MatchSupabaseDataSource matchSupabaseDataSource;
  final MatchLocalDataSource matchLocalDataSource;
  final ConnectionChecker connectionChecker;

  MatchRepositoryImpl(
    this.matchSupabaseDataSource,
    this.matchLocalDataSource,
    this.connectionChecker,
  );

  @override
  Future<Either<Failure, MatchEntity>> uploadMatch({
    required DateTime matchDate,
    required String homeTeamId,
    required String awayTeamId,
    String? matchDay,
    required String leagueId,
  }) async {
    try {
      if (!await (connectionChecker.isConnected)) {
        return left(Failure(Constants.noConnectionErrorMessage));
      }
      MatchModel matchModel = MatchModel(
        id: Uuid().v1(),
        updatedAt: DateTime.now(),
        matchDate: matchDate,
        homeTeamId: homeTeamId,
        awayTeamId: awayTeamId,
        matchDay: matchDay,
        leagueId: leagueId,
      );
      await matchSupabaseDataSource.uploadMatch(matchModel);
      return right(matchModel);
    } on ServerException catch (e) {
      return left(Failure(e.message));
    }
  }

  @override
  Future<Either<Failure, List<MatchEntity>>> getAllMatches() async {
    try {
      if (!await (connectionChecker.isConnected)) {
        final matches = matchLocalDataSource.loadMatches();
        return right(matches);
      }
      final matches = await matchSupabaseDataSource.getAllMatches();
      matchLocalDataSource.uploadLocalMatches(matches: matches);
      return right(matches);
    } on ServerException catch (e) {
      return left(Failure(e.message));
    }
  }

  @override
  Future<Either<Failure, MatchEntity>> updateMatch({
    required MatchEntity match,
    DateTime? matchDate,
    String? homeTeamId,
    String? awayTeamId,
    String? matchDay,
    TeamModel? homeTeam,
    TeamModel? awayTeam,
    String? leagueId,
  }) async {
    try {
      if (!await (connectionChecker.isConnected)) {
        return left(Failure(Constants.noConnectionErrorMessage));
      }
      MatchModel matchModel = MatchModel(
        id: match.id,
        updatedAt: DateTime.now(),
        matchDate: matchDate ?? match.matchDate,
        homeTeamId: homeTeamId ?? match.homeTeamId,
        awayTeamId: awayTeamId ?? match.awayTeamId,
        matchDay: matchDay ?? match.matchDay,
        homeTeam: homeTeam ?? match.homeTeam,
        awayTeam: awayTeam ?? match.awayTeam,
        leagueId: leagueId ?? match.leagueId,
      );
      await matchSupabaseDataSource.updateMatch(matchModel);
      return right(matchModel);
    } on ServerException catch (e) {
      return left(Failure(e.message));
    }
  }

  @override
  Future<Either<Failure, MatchEntity>> deleteMatch({
    required String matchId,
  }) async {
    try {
      if (!await (connectionChecker.isConnected)) {
        return left(Failure(Constants.noConnectionErrorMessage));
      }
      final deletedMatch = await matchSupabaseDataSource.deleteMatch(
        matchId: matchId,
      );
      return right(deletedMatch);
    } on ServerException catch (e) {
      return left(Failure(e.message));
    }
  }
}
