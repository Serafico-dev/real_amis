import 'package:dartz/dartz.dart';
import 'package:real_amis/core/errors/failure.dart';
import 'package:real_amis/core/usecase/usecase.dart';
import 'package:real_amis/domain/entities/event/event_entity.dart';
import 'package:real_amis/domain/repositories/event/event_repository.dart';

class GetAllEvents implements UseCase<List<EventEntity>, NoParams> {
  final EventRepository eventRepository;
  GetAllEvents(this.eventRepository);

  @override
  Future<Either<Failure, List<EventEntity>>> call(NoParams params) async {
    return await eventRepository.getAllEvents();
  }
}
