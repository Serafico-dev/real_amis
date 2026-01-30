import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:real_amis/data/repositories/team/team_repository_impl.dart';
import 'package:real_amis/domain/usecases/team/delete_team.dart';
import 'package:real_amis/domain/usecases/team/get_all_teams.dart';
import 'package:real_amis/domain/usecases/team/update_team.dart';
import 'package:real_amis/domain/usecases/team/upload_team.dart';

final uploadTeamProvider = Provider<UploadTeam>((ref) {
  return UploadTeam(ref.read(teamRepositoryProvider));
});

final getAllTeamsProvider = Provider<GetAllTeams>((ref) {
  return GetAllTeams(ref.read(teamRepositoryProvider));
});

final updateTeamProvider = Provider<UpdateTeam>((ref) {
  return UpdateTeam(ref.read(teamRepositoryProvider));
});

final deleteTeamProvider = Provider<DeleteTeam>((ref) {
  return DeleteTeam(ref.read(teamRepositoryProvider));
});
