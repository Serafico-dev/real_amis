import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:real_amis/core/usecase/usecase.dart';
import 'package:real_amis/domain/entities/score/score_entity.dart';
import 'package:real_amis/domain/usecases/score/delete_score.dart';

import 'package:real_amis/domain/usecases/score/get_all_scores.dart';
import 'package:real_amis/domain/usecases/score/get_scores_by_league.dart';
import 'package:real_amis/domain/usecases/score/update_score.dart';
import 'package:real_amis/domain/usecases/score/upload_score.dart';
import 'package:uuid/uuid.dart';

part 'score_event.dart';
part 'score_state.dart';

class ScoreBloc extends Bloc<ScoreEvent, ScoreState> {
  final UploadScore _uploadScore;
  final GetAllScores _getAllScores;
  final GetScoresByLeague _getScoresByLeague;
  final UpdateScore _updateScore;
  final DeleteScore _deleteScore;

  ScoreBloc({
    required UploadScore uploadScore,
    required GetAllScores getAllScores,
    required GetScoresByLeague getScoresByLeague,
    required UpdateScore updateScore,
    required DeleteScore deleteScore,
  }) : _uploadScore = uploadScore,
       _getAllScores = getAllScores,
       _getScoresByLeague = getScoresByLeague,
       _updateScore = updateScore,
       _deleteScore = deleteScore,
       super(ScoreInitial()) {
    on<ScoreUpload>(_onScoreUpload);
    on<ScoreFetchAllScores>(_onFetchAllScores);
    on<ScoreFetchByLeague>(_onFetchByLeague);
    on<ScoreUpdate>(_onScoreUpdate);
    on<ScoreDelete>(_onScoreDelete);
  }

  Future<void> _onScoreUpload(
    ScoreUpload event,
    Emitter<ScoreState> emit,
  ) async {
    final currentScores = state is ScoreDisplaySuccess
        ? List<ScoreEntity>.from((state as ScoreDisplaySuccess).scores)
        : <ScoreEntity>[];

    final res = await _uploadScore(
      UploadScoreParams(
        leagueId: event.leagueId,
        teamId: event.teamId,
        score: event.score,
      ),
    );

    res.fold((l) => emit(ScoreFailure(l.message)), (r) {
      currentScores.add(
        ScoreEntity(
          id: const Uuid().v4(),
          teamId: event.teamId,
          leagueId: event.leagueId,
          score: event.score,
        ),
      );
      emit(ScoreDisplaySuccess(currentScores));
    });
  }

  Future<void> _onFetchAllScores(
    ScoreFetchAllScores event,
    Emitter<ScoreState> emit,
  ) async {
    final res = await _getAllScores(NoParams());

    res.fold(
      (l) => emit(ScoreFailure(l.message)),
      (r) => emit(ScoreDisplaySuccess(r)),
    );
  }

  Future<void> _onFetchByLeague(
    ScoreFetchByLeague event,
    Emitter<ScoreState> emit,
  ) async {
    final res = await _getScoresByLeague(
      GetScoresByLeagueParams(leagueId: event.leagueId),
    );

    res.fold(
      (l) => emit(ScoreFailure(l.message)),
      (r) => emit(ScoreDisplaySuccess(r)),
    );
  }

  Future<void> _onScoreUpdate(
    ScoreUpdate event,
    Emitter<ScoreState> emit,
  ) async {
    final currentScores = state is ScoreDisplaySuccess
        ? List<ScoreEntity>.from((state as ScoreDisplaySuccess).scores)
        : <ScoreEntity>[];

    final res = await _updateScore(
      UpdateScoreParams(
        scoreEntity: event.scoreEntity,
        leagueId: event.leagueId!,
        teamId: event.teamId!,
        score: event.score!,
      ),
    );

    res.fold((l) => emit(ScoreFailure(l.message)), (updatedScore) {
      final idx = currentScores.indexWhere((s) => s.id == updatedScore.id);
      if (idx >= 0) {
        currentScores[idx] = updatedScore;
      } else {
        currentScores.add(updatedScore);
      }
      emit(ScoreDisplaySuccess(currentScores));
    });
  }

  Future<void> _onScoreDelete(
    ScoreDelete event,
    Emitter<ScoreState> emit,
  ) async {
    final res = await _deleteScore(event.scoreId);

    res.fold((l) => emit(ScoreFailure(l.message)), (r) {
      if (state is ScoreDisplaySuccess) {
        final currentScores = List<ScoreEntity>.from(
          (state as ScoreDisplaySuccess).scores,
        )..removeWhere((s) => s.id == event.scoreId);
        emit(ScoreDisplaySuccess(currentScores));
      }
    });
  }
}
