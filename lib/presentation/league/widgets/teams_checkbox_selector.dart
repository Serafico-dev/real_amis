import 'package:flutter/material.dart';
import 'package:real_amis/domain/entities/team/team_entity.dart';

class TeamsCheckboxSelector extends StatelessWidget {
  final List<TeamEntity> allTeams;
  final List<TeamEntity> selectedTeams;
  final ValueChanged<List<TeamEntity>> onChanged;

  const TeamsCheckboxSelector({
    super.key,
    required this.allTeams,
    required this.selectedTeams,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Seleziona le squadre',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 8),
        ...allTeams.map((team) {
          final isSelected = selectedTeams.contains(team);
          return CheckboxListTile(
            title: Text(team.name),
            value: isSelected,
            onChanged: (value) {
              final updated = List<TeamEntity>.from(selectedTeams);
              if (value == true) {
                updated.add(team);
              } else {
                updated.remove(team);
              }
              onChanged(updated);
            },
          );
        }),
      ],
    );
  }
}
