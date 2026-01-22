import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:real_amis/core/usecase/usecase.dart';
import 'package:real_amis/domain/entities/score/score_entity.dart';
import 'package:real_amis/domain/usecases/score/delete_score.dart';

import 'package:real_amis/domain/usecases/score/get_all_scores.dart';
import 'package:real_amis/domain/usecases/score/update_score.dart';
import 'package:real_amis/domain/usecases/score/upload_score.dart';

part 'score_event.dart';
part 'score_state.dart';

class ScoreBloc extends Bloc<ScoreEvent, ScoreState> {
  final UploadScore _uploadScore;
  final GetAllScores _getAllScores;
  final UpdateScore _updateScore;
  final DeleteScore _deleteScore;

  ScoreBloc({
    required UploadScore uploadScore,
    required GetAllScores getAllScores,
    required UpdateScore updateScore,
    required DeleteScore deleteScore,
  }) : _uploadScore = uploadScore,
       _getAllScores = getAllScores,
       _updateScore = updateScore,
       _deleteScore = deleteScore,
       super(ScoreInitial()) {
    on<ScoreUpload>(_onScoreUpload);
    on<ScoreFetchAllScores>(_onFetchAllScores);
    on<ScoreUpdate>(_onScoreUpdate);
    on<ScoreDelete>(_onScoreDelete);
  }
  void _onScoreUpload(ScoreUpload event, Emitter<ScoreState> emit) async {
    emit(ScoreLoading());

    final res = await _uploadScore(
      UploadScoreParams(
        leagueId: event.leagueId,
        teamId: event.teamId,
        score: event.score,
      ),
    );

    res.fold(
      (l) => emit(ScoreFailure(l.message)),
      (r) => emit(ScoreUploadSuccess()),
    );
  }

  void _onFetchAllScores(
    ScoreFetchAllScores event,
    Emitter<ScoreState> emit,
  ) async {
    emit(ScoreLoading());

    final res = await _getAllScores(NoParams());

    res.fold(
      (l) => emit(ScoreFailure(l.message)),
      (r) => emit(ScoreDisplaySuccess(r)),
    );
  }

  void _onScoreUpdate(ScoreUpdate event, Emitter<ScoreState> emit) async {
    emit(ScoreLoading());

    final res = await _updateScore(
      UpdateScoreParams(
        scoreEntity: event.scoreEntity,
        leagueId: event.leagueId,
        teamId: event.teamId,
        score: event.score,
      ),
    );

    res.fold((l) => emit(ScoreFailure(l.message)), (updatedScore) {
      List<ScoreEntity> updatedScores;
      if (state is ScoreDisplaySuccess) {
        updatedScores = List<ScoreEntity>.from(
          (state as ScoreDisplaySuccess).scores,
        );
        final idx = updatedScores.indexWhere((p) => p.id == updatedScore.id);
        if (idx >= 0) {
          updatedScores[idx] = updatedScore;
        } else {
          updatedScores.add(updatedScore);
        }
      } else {
        updatedScores = [updatedScore];
      }
      emit(ScoreDisplaySuccess(updatedScores));
      emit(ScoreUpdateSuccess(updatedScore));
    });
  }

  void _onScoreDelete(ScoreDelete event, Emitter<ScoreState> emit) async {
    emit(ScoreLoading());

    final res = await _deleteScore(event.scoreId);

    res.fold(
      (l) => emit(ScoreFailure(l.message)),
      (r) => emit(ScoreDeleteSuccess()),
    );
  }
}
