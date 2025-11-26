import 'package:dartz/dartz.dart';
import 'package:real_amis/core/errors/failure.dart';
import 'package:real_amis/core/usecase/usecase.dart';
import 'package:real_amis/domain/entities/player/player_entity.dart';
import 'package:real_amis/domain/repositories/player/player_repository.dart';

class GetAllPlayers implements UseCase<List<PlayerEntity>, NoParams> {
  final PlayerRepository playerRepository;
  GetAllPlayers(this.playerRepository);

  @override
  Future<Either<Failure, List<PlayerEntity>>> call(NoParams params) async {
    return await playerRepository.getAllPlayers();
  }
}
