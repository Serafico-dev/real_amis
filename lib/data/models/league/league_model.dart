import 'package:real_amis/domain/entities/league/league_entity.dart';

class LeagueModel extends LeagueEntity {
  LeagueModel({required super.id, required super.name, required super.year});

  Map<String, dynamic> toJson() {
    return <String, dynamic>{'id': id, 'name': name, 'year': year};
  }

  factory LeagueModel.fromJson(Map<String, dynamic> map) {
    return LeagueModel(
      id: map['id'] ?? '',
      name: map['name'] ?? '',
      year: map['year'] ?? '',
    );
  }

  LeagueModel copyWith({String? id, String? name, String? year}) {
    return LeagueModel(
      id: id ?? this.id,
      name: name ?? this.name,
      year: year ?? this.year,
    );
  }
}
