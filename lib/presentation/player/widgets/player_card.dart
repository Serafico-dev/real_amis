import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:real_amis/common/helpers/is_dark_mode.dart';
import 'package:real_amis/core/configs/theme/app_colors.dart';
import 'package:real_amis/domain/entities/player/player_entity.dart';
import 'package:real_amis/domain/entities/player/player_role.dart';
import 'package:real_amis/presentation/player/bloc/player_bloc.dart';
import 'package:real_amis/presentation/player/pages/player_viewer.dart';

class PlayerCard extends StatelessWidget {
  final PlayerEntity player;
  final Color color;

  const PlayerCard({super.key, required this.player, required this.color});

  Widget _statTile(BuildContext context, String value, Widget icon) => Column(
    children: [
      Text(
        value,
        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
          fontWeight: FontWeight.bold,
          fontSize: 16,
        ),
      ),
      const SizedBox(height: 4),
      icon,
    ],
  );

  @override
  Widget build(BuildContext context) {
    final isDark = context.isDarkMode;
    final textPrimary = Theme.of(context).textTheme.bodyMedium!.color;
    final textSecondary = Theme.of(context).textTheme.bodySmall!.color;

    return GestureDetector(
      onTap: () async {
        await Navigator.push(
          context,
          PlayerViewerPage.route(player.id, cardColor: color),
        );
        if (context.mounted) {
          context.read<PlayerBloc>().add(PlayerFetchAllPlayers());
        }
      },
      child: Container(
        margin: const EdgeInsets.all(16).copyWith(bottom: 4),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.25),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    player.role.value,
                    overflow: TextOverflow.ellipsis,
                    style: Theme.of(
                      context,
                    ).textTheme.bodySmall!.copyWith(color: textSecondary),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    player.fullName,
                    style: Theme.of(context).textTheme.titleMedium!.copyWith(
                      fontWeight: FontWeight.bold,
                      fontSize: 20,
                      color: textPrimary,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  Text(
                    "'${player.userName}'",
                    style: Theme.of(
                      context,
                    ).textTheme.bodySmall!.copyWith(color: textSecondary),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 12),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      _statTile(
                        context,
                        player.attendances.toString(),
                        const Icon(Icons.stadium, size: 28),
                      ),
                      const SizedBox(width: 12),
                      _statTile(
                        context,
                        player.goals.toString(),
                        const Icon(Icons.sports_soccer, size: 28),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            const SizedBox(width: 16),

            ClipRRect(
              borderRadius: BorderRadius.circular(10),
              child: CachedNetworkImage(
                imageUrl: player.imageUrl,
                cacheKey: player.id,
                height: 125,
                fit: BoxFit.cover,
                placeholder: (_, _) => Container(
                  height: 125,
                  color: isDark ? AppColors.cardDark : AppColors.cardLight,
                  child: const Center(child: CircularProgressIndicator()),
                ),
                errorWidget: (_, _, _) => Container(
                  height: 125,
                  color: isDark ? AppColors.cardDark : AppColors.cardLight,
                  child: const Center(
                    child: Icon(Icons.broken_image, size: 40),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
