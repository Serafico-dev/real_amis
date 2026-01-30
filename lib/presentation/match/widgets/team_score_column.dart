import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:real_amis/common/helpers/is_dark_mode.dart';
import 'package:real_amis/core/configs/theme/app_colors.dart';
import 'package:real_amis/domain/entities/team/team_entity.dart';

class TeamScoreColumn extends StatelessWidget {
  final TeamEntity team;
  final int score;

  const TeamScoreColumn({super.key, required this.team, required this.score});

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        SizedBox(
          height: 90,
          width: double.infinity,
          child: CachedNetworkImage(
            imageUrl: team.imageUrl,
            cacheKey: team.id,
            fit: BoxFit.contain,
            placeholder: (_, _) =>
                const Center(child: CircularProgressIndicator()),
            errorWidget: (_, _, _) => const Icon(Icons.shield, size: 40),
          ),
        ),
        const SizedBox(height: 8),
        Text(
          score.toString(),
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 24,
            color: context.isDarkMode
                ? AppColors.textDarkPrimary
                : AppColors.textLightPrimary,
          ),
        ),
      ],
    );
  }
}
