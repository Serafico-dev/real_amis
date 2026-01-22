import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:real_amis/core/usecase/usecase.dart';
import 'package:real_amis/domain/entities/league/league_entity.dart';
import 'package:real_amis/domain/usecases/league/delete_league.dart';

import 'package:real_amis/domain/usecases/league/get_all_leagues.dart';
import 'package:real_amis/domain/usecases/league/update_league.dart';
import 'package:real_amis/domain/usecases/league/upload_league.dart';

part 'league_event.dart';
part 'league_state.dart';

class LeagueBloc extends Bloc<LeagueEvent, LeagueState> {
  final UploadLeague _uploadLeague;
  final GetAllLeagues _getAllLeagues;
  final UpdateLeague _updateLeague;
  final DeleteLeague _deleteLeague;

  LeagueBloc({
    required UploadLeague uploadLeague,
    required GetAllLeagues getAllLeagues,
    required UpdateLeague updateLeague,
    required DeleteLeague deleteLeague,
  }) : _uploadLeague = uploadLeague,
       _getAllLeagues = getAllLeagues,
       _updateLeague = updateLeague,
       _deleteLeague = deleteLeague,
       super(LeagueInitial()) {
    on<LeagueUpload>(_onLeagueUpload);
    on<LeagueFetchAllLeagues>(_onFetchAllLeagues);
    on<LeagueUpdate>(_onLeagueUpdate);
    on<LeagueDelete>(_onLeagueDelete);
  }
  void _onLeagueUpload(LeagueUpload event, Emitter<LeagueState> emit) async {
    emit(LeagueLoading());

    final res = await _uploadLeague(
      UploadLeagueParams(name: event.name, year: event.year),
    );

    res.fold(
      (l) => emit(LeagueFailure(l.message)),
      (r) => emit(LeagueUploadSuccess()),
    );
  }

  void _onFetchAllLeagues(
    LeagueFetchAllLeagues event,
    Emitter<LeagueState> emit,
  ) async {
    emit(LeagueLoading());

    final res = await _getAllLeagues(NoParams());

    res.fold(
      (l) => emit(LeagueFailure(l.message)),
      (r) => emit(LeagueDisplaySuccess(r)),
    );
  }

  void _onLeagueUpdate(LeagueUpdate event, Emitter<LeagueState> emit) async {
    emit(LeagueLoading());

    final res = await _updateLeague(
      UpdateLeagueParams(
        league: event.league,
        name: event.name,
        year: event.year,
      ),
    );

    res.fold((l) => emit(LeagueFailure(l.message)), (updatedLeague) {
      List<LeagueEntity> updatedLeagues;
      if (state is LeagueDisplaySuccess) {
        updatedLeagues = List<LeagueEntity>.from(
          (state as LeagueDisplaySuccess).leagues,
        );
        final idx = updatedLeagues.indexWhere((p) => p.id == updatedLeague.id);
        if (idx >= 0) {
          updatedLeagues[idx] = updatedLeague;
        } else {
          updatedLeagues.add(updatedLeague);
        }
      } else {
        updatedLeagues = [updatedLeague];
      }
      emit(LeagueDisplaySuccess(updatedLeagues));
      emit(LeagueUpdateSuccess(updatedLeague));
    });
  }

  void _onLeagueDelete(LeagueDelete event, Emitter<LeagueState> emit) async {
    emit(LeagueLoading());

    final res = await _deleteLeague(event.leagueId);

    res.fold(
      (l) => emit(LeagueFailure(l.message)),
      (r) => emit(LeagueDeleteSuccess()),
    );
  }
}
