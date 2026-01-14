part of 'event_bloc.dart';

@immutable
sealed class EventState {}

final class EventInitial extends EventState {}

final class EventLoading extends EventState {}

final class EventFailure extends EventState {
  final String error;
  EventFailure(this.error);
}

final class EventUploadSuccess extends EventState {}

final class EventDisplaySuccess extends EventState {
  final List<EventEntity> events;
  EventDisplaySuccess(this.events);
}

final class EventUpdateSuccess extends EventState {
  final EventEntity updatedEvent;
  EventUpdateSuccess(this.updatedEvent);
}

final class EventDeleteSuccess extends EventState {}
