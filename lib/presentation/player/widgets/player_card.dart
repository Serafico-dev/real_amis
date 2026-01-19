import 'package:cached_network_image/cached_network_image.dart';
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
        if (context.mounted) {
          context.read().add(PlayerFetchAllPlayers());
        }
      },
      child: Container(
        margin: EdgeInsets.all(16).copyWith(bottom: 4),
        padding: EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(10),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(player.role.value, overflow: TextOverflow.ellipsis),
                  SizedBox(height: 4),
                  Text(
                    player.fullName,
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  Text(
                    "'${player.userName}'",
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  SizedBox(height: 10),
                  Row(
                    children: [
                      Text(player.attendances.toString()),
                      SizedBox(width: 4),
                      Icon(Icons.stadium, size: 16),
                      SizedBox(width: 10),
                      Text(player.goals.toString()),
                      SizedBox(width: 4),
                      Icon(Icons.sports_soccer, size: 16),
                    ],
                  ),
                ],
              ),
            ),
            SizedBox(width: 12),
            ClipRRect(
              borderRadius: BorderRadius.circular(10),
              child: CachedNetworkImage(
                imageUrl: player.imageUrl,
                width: 80,
                height: 80,
                fit: BoxFit.cover,
              ),
            ),
            SizedBox(width: 8),
            ConstrainedBox(
              constraints: BoxConstraints(minWidth: 24),
              child: player.active == true
                  ? Icon(Icons.check_circle_outline, color: Colors.green)
                  : Icon(Icons.not_interested, color: Colors.red),
            ),
          ],
        ),
      ),
    );
  }
}
