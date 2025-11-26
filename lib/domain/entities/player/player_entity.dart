import 'package:real_amis/domain/entities/player/player_role.dart';

class PlayerEntity {
  final String id;
  final DateTime updatedAt;
  final String userName;
  final String fullName;
  final String imageUrl;
  final PlayerRole role;
  final int? attendances;
  final int? goals;
  final int? yellowCards;
  final int? redCards;
  final bool active;

  PlayerEntity({
    required this.id,
    required this.updatedAt,
    required this.userName,
    required this.fullName,
    required this.imageUrl,
    required this.role,
    this.attendances,
    this.goals,
    this.yellowCards,
    this.redCards,
    required this.active,
  });
}
