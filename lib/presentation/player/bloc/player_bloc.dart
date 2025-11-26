import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:real_amis/core/usecase/usecase.dart';
import 'package:real_amis/domain/entities/player/player_entity.dart';
import 'package:real_amis/domain/entities/player/player_role.dart';
import 'package:real_amis/domain/usecases/player/delete_player.dart';
import 'package:real_amis/domain/usecases/player/get_all_players.dart';
import 'package:real_amis/domain/usecases/player/update_player.dart';
import 'package:real_amis/domain/usecases/player/upload_player.dart';

part 'player_event.dart';
part 'player_state.dart';

class PlayerBloc extends Bloc<PlayerEvent, PlayerState> {
  final UploadPlayer _uploadPlayer;
  final GetAllPlayers _getAllPlayers;
  final UpdatePlayer _updatePlayer;
  final DeletePlayer _deletePlayer;

  PlayerBloc({
    required UploadPlayer uploadPlayer,
    required GetAllPlayers getAllPlayers,
    required UpdatePlayer updatePlayer,
    required DeletePlayer deletePlayer,
  }) : _uploadPlayer = uploadPlayer,
       _getAllPlayers = getAllPlayers,
       _updatePlayer = updatePlayer,
       _deletePlayer = deletePlayer,
       super(PlayerInitial()) {
    on<PlayerUpload>(_onPlayerUpload);
    on<PlayerFetchAllPlayers>(_onFetchAllPlayers);
    on<PlayerUpdate>(_onPlayerUpdate);
    on<PlayerDelete>(_onPlayerDelete);
  }
  void _onPlayerUpload(PlayerUpload event, Emitter<PlayerState> emit) async {
    emit(PlayerLoading());

    final res = await _uploadPlayer(
      UploadPlayerParams(
        userName: event.userName,
        fullName: event.fullName,
        image: event.image,
        role: event.role,
        attendances: event.attendances,
        goals: event.goals,
        yellowCards: event.yellowCards,
        redCards: event.redCards,
        active: event.active,
      ),
    );

    res.fold(
      (l) => emit(PlayerFailure(l.message)),
      (r) => emit(PlayerUploadSuccess()),
    );
  }

  void _onFetchAllPlayers(
    PlayerFetchAllPlayers event,
    Emitter<PlayerState> emit,
  ) async {
    emit(PlayerLoading());

    final res = await _getAllPlayers(NoParams());

    res.fold(
      (l) => emit(PlayerFailure(l.message)),
      (r) => emit(PlayerDisplaySuccess(r)),
    );
  }

  void _onPlayerUpdate(PlayerUpdate event, Emitter<PlayerState> emit) async {
    emit(PlayerLoading());

    final res = await _updatePlayer(
      UpdatePlayerParams(
        player: event.player,
        userName: event.userName,
        fullName: event.fullName,
        image: event.image,
        role: event.role,
        attendances: event.attendances,
        goals: event.goals,
        yellowCards: event.yellowCards,
        redCards: event.redCards,
        active: event.active,
      ),
    );

    res.fold((l) => emit(PlayerFailure(l.message)), (updatedPlayer) {
      List<PlayerEntity> updatedPlayers;
      if (state is PlayerDisplaySuccess) {
        updatedPlayers = List<PlayerEntity>.from(
          (state as PlayerDisplaySuccess).players,
        );
        final idx = updatedPlayers.indexWhere((p) => p.id == updatedPlayer.id);
        if (idx >= 0) {
          updatedPlayers[idx] = updatedPlayer;
        } else {
          updatedPlayers.add(updatedPlayer);
        }
      } else {
        updatedPlayers = [updatedPlayer];
      }
      emit(PlayerDisplaySuccess(updatedPlayers));
      emit(PlayerUpdateSuccess(updatedPlayer));
    });
  }

  void _onPlayerDelete(PlayerDelete event, Emitter<PlayerState> emit) async {
    emit(PlayerLoading());

    final res = await _deletePlayer(event.playerId);

    res.fold(
      (l) => emit(PlayerFailure(l.message)),
      (r) => emit(PlayerDeleteSuccess()),
    );
  }
}
