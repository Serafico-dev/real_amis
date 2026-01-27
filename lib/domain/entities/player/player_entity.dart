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
  final DateTime? birthday;

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
    this.birthday,
  });

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is PlayerEntity && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;
}
