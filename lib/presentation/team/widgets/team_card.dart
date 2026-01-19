import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:real_amis/domain/entities/team/team_entity.dart';
import 'package:real_amis/presentation/team/bloc/team_bloc.dart';
import 'package:real_amis/presentation/team/pages/edit_team.dart';

class TeamCard extends StatelessWidget {
  final TeamEntity team;
  final Color color;
  final bool isAdmin;
  const TeamCard({
    super.key,
    required this.team,
    required this.color,
    required this.isAdmin,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: isAdmin
          ? () async {
              await Navigator.push(context, EditTeamPage.route(team));
              if (context.mounted) {
                context.read<TeamBloc>().add(TeamFetchAllTeams());
              }
            }
          : null,
      child: Container(
        margin: EdgeInsets.all(8).copyWith(bottom: 4),
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(10),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Image.network(team.imageUrl, height: 100),
            Text(
              team.name,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              textAlign: TextAlign.center,
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
            ),
          ],
        ),
      ),
    );
  }
}
