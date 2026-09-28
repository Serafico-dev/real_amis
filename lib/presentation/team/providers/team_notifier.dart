import 'dart:io';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';
import 'package:real_amis/core/usecase/usecase.dart';
import 'package:real_amis/domain/entities/team/team_entity.dart';
import 'package:real_amis/domain/usecases/team/update_team.dart';
import 'package:real_amis/domain/usecases/team/upload_team.dart';
import 'package:real_amis/presentation/team/providers/team_provider.dart';

final teamNotifierProvider =
    StateNotifierProvider<TeamNotifier, AsyncValue<List<TeamEntity>>>(
      (ref) => TeamNotifier(ref),
    );

class TeamNotifier extends StateNotifier<AsyncValue<List<TeamEntity>>> {
  final Ref ref;

  TeamNotifier(this.ref) : super(const AsyncValue.loading()) {
    fetchAllTeams();
  }

  Future<void> fetchAllTeams() async {
    state = const AsyncValue.loading();

    final res = await ref.read(getAllTeamsProvider)(NoParams());
    state = res.fold(
      (failure) => AsyncValue.error(failure.message, StackTrace.current),
      (teams) => AsyncValue.data(teams),
    );
  }

  Future<void> uploadTeam({required String name, required File image}) async {
    state = const AsyncValue.loading();
    final res = await ref.read(uploadTeamProvider)(
      UploadTeamParams(name: name, image: image),
    );

    res.fold(
      (failure) =>
          state = AsyncValue.error(failure.message, StackTrace.current),
      (_) async => fetchAllTeams(),
    );
  }

  Future<void> updateTeam({
    required TeamEntity team,
    String? name,
    File? image,
  }) async {
    final res = await ref.read(updateTeamProvider)(
      UpdateTeamParams(team: team, name: name, image: image),
    );

    res.fold(
      (failure) =>
          state = AsyncValue.error(failure.message, StackTrace.current),
      (updatedTeam) {
        final currentTeams = state.value ?? [];
        final updatedList = [
          for (final t in currentTeams)
            if (t.id == updatedTeam.id) updatedTeam else t,
        ];
        state = AsyncValue.data(updatedList);
      },
    );
  }

  Future<void> deleteTeam(String teamId) async {
    state = const AsyncValue.loading();
    final res = await ref.read(deleteTeamProvider)(teamId);

    res.fold(
      (failure) =>
          state = AsyncValue.error(failure.message, StackTrace.current),
      (_) async => fetchAllTeams(),
    );
  }
}
