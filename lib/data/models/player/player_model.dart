import 'package:real_amis/domain/entities/player/player_entity.dart';
import 'package:real_amis/domain/entities/player/player_role.dart';

class PlayerModel extends PlayerEntity {
  PlayerModel({
    required super.id,
    required super.updatedAt,
    required super.userName,
    required super.fullName,
    required super.imageUrl,
    required super.role,
    super.attendances,
    super.goals,
    super.yellowCards,
    super.redCards,
    required super.active,
  });

  Map<String, dynamic> toJson() {
    return <String, dynamic>{
      'id': id,
      'updated_at': updatedAt.toIso8601String(),
      'username': userName,
      'full_name': fullName,
      'image_url': imageUrl,
      'role': role.value,
      'attendances': attendances,
      'goals': goals,
      'yellow_cards': yellowCards,
      'red_cards': redCards,
      'active': active,
    };
  }

  factory PlayerModel.fromJson(Map<String, dynamic> map) {
    return PlayerModel(
      id: map['id'] as String,
      updatedAt: map['updated_at'] == null
          ? DateTime.now()
          : DateTime.parse(map['updated_at']),
      userName: map['username'] as String,
      fullName: map['full_name'] as String,
      imageUrl: map['image_url'] as String,
      role: PlayerRoleX.fromString(map['role'] as String),
      attendances: map['attendances'] as int,
      goals: map['goals'] as int,
      yellowCards: map['yellow_cards'] as int,
      redCards: map['red_cards'] as int,
      active: map['active'] as bool,
    );
  }

  PlayerModel copyWith({
    String? id,
    DateTime? updatedAt,
    String? userName,
    String? fullName,
    String? imageUrl,
    PlayerRole? role,
    int? attendances,
    int? goals,
    int? yellowCards,
    int? redCards,
    bool? active,
  }) {
    return PlayerModel(
      id: id ?? this.id,
      updatedAt: updatedAt ?? this.updatedAt,
      userName: userName ?? this.userName,
      fullName: fullName ?? this.fullName,
      imageUrl: imageUrl ?? this.imageUrl,
      role: role ?? this.role,
      attendances: attendances ?? this.attendances,
      goals: goals ?? this.goals,
      yellowCards: yellowCards ?? this.yellowCards,
      redCards: redCards ?? this.redCards,
      active: active ?? this.active,
    );
  }
}
