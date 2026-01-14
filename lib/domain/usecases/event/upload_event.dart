import 'package:dartz/dartz.dart';
import 'package:real_amis/core/errors/failure.dart';
import 'package:real_amis/core/usecase/usecase.dart';
import 'package:real_amis/domain/entities/event/event_entity.dart';
import 'package:real_amis/domain/entities/event/event_type.dart';
import 'package:real_amis/domain/repositories/event/event_repository.dart';

class UploadEvent implements UseCase<EventEntity, UploadEventParams> {
  final EventRepository eventRepository;
  UploadEvent(this.eventRepository);

  @override
  Future<Either<Failure, EventEntity>> call(UploadEventParams params) async {
    return await eventRepository.uploadEvent(
      teamId: params.teamId,
      player: params.player,
      minutes: params.minutes,
      eventType: params.eventType,
    );
  }
}

class UploadEventParams {
  final String teamId;
  final String player;
  final int minutes;
  final EventType eventType;

  UploadEventParams({
    required this.teamId,
    required this.player,
    required this.minutes,
    required this.eventType,
  });
}
