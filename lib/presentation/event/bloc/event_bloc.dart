import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:real_amis/core/usecase/usecase.dart';
import 'package:real_amis/domain/entities/event/event_entity.dart';
import 'package:real_amis/domain/entities/event/event_type.dart';
import 'package:real_amis/domain/usecases/event/delete_event.dart';
import 'package:real_amis/domain/usecases/event/get_all_events.dart';
import 'package:real_amis/domain/usecases/event/get_events_by_match.dart';
import 'package:real_amis/domain/usecases/event/update_event.dart';
import 'package:real_amis/domain/usecases/event/upload_event.dart';

part 'event_event.dart';
part 'event_state.dart';

class EventBloc extends Bloc<EventEvent, EventState> {
  final UploadEvent _uploadEvent;
  final GetAllEvents _getAllEvents;
  final GetEventsByMatch _getEventsByMatch;
  final UpdateEvent _updateEvent;
  final DeleteEvent _deleteEvent;

  EventBloc({
    required UploadEvent uploadEvent,
    required GetAllEvents getAllEvents,
    required GetEventsByMatch getEventsByMatch,
    required UpdateEvent updateEvent,
    required DeleteEvent deleteEvent,
  }) : _uploadEvent = uploadEvent,
       _getAllEvents = getAllEvents,
       _getEventsByMatch = getEventsByMatch,
       _updateEvent = updateEvent,
       _deleteEvent = deleteEvent,
       super(EventInitial()) {
    on<EventUpload>(_onEventUpload);
    on<EventFetchAllEvents>(_onFetchAllEvents);
    on<EventFetchMatchEvents>(_onFetchMatchEvents);
    on<EventUpdate>(_onEventUpdate);
    on<EventDelete>(_onEventDelete);
  }
  void _onEventUpload(EventUpload event, Emitter<EventState> emit) async {
    emit(EventLoading());

    final res = await _uploadEvent(
      UploadEventParams(
        matchId: event.matchId,
        teamId: event.teamId,
        player: event.player,
        minutes: event.minutes,
        eventType: event.eventType,
      ),
    );

    res.fold(
      (l) => emit(EventFailure(l.message)),
      (r) => emit(EventUploadSuccess()),
    );
  }

  void _onFetchAllEvents(
    EventFetchAllEvents event,
    Emitter<EventState> emit,
  ) async {
    emit(EventLoading());

    final res = await _getAllEvents(NoParams());
    res.fold(
      (l) => emit(EventFailure(l.message)),
      (r) => emit(EventDisplaySuccess(r)),
    );
  }

  void _onFetchMatchEvents(
    EventFetchMatchEvents event,
    Emitter<EventState> emit,
  ) async {
    emit(EventLoading());

    final res = await _getEventsByMatch(MatchIdParams(event.matchId));
    res.fold(
      (l) => emit(EventFailure(l.message)),
      (r) => emit(EventDisplaySuccess(r)),
    );
  }

  void _onEventUpdate(EventUpdate event, Emitter<EventState> emit) async {
    emit(EventLoading());

    final res = await _updateEvent(
      UpdateEventParams(
        event: event.event,
        matchId: event.matchId,
        teamId: event.teamId,
        player: event.player,
        minutes: event.minutes,
        eventType: event.eventType,
      ),
    );

    res.fold((l) => emit(EventFailure(l.message)), (updatedEvent) {
      List<EventEntity> updatedEvents;
      if (state is EventDisplaySuccess) {
        updatedEvents = List<EventEntity>.from(
          (state as EventDisplaySuccess).events,
        );
        final idx = updatedEvents.indexWhere((p) => p.id == updatedEvent.id);
        if (idx >= 0) {
          updatedEvents[idx] = updatedEvent;
        } else {
          updatedEvents.add(updatedEvent);
        }
      } else {
        updatedEvents = [updatedEvent];
      }
      emit(EventDisplaySuccess(updatedEvents));
      emit(EventUpdateSuccess(updatedEvent));
    });
  }

  void _onEventDelete(EventDelete event, Emitter<EventState> emit) async {
    emit(EventLoading());

    final res = await _deleteEvent(event.eventId);

    res.fold(
      (l) => emit(EventFailure(l.message)),
      (r) => emit(EventDeleteSuccess()),
    );
  }
}
