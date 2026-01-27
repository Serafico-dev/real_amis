import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:real_amis/common/widgets/loader/loader.dart';
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
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              DropdownButtonFormField<TeamEntity>(
                isExpanded: true,
                decoration: InputDecoration(
                  labelText: 'Squadra in Casa',
                  hintText: hintHome ?? 'Seleziona la squadra di casa',
                  border: const OutlineInputBorder(),
                  floatingLabelBehavior: FloatingLabelBehavior.always,
                ),
                initialValue: homeTeams.contains(homeTeam) ? homeTeam : null,
                items: homeTeams
                    .map(
                      (team) => DropdownMenuItem(
                        value: team,
                        child: Text(team.name, overflow: TextOverflow.ellipsis),
                      ),
                    )
                    .toList(),
                onChanged: onHomeChanged,
              ),
              const SizedBox(height: 15),
              DropdownButtonFormField<TeamEntity>(
                isExpanded: true,
                decoration: InputDecoration(
                  labelText: 'Squadra Ospite',
                  hintText: hintAway ?? 'Seleziona la squadra ospite',
                  border: const OutlineInputBorder(),
                  floatingLabelBehavior: FloatingLabelBehavior.always,
                ),
                initialValue: awayTeams.contains(awayTeam) ? awayTeam : null,
                items: awayTeams
                    .map(
                      (team) => DropdownMenuItem(
                        value: team,
                        child: Text(team.name, overflow: TextOverflow.ellipsis),
                      ),
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
