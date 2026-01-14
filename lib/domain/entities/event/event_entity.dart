import 'package:real_amis/domain/entities/event/event_type.dart';
import 'package:real_amis/domain/entities/team/team_entity.dart';

class EventEntity {
  final String id;
  final String teamId;
  final String player;
  final int minutes;
  final EventType eventType;
  final TeamEntity? team;

  EventEntity({
    required this.id,
    required this.teamId,
    required this.player,
    required this.minutes,
    required this.eventType,
    this.team,
  });
}
