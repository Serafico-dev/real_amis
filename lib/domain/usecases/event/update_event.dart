import 'package:dartz/dartz.dart';
import 'package:real_amis/core/errors/failure.dart';
import 'package:real_amis/core/usecase/usecase.dart';
import 'package:real_amis/domain/entities/event/event_entity.dart';
import 'package:real_amis/domain/entities/event/event_type.dart';
import 'package:real_amis/domain/repositories/event/event_repository.dart';

class UpdateEvent implements UseCase<EventEntity, UpdateEventParams> {
  final EventRepository eventRepository;
  UpdateEvent(this.eventRepository);

  @override
  Future<Either<Failure, EventEntity>> call(UpdateEventParams params) async {
    return await eventRepository.updateEvent(
      event: params.event,
      teamId: params.teamId,
      player: params.player,
      minutes: params.minutes,
      eventType: params.eventType,
    );
  }
}

class UpdateEventParams {
  final EventEntity event;
  final String? teamId;
  final String? player;
  final int? minutes;
  final EventType? eventType;

  UpdateEventParams({
    required this.event,
    this.teamId,
    this.player,
    this.minutes,
    this.eventType,
  });
}
