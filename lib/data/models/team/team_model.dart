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
      id: map['id'] as String? ?? '',
      updatedAt: map['updated_at'] != null
          ? DateTime.tryParse(map['updated_at'].toString()) ?? DateTime.now()
          : DateTime.now(),
      name: map['name'] as String? ?? '',
      imageUrl: map['image_url'] as String? ?? '',
    );
  }

  TeamModel copyWith({
    String? id,
    DateTime? updatedAt,
    String? name,
    String? imageUrl,
  }) {
    return TeamModel(
      id: id ?? this.id,
      updatedAt: updatedAt ?? this.updatedAt,
      name: name ?? this.name,
      imageUrl: imageUrl ?? this.imageUrl,
    );
  }
}
