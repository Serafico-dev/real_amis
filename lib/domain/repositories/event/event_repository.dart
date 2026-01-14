import 'package:dartz/dartz.dart';
import 'package:real_amis/core/errors/failure.dart';
import 'package:real_amis/domain/entities/event/event_entity.dart';
import 'package:real_amis/domain/entities/event/event_type.dart';

abstract interface class EventRepository {
  Future<Either<Failure, EventEntity>> uploadEvent({
    required String teamId,
    required String player,
    required int minutes,
    required EventType eventType,
  });

  Future<Either<Failure, List<EventEntity>>> getAllEvents();

  Future<Either<Failure, EventEntity>> updateEvent({
    required EventEntity event,
    String? teamId,
    String? player,
    int? minutes,
    EventType? eventType,
  });

  Future<Either<Failure, EventEntity>> deleteEvent({required String eventId});
}
