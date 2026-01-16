import 'package:dartz/dartz.dart';
import 'package:real_amis/core/constants/constants.dart';
import 'package:real_amis/core/errors/exceptions.dart';
import 'package:real_amis/core/errors/failure.dart';
import 'package:real_amis/core/network/connection_checker.dart';
import 'package:real_amis/data/models/event/event_model.dart';
import 'package:real_amis/data/models/team/team_model.dart';
import 'package:real_amis/data/sources/event/event_local_data_source.dart';
import 'package:real_amis/data/sources/event/event_supabase_data_source.dart';
import 'package:real_amis/domain/entities/event/event_entity.dart';
import 'package:real_amis/domain/entities/event/event_type.dart';
import 'package:real_amis/domain/repositories/event/event_repository.dart';
import 'package:uuid/uuid.dart';

class EventRepositoryImpl implements EventRepository {
  final EventSupabaseDataSource eventSupabaseDataSource;
  final EventLocalDataSource eventLocalDataSource;
  final ConnectionChecker connectionChecker;

  EventRepositoryImpl(
    this.eventSupabaseDataSource,
    this.eventLocalDataSource,
    this.connectionChecker,
  );

  @override
  Future<Either<Failure, EventEntity>> uploadEvent({
    required String matchId,
    required String teamId,
    required String player,
    required int minutes,
    required EventType eventType,
  }) async {
    try {
      if (!await (connectionChecker.isConnected)) {
        return left(Failure(Constants.noConnectionErrorMessage));
      }
      EventModel eventModel = EventModel(
        id: Uuid().v1(),
        matchId: matchId,
        teamId: teamId,
        player: player,
        minutes: minutes,
        eventType: eventType,
      );
      await eventSupabaseDataSource.uploadEvent(eventModel);
      return right(eventModel);
    } on ServerException catch (e) {
      return left(Failure(e.message));
    }
  }

  @override
  Future<Either<Failure, List<EventEntity>>> getAllEvents() async {
    try {
      if (!await (connectionChecker.isConnected)) {
        final events = eventLocalDataSource.loadEvents();
        return right(events);
      }
      final events = await eventSupabaseDataSource.getAllEvents();
      eventLocalDataSource.uploadLocalEvents(events: events);
      return right(events);
    } on ServerException catch (e) {
      return left(Failure(e.message));
    }
  }

  @override
  Future<Either<Failure, List<EventEntity>>> getEventsByMatch({
    required String matchId,
  }) async {
    try {
      if (!await (connectionChecker.isConnected)) {
        final events = eventLocalDataSource
            .loadEvents()
            .where((e) => e.matchId == matchId)
            .toList();
        return right(events);
      }
      final events = await eventSupabaseDataSource.getEventsByMatch(
        matchId: matchId,
      );
      eventLocalDataSource.uploadLocalEvents(events: events);
      return right(events);
    } on ServerException catch (e) {
      return left(Failure(e.message));
    }
  }

  @override
  Future<Either<Failure, EventEntity>> updateEvent({
    required EventEntity event,
    String? matchId,
    String? teamId,
    String? player,
    int? minutes,
    EventType? eventType,
    TeamModel? team,
  }) async {
    try {
      if (!await (connectionChecker.isConnected)) {
        return left(Failure(Constants.noConnectionErrorMessage));
      }
      EventModel eventModel = EventModel(
        id: event.id,
        matchId: matchId ?? event.matchId,
        teamId: teamId ?? event.teamId,
        player: player ?? event.player,
        minutes: minutes ?? event.minutes,
        eventType: eventType ?? event.eventType,
        team: team ?? event.team,
      );
      await eventSupabaseDataSource.updateEvent(eventModel);
      return right(eventModel);
    } on ServerException catch (e) {
      return left(Failure(e.message));
    }
  }

  @override
  Future<Either<Failure, EventEntity>> deleteEvent({
    required String eventId,
  }) async {
    try {
      if (!await (connectionChecker.isConnected)) {
        return left(Failure(Constants.noConnectionErrorMessage));
      }
      final deletedEvent = await eventSupabaseDataSource.deleteEvent(
        eventId: eventId,
      );
      return right(deletedEvent);
    } on ServerException catch (e) {
      return left(Failure(e.message));
    }
  }
}
