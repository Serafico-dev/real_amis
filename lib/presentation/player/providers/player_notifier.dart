import 'dart:io';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';
import 'package:real_amis/core/notifications/birthday_notification_service.dart';
import 'package:real_amis/domain/entities/player/player_entity.dart';
import 'package:real_amis/domain/entities/player/player_role.dart';
import 'package:real_amis/domain/usecases/player/update_player.dart';
import 'package:real_amis/domain/usecases/player/upload_player.dart';
import 'package:real_amis/core/usecase/usecase.dart';
import 'package:real_amis/presentation/auth/providers/app_user_provider.dart';
import 'package:real_amis/presentation/auth/providers/app_user_state.dart';
import 'package:real_amis/presentation/player/providers/player_provider.dart';

final playerNotifierProvider =
    StateNotifierProvider<PlayerNotifier, AsyncValue<List<PlayerEntity>>>(
      (ref) => PlayerNotifier(ref),
    );

class PlayerNotifier extends StateNotifier<AsyncValue<List<PlayerEntity>>> {
  final Ref ref;

  PlayerNotifier(this.ref) : super(const AsyncLoading()) {
    fetchAllPlayers();
  }

  Future<void> fetchAllPlayers() async {
    state = const AsyncLoading();
    final user = ref.read(appUserProvider).value?.user;
    if (user == null) {
      state = const AsyncData([]);
      return;
    }

    final res = await ref.read(getAllPlayersProvider)(NoParams());
    state = res.fold(
      (failure) => AsyncError(failure.message, StackTrace.current),
      (players) {
        _scheduleBirthdayNotifications(players);
        return AsyncData(players);
      },
    );
  }

  void _scheduleBirthdayNotifications(List<PlayerEntity> players) {
    final service = ref.read(birthdayNotificationServiceProvider);
    for (final player in players) {
      if (player.birthday != null && player.active) {
        service.scheduleBirthday(
          playerId: player.id,
          fullName: player.fullName,
          birthday: player.birthday!,
        );
      }
    }
  }

  Future<void> uploadPlayer({
    required String userName,
    required String fullName,
    required File image,
    required PlayerRole role,
    required int attendances,
    required int goals,
    required int yellowCards,
    required int redCards,
    required bool active,
    required DateTime birthday,
  }) async {
    state = const AsyncLoading();
    final res = await ref.read(uploadPlayerProvider)(
      UploadPlayerParams(
        userName: userName,
        fullName: fullName,
        image: image,
        role: role,
        attendances: attendances,
        goals: goals,
        yellowCards: yellowCards,
        redCards: redCards,
        active: active,
        birthday: birthday,
      ),
    );

    res.fold(
      (failure) => state = AsyncError(failure.message, StackTrace.current),
      (_) async => fetchAllPlayers(),
    );
  }

  Future<void> updatePlayer({
    required PlayerEntity player,
    String? userName,
    String? fullName,
    File? image,
    PlayerRole? role,
    int? attendances,
    int? goals,
    int? yellowCards,
    int? redCards,
    bool? active,
    DateTime? birthday,
  }) async {
    final res = await ref.read(updatePlayerProvider)(
      UpdatePlayerParams(
        player: player,
        userName: userName,
        fullName: fullName,
        image: image,
        role: role,
        attendances: attendances,
        goals: goals,
        yellowCards: yellowCards,
        redCards: redCards,
        active: active,
        birthday: birthday,
      ),
    );

    res.fold(
      (failure) => state = AsyncError(failure.message, StackTrace.current),
      (updatedPlayer) {
        final currentPlayers = state.value ?? [];
        final updatedList = [
          for (final p in currentPlayers)
            if (p.id == updatedPlayer.id) updatedPlayer else p,
        ];
        state = AsyncData(updatedList);
        if (updatedPlayer.birthday != null && updatedPlayer.active) {
          ref
              .read(birthdayNotificationServiceProvider)
              .scheduleBirthday(
                playerId: updatedPlayer.id,
                fullName: updatedPlayer.fullName,
                birthday: updatedPlayer.birthday!,
              );
        } else {
          ref
              .read(birthdayNotificationServiceProvider)
              .cancel(updatedPlayer.id);
        }
      },
    );
  }

  Future<void> deletePlayer(String playerId) async {
    state = const AsyncLoading();
    ref.read(birthdayNotificationServiceProvider).cancel(playerId);

    final res = await ref.read(deletePlayerProvider)(playerId);
    res.fold(
      (failure) => state = AsyncError(failure.message, StackTrace.current),
      (_) async => fetchAllPlayers(),
    );
  }
}
