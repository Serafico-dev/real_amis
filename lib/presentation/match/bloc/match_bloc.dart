import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:real_amis/core/usecase/usecase.dart';
import 'package:real_amis/domain/entities/match/match_entity.dart';
import 'package:real_amis/domain/entities/team/team_entity.dart';
import 'package:real_amis/domain/usecases/match/delete_match.dart';
import 'package:real_amis/domain/usecases/match/get_all_matches.dart';
import 'package:real_amis/domain/usecases/match/update_match.dart';
import 'package:real_amis/domain/usecases/match/upload_match.dart';

part 'match_event.dart';
part 'match_state.dart';

class MatchBloc extends Bloc<MatchEvent, MatchState> {
  final UploadMatch _uploadMatch;
  final GetAllMatches _getAllMatches;
  final UpdateMatch _updateMatch;
  final DeleteMatch _deleteMatch;

  MatchBloc({
    required UploadMatch uploadMatch,
    required GetAllMatches getAllMatches,
    required UpdateMatch updateMatch,
    required DeleteMatch deleteMatch,
  }) : _uploadMatch = uploadMatch,
       _getAllMatches = getAllMatches,
       _updateMatch = updateMatch,
       _deleteMatch = deleteMatch,
       super(MatchInitial()) {
    on<MatchUpload>(_onMatchUpload);
    on<MatchFetchAllMatches>(_onFetchAllMatches);
    on<MatchUpdate>(_onMatchUpdate);
    on<MatchDelete>(_onMatchDelete);
  }
  void _onMatchUpload(MatchUpload event, Emitter<MatchState> emit) async {
    emit(MatchLoading());

    final res = await _uploadMatch(
      UploadMatchParams(
        matchDate: event.matchDate,
        homeTeamId: event.homeTeamId,
        awayTeamId: event.awayTeamId,
        homeTeamScore: event.homeTeamScore,
        awayTeamScore: event.awayTeamScore,
        matchDay: event.matchDay,
      ),
    );

    res.fold(
      (l) => emit(MatchFailure(l.message)),
      (r) => emit(MatchUploadSuccess()),
    );
  }

  void _onFetchAllMatches(
    MatchFetchAllMatches event,
    Emitter<MatchState> emit,
  ) async {
    emit(MatchLoading());

    final res = await _getAllMatches(NoParams());

    res.fold(
      (l) => emit(MatchFailure(l.message)),
      (r) => emit(MatchDisplaySuccess(r)),
    );
  }

  void _onMatchUpdate(MatchUpdate event, Emitter<MatchState> emit) async {
    emit(MatchLoading());

    final res = await _updateMatch(
      UpdateMatchParams(
        match: event.match,
        matchDate: event.matchDate,
        homeTeamId: event.homeTeamId,
        awayTeamId: event.awayTeamId,
        homeTeamScore: event.homeTeamScore,
        awayTeamScore: event.awayTeamScore,
        matchDay: event.matchDay,
      ),
    );

    res.fold((l) => emit(MatchFailure(l.message)), (updatedMatch) {
      List<MatchEntity> updatedMatches;
      if (state is MatchDisplaySuccess) {
        updatedMatches = List<MatchEntity>.from(
          (state as MatchDisplaySuccess).matches,
        );
        final idx = updatedMatches.indexWhere((p) => p.id == updatedMatch.id);
        if (idx >= 0) {
          updatedMatches[idx] = updatedMatch;
        } else {
          updatedMatches.add(updatedMatch);
        }
      } else {
        updatedMatches = [updatedMatch];
      }
      emit(MatchDisplaySuccess(updatedMatches));
      emit(MatchUpdateSuccess(updatedMatch));
    });
  }

  void _onMatchDelete(MatchDelete event, Emitter<MatchState> emit) async {
    emit(MatchLoading());

    final res = await _deleteMatch(event.matchId);

    res.fold(
      (l) => emit(MatchFailure(l.message)),
      (r) => emit(MatchDeleteSuccess()),
    );
  }
}
