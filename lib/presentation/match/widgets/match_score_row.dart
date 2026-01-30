import 'package:flutter/material.dart';
import 'package:real_amis/common/helpers/is_dark_mode.dart';
import 'package:real_amis/core/configs/theme/app_colors.dart';
import 'package:real_amis/domain/entities/match/match_entity.dart';
import 'package:real_amis/domain/entities/event/event_entity.dart';
import 'package:real_amis/domain/entities/match/match_score.dart';
import 'package:real_amis/presentation/match/widgets/team_score_column.dart';

class MatchScoreRow extends StatelessWidget {
  final MatchEntity match;
  final List<EventEntity> events;
  const MatchScoreRow({super.key, required this.match, required this.events});

  @override
  Widget build(BuildContext context) {
    final vsColor = context.isDarkMode
        ? AppColors.textDarkPrimary
        : AppColors.textLightPrimary;

    final score = MatchScore.fromEvents(match, events);

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceAround,
      children: [
        Expanded(
          child: TeamScoreColumn(team: match.homeTeam!, score: score.home),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8),
          child: Text(
            'VS',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 24,
              color: vsColor,
            ),
          ),
        ),
        Expanded(
          child: TeamScoreColumn(team: match.awayTeam!, score: score.away),
        ),
      ],
    );
  }
}
