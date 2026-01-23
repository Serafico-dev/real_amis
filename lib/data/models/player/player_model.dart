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
    super.birthday,
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
      'birthday': birthday?.toIso8601String(),
    };
  }

  factory PlayerModel.fromJson(Map<String, dynamic> map) {
    return PlayerModel(
      id: map['id'] ?? '',
      updatedAt: map['updated_at'] != null
          ? DateTime.parse(map['updated_at'])
          : DateTime.now(),
      userName: map['username'] ?? '',
      fullName: map['full_name'] ?? '',
      imageUrl: map['image_url'] ?? '',
      role: PlayerRoleX.fromString(map['role'] ?? ''),
      attendances: map['attendances'] ?? 0,
      goals: map['goals'] ?? 0,
      yellowCards: map['yellow_cards'] ?? 0,
      redCards: map['red_cards'] ?? 0,
      active: map['active'] ?? false,
      birthday: map['birthday'] != null
          ? DateTime.parse(map['birthday'])
          : null,
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
    DateTime? birthday,
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
      birthday: birthday ?? this.birthday,
    );
  }
}
