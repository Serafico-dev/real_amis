import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:real_amis/domain/entities/player/player_entity.dart';
import 'package:real_amis/domain/entities/player/player_role.dart';
import 'package:real_amis/presentation/player/bloc/player_bloc.dart';
import 'package:real_amis/presentation/player/pages/player_viewer.dart';

class PlayerCard extends StatelessWidget {
  final PlayerEntity player;
  final Color color;
  const PlayerCard({super.key, required this.player, required this.color});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () async {
        await Navigator.push(context, PlayerViewerPage.route(player.id));
        context.read().add(PlayerFetchAllPlayers());
      },
      child: Container(
        margin: EdgeInsets.all(16).copyWith(bottom: 4),
        padding: EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(10),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(player.role.value),
                Text(
                  player.fullName,
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
                Text("'${player.userName}'"),
                SizedBox(height: 10),
                Row(
                  children: [
                    Text(player.attendances.toString()),
                    SizedBox(width: 4),
                    Icon(Icons.stadium),
                    SizedBox(width: 10),
                    Text(player.goals.toString()),
                    SizedBox(width: 4),
                    Icon(Icons.sports_soccer),
                  ],
                ),
              ],
            ),
            Spacer(),
            ClipRRect(
              borderRadius: BorderRadiusGeometry.circular(10),
              child: Image.network(player.imageUrl, width: 125),
            ),
            player.active == true
                ? Icon(Icons.check_circle_outline, color: Colors.green)
                : Icon(Icons.not_interested, color: Colors.red),
          ],
        ),
      ),
    );
  }
}
