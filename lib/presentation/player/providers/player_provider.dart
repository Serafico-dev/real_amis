import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:real_amis/core/notifications/birthday_notification_service.dart';
import 'package:real_amis/data/repositories/player/player_repository_impl.dart';
import 'package:real_amis/domain/usecases/player/delete_player.dart';
import 'package:real_amis/domain/usecases/player/get_all_players.dart';
import 'package:real_amis/domain/usecases/player/update_player.dart';
import 'package:real_amis/domain/usecases/player/upload_player.dart';

final uploadPlayerProvider = Provider<UploadPlayer>((ref) {
  final repo = ref.read(playerRepositoryProvider);
  final birthdayService = ref.read(birthdayNotificationServiceProvider);
  return UploadPlayer(repo, birthdayService);
});

final updatePlayerProvider = Provider<UpdatePlayer>((ref) {
  final repo = ref.read(playerRepositoryProvider);
  final birthdayService = ref.read(birthdayNotificationServiceProvider);
  return UpdatePlayer(repo, birthdayService);
});

final getAllPlayersProvider = Provider<GetAllPlayers>((ref) {
  return GetAllPlayers(ref.read(playerRepositoryProvider));
});

final deletePlayerProvider = Provider<DeletePlayer>((ref) {
  return DeletePlayer(ref.read(playerRepositoryProvider));
});
