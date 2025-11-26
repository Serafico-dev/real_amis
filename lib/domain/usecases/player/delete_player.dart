import 'package:dartz/dartz.dart';
import 'package:real_amis/core/errors/failure.dart';
import 'package:real_amis/core/usecase/usecase.dart';
import 'package:real_amis/domain/entities/player/player_entity.dart';
import 'package:real_amis/domain/repositories/player/player_repository.dart';

class DeletePlayer implements UseCase<PlayerEntity, String> {
  final PlayerRepository playerRepository;
  DeletePlayer(this.playerRepository);

  @override
  Future<Either<Failure, PlayerEntity>> call(String playerId) async {
    return await playerRepository.deletePlayer(playerId: playerId);
  }
}
