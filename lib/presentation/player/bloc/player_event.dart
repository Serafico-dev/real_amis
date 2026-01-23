part of 'player_bloc.dart';

@immutable
sealed class PlayerEvent {}

final class PlayerUpload extends PlayerEvent {
  final String userName;
  final String fullName;
  final File image;
  final PlayerRole role;
  final int? attendances;
  final int? goals;
  final int? yellowCards;
  final int? redCards;
  final bool active;
  final DateTime? birthday;

  PlayerUpload({
    required this.userName,
    required this.fullName,
    required this.image,
    required this.role,
    this.attendances,
    this.goals,
    this.yellowCards,
    this.redCards,
    required this.active,
    this.birthday,
  });
}

final class PlayerFetchAllPlayers extends PlayerEvent {}

final class PlayerUpdate extends PlayerEvent {
  final PlayerEntity player;
  final String? userName;
  final String? fullName;
  final File? image;
  final PlayerRole? role;
  final int? attendances;
  final int? goals;
  final int? yellowCards;
  final int? redCards;
  final bool? active;
  final DateTime? birthday;

  PlayerUpdate({
    required this.player,
    this.userName,
    this.fullName,
    this.image,
    this.role,
    this.attendances,
    this.goals,
    this.yellowCards,
    this.redCards,
    this.active,
    this.birthday,
  });
}

final class PlayerDelete extends PlayerEvent {
  final String playerId;
  PlayerDelete({required this.playerId});
}
