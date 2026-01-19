import 'package:real_amis/data/models/team/team_model.dart';
import 'package:real_amis/domain/entities/event/event_entity.dart';
import 'package:real_amis/domain/entities/event/event_type.dart';

class EventModel extends EventEntity {
  EventModel({
    required super.id,
    required super.matchId,
    required super.teamId,
    required super.player,
    required super.minutes,
    required super.eventType,
    super.team,
  });

  Map<String, dynamic> toJson() {
    return <String, dynamic>{
      'id': id,
      'match_id': matchId,
      'team_id': teamId,
      'player': player,
      'minutes': minutes,
      'event': eventType.value,
    };
  }

  factory EventModel.fromJson(Map<String, dynamic> map) {
    return EventModel(
      id: map['id'] ?? '',
      matchId: map['match_id'] ?? '',
      teamId: map['team_id'] ?? '',
      player: map['player'] ?? '',
      minutes: map['minutes'] ?? 0,
      eventType: EventTypeX.fromString((map['event'] ?? '') as String),
      team: map['team'] != null
          ? TeamModel.fromJson(map['team'] as Map<String, dynamic>)
          : null,
    );
  }

  EventModel copyWith({
    String? id,
    String? matchId,
    String? teamId,
    String? player,
    int? minutes,
    EventType? eventType,
    TeamModel? team,
  }) {
    return EventModel(
      id: id ?? this.id,
      matchId: matchId ?? this.matchId,
      teamId: teamId ?? this.teamId,
      player: player ?? this.player,
      minutes: minutes ?? this.minutes,
      eventType: eventType ?? this.eventType,
      team: team ?? this.team,
    );
  }
}
