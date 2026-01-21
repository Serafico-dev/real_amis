import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:real_amis/common/helpers/is_dark_mode.dart';
import 'package:real_amis/common/widgets/loader/loader.dart';
import 'package:real_amis/core/configs/theme/app_colors.dart';
import 'package:real_amis/domain/entities/team/team_entity.dart';
import 'package:real_amis/presentation/team/bloc/team_bloc.dart';

class TeamsDropdownSection extends StatelessWidget {
  final TeamEntity? homeTeam;
  final TeamEntity? awayTeam;
  final ValueChanged<TeamEntity?> onHomeChanged;
  final ValueChanged<TeamEntity?> onAwayChanged;
  final String? hintHome;
  final String? hintAway;

  const TeamsDropdownSection({
    super.key,
    required this.homeTeam,
    required this.awayTeam,
    required this.onHomeChanged,
    required this.onAwayChanged,
    this.hintHome,
    this.hintAway,
  });

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<TeamBloc, TeamState>(
      builder: (context, state) {
        if (state is TeamLoading) return const Loader();
        if (state is TeamFailure) {
          return Center(child: Text(state.error));
        }

        if (state is TeamDisplaySuccess) {
          final sortedTeams = List<TeamEntity>.from(state.teams)
            ..sort(
              (a, b) => a.name.toLowerCase().compareTo(b.name.toLowerCase()),
            );

          final homeTeams = sortedTeams
              .where((t) => awayTeam == null || t.id != awayTeam!.id)
              .toList();

          final awayTeams = sortedTeams
              .where((t) => homeTeam == null || t.id != homeTeam!.id)
              .toList();

          return Column(
            children: [
              DropdownButtonFormField<TeamEntity>(
                initialValue: homeTeams.contains(homeTeam) ? homeTeam : null,
                hint: Text(
                  hintHome ?? 'Squadra in Casa',
                  style: TextStyle(
                    color: context.isDarkMode
                        ? AppColors.textDarkSecondary
                        : AppColors.textLightSecondary,
                  ),
                ),
                items: homeTeams
                    .map(
                      (team) =>
                          DropdownMenuItem(value: team, child: Text(team.name)),
                    )
                    .toList(),
                onChanged: onHomeChanged,
              ),
              const SizedBox(height: 15),
              DropdownButtonFormField<TeamEntity>(
                initialValue: awayTeams.contains(awayTeam) ? awayTeam : null,
                hint: Text(
                  hintAway ?? 'Squadra Ospite',
                  style: TextStyle(
                    color: context.isDarkMode
                        ? AppColors.textDarkSecondary
                        : AppColors.textLightSecondary,
                  ),
                ),
                items: awayTeams
                    .map(
                      (team) =>
                          DropdownMenuItem(value: team, child: Text(team.name)),
                    )
                    .toList(),
                onChanged: onAwayChanged,
              ),
            ],
          );
        }

        return const SizedBox.shrink();
      },
    );
  }
}
