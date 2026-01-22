import 'package:real_amis/domain/entities/team/team_entity.dart';

class TeamModel extends TeamEntity {
  TeamModel({
    required super.id,
    required super.updatedAt,
    required super.name,
    required super.imageUrl,
  });

  Map<String, dynamic> toJson() {
    return <String, dynamic>{
      'id': id,
      'updated_at': updatedAt.toIso8601String(),
      'name': name,
      'image_url': imageUrl,
    };
  }

  factory TeamModel.fromJson(Map<String, dynamic> map) {
    return TeamModel(
      id: map['id'] ?? '',
      updatedAt: map['updated_at'] == null
          ? DateTime.now()
          : DateTime.parse(map['updated_at']),
      name: map['name'] ?? '',
      imageUrl: map['image_url'] ?? '',
    );
  }
  TeamModel copyWith({
    String? id,
    DateTime? updatedAt,
    String? name,
    String? imageUrl,
    int? score,
  }) {
    return TeamModel(
      id: id ?? this.id,
      updatedAt: updatedAt ?? this.updatedAt,
      name: name ?? this.name,
      imageUrl: imageUrl ?? this.imageUrl,
    );
  }
}
