import 'package:real_amis/domain/entities/league/league_entity.dart';

class LeagueModel extends LeagueEntity {
  LeagueModel({
    required super.id,
    required super.name,
    required super.year,
    super.teamIds = const [],
  });

  Map<String, dynamic> toJson() {
    return <String, dynamic>{
      'id': id,
      'name': name,
      'year': year,
      'team_ids': teamIds,
    };
  }

  factory LeagueModel.fromJson(Map<String, dynamic> map) {
    return LeagueModel(
      id: map['id'] as String? ?? '',
      name: map['name'] as String? ?? '',
      year: map['year'] as String? ?? '',
      teamIds: map['team_ids'] != null
          ? List<String>.from(map['team_ids'] as List<dynamic>)
          : [],
    );
  }

  LeagueModel copyWith({
    String? id,
    String? name,
    String? year,
    List<String>? teamIds,
  }) {
    return LeagueModel(
      id: id ?? this.id,
      name: name ?? this.name,
      year: year ?? this.year,
      teamIds: teamIds ?? this.teamIds,
    );
  }
}
