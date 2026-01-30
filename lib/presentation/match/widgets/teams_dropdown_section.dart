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
    final homeTeams = filteredTeams
        .where((t) => awayTeam == null || t.id != awayTeam!.id)
        .toList();

    final awayTeams = filteredTeams
        .where((t) => homeTeam == null || t.id != homeTeam!.id)
        .toList();

    final uniqueHomeTeams = {for (var t in homeTeams) t.id: t}.values.toList();
    final uniqueAwayTeams = {for (var t in awayTeams) t.id: t}.values.toList();

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
          items: uniqueHomeTeams
              .map(
                (team) => DropdownMenuItem(value: team, child: Text(team.name)),
              )
              .toList(),
          initialValue: homeTeam,
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
          items: uniqueAwayTeams
              .map(
                (team) => DropdownMenuItem(value: team, child: Text(team.name)),
              )
              .toList(),
          initialValue: awayTeam,
          onChanged: onAwayChanged,
          validator: (v) => v == null ? 'Seleziona la squadra ospite' : null,
        ),
      ],
    );
  }
}
