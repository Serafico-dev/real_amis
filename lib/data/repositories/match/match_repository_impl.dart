import 'package:dartz/dartz.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:real_amis/core/constants/constants.dart';
import 'package:real_amis/core/errors/exceptions.dart';
import 'package:real_amis/core/errors/failure.dart';
import 'package:real_amis/core/network/connection_checker.dart';
import 'package:real_amis/core/providers/connection_checker_provider.dart';
import 'package:real_amis/data/models/match/match_model.dart';
import 'package:real_amis/data/models/team/team_model.dart';
import 'package:real_amis/data/sources/match/match_local_data_source.dart';
import 'package:real_amis/data/sources/match/match_supabase_data_source.dart';
import 'package:real_amis/domain/entities/match/match_entity.dart';
import 'package:real_amis/domain/repositories/match/match_repository.dart';
import 'package:uuid/uuid.dart';

final matchRepositoryProvider = Provider<MatchRepositoryImpl>((ref) {
  return MatchRepositoryImpl(
    ref.read(matchSupabaseDataSourceProvider),
    ref.read(matchLocalDataSourceProvider),
    ref.read(connectionCheckerProvider),
  );
});

class MatchRepositoryImpl implements MatchRepository {
  final MatchSupabaseDataSource matchSupabaseDataSource;
  final MatchLocalDataSource matchLocalDataSource;
  final ConnectionChecker connectionChecker;

  MatchRepositoryImpl(
    this.matchSupabaseDataSource,
    this.matchLocalDataSource,
    this.connectionChecker,
  );

  MatchEntity _toEntity(MatchModel model) {
    return MatchEntity(
      id: model.id,
      updatedAt: model.updatedAt,
      matchDate: model.matchDate,
      homeTeamId: model.homeTeamId,
      awayTeamId: model.awayTeamId,
      matchDay: model.matchDay,
      leagueId: model.leagueId,
      homeTeam: model.homeTeam,
      awayTeam: model.awayTeam,
    );
  }

  @override
  Future<Either<Failure, MatchEntity>> uploadMatch({
    required DateTime matchDate,
    required String homeTeamId,
    required String awayTeamId,
    int? homeTeamScore,
    int? awayTeamScore,
    String? matchDay,
    required String leagueId,
  }) async {
    try {
      if (!await connectionChecker.isConnected) {
        return left(Failure(Constants.noConnectionErrorMessage));
      }

      final matchModel = MatchModel(
        id: Uuid().v1(),
        updatedAt: DateTime.now(),
        matchDate: matchDate,
        homeTeamId: homeTeamId,
        awayTeamId: awayTeamId,
        matchDay: matchDay,
        leagueId: leagueId,
      );

      final uploadedMatch = await matchSupabaseDataSource.uploadMatch(
        matchModel,
      );

      return right(_toEntity(uploadedMatch));
    } on ServerException catch (e) {
      return left(Failure(e.message));
    }
  }

  @override
  Future<Either<Failure, List<MatchEntity>>> getAllMatches() async {
    try {
      List<MatchModel> matches;
      if (!await connectionChecker.isConnected) {
        matches = matchLocalDataSource.loadMatches();
      } else {
        matches = await matchSupabaseDataSource.getAllMatches();
        matchLocalDataSource.uploadLocalMatches(matches: matches);
      }

      return right(matches.map(_toEntity).toList());
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
      if (!await connectionChecker.isConnected) {
        return left(Failure(Constants.noConnectionErrorMessage));
      }

      final matchModel = MatchModel(
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

      final updatedMatch = await matchSupabaseDataSource.updateMatch(
        matchModel,
      );

      return right(_toEntity(updatedMatch));
    } on ServerException catch (e) {
      return left(Failure(e.message));
    }
  }

  @override
  Future<Either<Failure, MatchEntity>> deleteMatch({
    required String matchId,
  }) async {
    try {
      if (!await connectionChecker.isConnected) {
        return left(Failure(Constants.noConnectionErrorMessage));
      }

      final deletedMatch = await matchSupabaseDataSource.deleteMatch(
        matchId: matchId,
      );

      return right(_toEntity(deletedMatch));
    } on ServerException catch (e) {
      return left(Failure(e.message));
    }
  }
}
