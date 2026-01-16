import 'package:dartz/dartz.dart';
import 'package:real_amis/core/errors/failure.dart';
import 'package:real_amis/core/usecase/usecase.dart';
import 'package:real_amis/domain/entities/event/event_entity.dart';
import 'package:real_amis/domain/repositories/event/event_repository.dart';

class GetEventsByMatch implements UseCase<List<EventEntity>, MatchIdParams> {
  final EventRepository repository;
  GetEventsByMatch(this.repository);

  @override
  Future<Either<Failure, List<EventEntity>>> call(MatchIdParams params) {
    return repository.getEventsByMatch(matchId: params.matchId);
  }
}

class MatchIdParams {
  final String matchId;
  MatchIdParams(this.matchId);
}
