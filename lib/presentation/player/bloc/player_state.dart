part of 'player_bloc.dart';

@immutable
sealed class PlayerState {}

final class PlayerInitial extends PlayerState {}

final class PlayerLoading extends PlayerState {}

final class PlayerFailure extends PlayerState {
  final String error;
  PlayerFailure(this.error);
}

final class PlayerUploadSuccess extends PlayerState {}

final class PlayerDisplaySuccess extends PlayerState {
  final List<PlayerEntity> players;
  PlayerDisplaySuccess(this.players);
}

final class PlayerUpdateSuccess extends PlayerState {
  final PlayerEntity updatedPlayer;
  PlayerUpdateSuccess(this.updatedPlayer);
}

final class PlayerDeleteSuccess extends PlayerState {}
