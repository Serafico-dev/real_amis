part of 'event_bloc.dart';

@immutable
sealed class EventEvent {}

final class EventUpload extends EventEvent {
  final String matchId;
  final String teamId;
  final String player;
  final int minutes;
  final EventType eventType;

  EventUpload({
    required this.matchId,
    required this.teamId,
    required this.player,
    required this.minutes,
    required this.eventType,
  });
}

final class EventFetchAllEvents extends EventEvent {}

final class EventFetchMatchEvents extends EventEvent {
  final String matchId;
  EventFetchMatchEvents({required this.matchId});
}

final class EventUpdate extends EventEvent {
  final EventEntity event;
  final String? matchId;
  final String? teamId;
  final String? player;
  final int? minutes;
  final EventType? eventType;

  EventUpdate({
    required this.event,
    this.matchId,
    this.teamId,
    this.player,
    this.minutes,
    this.eventType,
  });
}

final class EventDelete extends EventEvent {
  final String eventId;
  EventDelete({required this.eventId});
}
