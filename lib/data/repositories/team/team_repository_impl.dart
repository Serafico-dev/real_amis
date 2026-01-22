import 'dart:io';

import 'package:dartz/dartz.dart';
import 'package:real_amis/core/constants/constants.dart';
import 'package:real_amis/core/errors/exceptions.dart';
import 'package:real_amis/core/errors/failure.dart';
import 'package:real_amis/core/network/connection_checker.dart';
import 'package:real_amis/data/models/team/team_model.dart';
import 'package:real_amis/data/sources/team/team_local_data_source.dart';
import 'package:real_amis/data/sources/team/team_supabase_data_source.dart';
import 'package:real_amis/domain/entities/team/team_entity.dart';
import 'package:real_amis/domain/repositories/team/team_repository.dart';
import 'package:uuid/uuid.dart';

class TeamRepositoryImpl implements TeamRepository {
  final TeamSupabaseDataSource teamSupabaseDataSource;
  final TeamLocalDataSource teamLocalDataSource;
  final ConnectionChecker connectionChecker;

  TeamRepositoryImpl(
    this.teamSupabaseDataSource,
    this.teamLocalDataSource,
    this.connectionChecker,
  );

  @override
  Future<Either<Failure, TeamEntity>> uploadTeam({
    required String name,
    required File image,
  }) async {
    try {
      if (!await (connectionChecker.isConnected)) {
        return left(Failure(Constants.noConnectionErrorMessage));
      }
      TeamModel teamModel = TeamModel(
        id: Uuid().v1(),
        updatedAt: DateTime.now(),
        name: name,
        imageUrl: '',
      );

      final imageUrl = await teamSupabaseDataSource.uploadTeamImage(
        image: image,
        team: teamModel,
      );

      teamModel = teamModel.copyWith(imageUrl: imageUrl);
      final uploadedTeam = await teamSupabaseDataSource.uploadTeam(teamModel);
      return right(uploadedTeam);
    } on ServerException catch (e) {
      return left(Failure(e.message));
    }
  }

  @override
  Future<Either<Failure, List<TeamEntity>>> getAllTeams() async {
    try {
      if (!await (connectionChecker.isConnected)) {
        final teams = teamLocalDataSource.loadTeams();
        return right(teams);
      }
      final teams = await teamSupabaseDataSource.getAllTeams();
      teamLocalDataSource.uploadLocalTeams(teams: teams);
      return right(teams);
    } on ServerException catch (e) {
      return left(Failure(e.message));
    }
  }

  @override
  Future<Either<Failure, TeamEntity>> updateTeam({
    required TeamEntity team,
    String? name,
    File? image,
  }) async {
    try {
      if (!await (connectionChecker.isConnected)) {
        return left(Failure(Constants.noConnectionErrorMessage));
      }
      TeamModel teamModel = TeamModel(
        id: team.id,
        updatedAt: DateTime.now(),
        name: name ?? team.name,
        imageUrl: team.imageUrl,
      );

      final imageUrl = await teamSupabaseDataSource.updateTeamImage(
        image: image,
        team: teamModel,
      );

      teamModel = teamModel.copyWith(imageUrl: imageUrl);
      final updatedTeam = await teamSupabaseDataSource.updateTeam(teamModel);
      return right(updatedTeam);
    } on ServerException catch (e) {
      return left(Failure(e.message));
    }
  }

  @override
  Future<Either<Failure, TeamEntity>> deleteTeam({
    required String teamId,
  }) async {
    try {
      if (!await (connectionChecker.isConnected)) {
        return left(Failure(Constants.noConnectionErrorMessage));
      }
      final deletedTeam = await teamSupabaseDataSource.deleteTeam(
        teamId: teamId,
      );
      return right(deletedTeam);
    } on ServerException catch (e) {
      return left(Failure(e.message));
    }
  }
}
