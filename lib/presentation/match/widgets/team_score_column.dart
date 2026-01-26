import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:real_amis/common/helpers/is_dark_mode.dart';
import 'package:real_amis/core/configs/theme/app_colors.dart';
import 'package:real_amis/domain/entities/match/match_entity.dart';

class TeamScoreColumn extends StatelessWidget {
  final MatchEntity match;
  final bool isHome;

  const TeamScoreColumn({super.key, required this.match, required this.isHome});

  @override
  Widget build(BuildContext context) {
    final team = isHome ? match.homeTeam! : match.awayTeam!;
    final score = isHome ? match.homeTeamScore : match.awayTeamScore;

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
