import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:real_amis/core/usecase/usecase.dart';
import 'package:real_amis/domain/entities/team/team_entity.dart';
import 'package:real_amis/domain/usecases/team/delete_team.dart';

import 'package:real_amis/domain/usecases/team/get_all_teams.dart';
import 'package:real_amis/domain/usecases/team/update_team.dart';
import 'package:real_amis/domain/usecases/team/upload_team.dart';

part 'team_event.dart';
part 'team_state.dart';

class TeamBloc extends Bloc<TeamEvent, TeamState> {
  final UploadTeam _uploadTeam;
  final GetAllTeams _getAllTeams;
  final UpdateTeam _updateTeam;
  final DeleteTeam _deleteTeam;

  TeamBloc({
    required UploadTeam uploadTeam,
    required GetAllTeams getAllTeams,
    required UpdateTeam updateTeam,
    required DeleteTeam deleteTeam,
  }) : _uploadTeam = uploadTeam,
       _getAllTeams = getAllTeams,
       _updateTeam = updateTeam,
       _deleteTeam = deleteTeam,
       super(TeamInitial()) {
    on<TeamUpload>(_onTeamUpload);
    on<TeamFetchAllTeams>(_onFetchAllTeams);
    on<TeamUpdate>(_onTeamUpdate);
    on<TeamDelete>(_onTeamDelete);
  }
  void _onTeamUpload(TeamUpload event, Emitter<TeamState> emit) async {
    emit(TeamLoading());

    final res = await _uploadTeam(
      UploadTeamParams(name: event.name, image: event.image),
    );

    res.fold(
      (l) => emit(TeamFailure(l.message)),
      (r) => emit(TeamUploadSuccess()),
    );
  }

  void _onFetchAllTeams(
    TeamFetchAllTeams event,
    Emitter<TeamState> emit,
  ) async {
    emit(TeamLoading());

    final res = await _getAllTeams(NoParams());

    res.fold(
      (l) => emit(TeamFailure(l.message)),
      (r) => emit(TeamDisplaySuccess(r)),
    );
  }

  void _onTeamUpdate(TeamUpdate event, Emitter<TeamState> emit) async {
    emit(TeamLoading());

    final res = await _updateTeam(
      UpdateTeamParams(team: event.team, name: event.name, image: event.image),
    );

    res.fold((l) => emit(TeamFailure(l.message)), (updatedTeam) {
      List<TeamEntity> updatedTeams;
      if (state is TeamDisplaySuccess) {
        updatedTeams = List<TeamEntity>.from(
          (state as TeamDisplaySuccess).teams,
        );
        final idx = updatedTeams.indexWhere((p) => p.id == updatedTeam.id);
        if (idx >= 0) {
          updatedTeams[idx] = updatedTeam;
        } else {
          updatedTeams.add(updatedTeam);
        }
      } else {
        updatedTeams = [updatedTeam];
      }
      emit(TeamDisplaySuccess(updatedTeams));
      emit(TeamUpdateSuccess(updatedTeam));
    });
  }

  void _onTeamDelete(TeamDelete event, Emitter<TeamState> emit) async {
    emit(TeamLoading());

    final res = await _deleteTeam(event.teamId);

    res.fold(
      (l) => emit(TeamFailure(l.message)),
      (r) => emit(TeamDeleteSuccess()),
    );
  }
}
