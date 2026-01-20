import 'package:flutter/material.dart';
import 'package:real_amis/domain/entities/match/match_entity.dart';

class TeamSelector extends StatelessWidget {
  final MatchEntity match;
  final String teamSide;
  final ValueChanged<dynamic> onChanged;

  const TeamSelector({
    super.key,
    required this.match,
    required this.teamSide,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return RadioGroup(
      groupValue: teamSide,
      onChanged: onChanged,
      child: Column(
        children: [
          ListTile(
            leading: Radio<String>(value: 'home'),
            title: Text(match.homeTeam?.name ?? 'Home'),
            onTap: () => onChanged('home'),
          ),
          ListTile(
            leading: Radio<String>(value: 'away'),
            title: Text(match.awayTeam?.name ?? 'Away'),
            onTap: () => onChanged('away'),
          ),
        ],
      ),
    );
  }
}
