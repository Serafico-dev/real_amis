import 'package:flutter/material.dart';
import 'package:real_amis/domain/entities/team/team_entity.dart';

class TeamsDropdownSection extends StatelessWidget {
  final TeamEntity? homeTeam;
  final TeamEntity? awayTeam;
  final ValueChanged<TeamEntity?> onHomeChanged;
  final ValueChanged<TeamEntity?> onAwayChanged;
  final List<TeamEntity> filteredTeams;

  const TeamsDropdownSection({
    super.key,
    required this.homeTeam,
    required this.awayTeam,
    required this.onHomeChanged,
    required this.onAwayChanged,
    required this.filteredTeams,
  });

  @override
  Widget build(BuildContext context) {
    final homeTeams = [
      if (homeTeam != null && !filteredTeams.contains(homeTeam)) homeTeam!,
      ...filteredTeams.where((t) => t != awayTeam),
    ];
    final awayTeams = [
      if (awayTeam != null && !filteredTeams.contains(awayTeam)) awayTeam!,
      ...filteredTeams.where((t) => t != homeTeam),
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        DropdownButtonFormField<TeamEntity>(
          isExpanded: true,
          decoration: const InputDecoration(
            labelText: 'Squadra in Casa',
            border: OutlineInputBorder(),
            floatingLabelBehavior: FloatingLabelBehavior.always,
          ),
          items: homeTeams
              .map(
                (team) => DropdownMenuItem(value: team, child: Text(team.name)),
              )
              .toList(),
          value: homeTeam,
          onChanged: onHomeChanged,
          validator: (v) => v == null ? 'Seleziona la squadra in casa' : null,
        ),
        const SizedBox(height: 15),
        DropdownButtonFormField<TeamEntity>(
          isExpanded: true,
          decoration: const InputDecoration(
            labelText: 'Squadra Ospite',
            border: OutlineInputBorder(),
            floatingLabelBehavior: FloatingLabelBehavior.always,
          ),
          items: awayTeams
              .map(
                (team) => DropdownMenuItem(value: team, child: Text(team.name)),
              )
              .toList(),
          value: awayTeam,
          onChanged: onAwayChanged,
          validator: (v) => v == null ? 'Seleziona la squadra ospite' : null,
        ),
      ],
    );
  }
}
