import 'package:dartz/dartz.dart';
import 'package:real_amis/core/errors/failure.dart';
import 'package:real_amis/core/usecase/usecase.dart';
import 'package:real_amis/domain/entities/event/event_entity.dart';
import 'package:real_amis/domain/repositories/event/event_repository.dart';

class DeleteEvent implements UseCase<EventEntity, String> {
  final EventRepository eventRepository;
  DeleteEvent(this.eventRepository);

  @override
  Future<Either<Failure, EventEntity>> call(String eventId) async {
    return await eventRepository.deleteEvent(eventId: eventId);
  }
}
