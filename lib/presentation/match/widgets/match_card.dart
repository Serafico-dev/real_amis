import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:real_amis/common/helpers/is_dark_mode.dart';
import 'package:real_amis/core/configs/theme/app_colors.dart';
import 'package:real_amis/core/utils/format_data.dart';
import 'package:real_amis/domain/entities/match/match_entity.dart';
import 'package:real_amis/presentation/match/bloc/match_bloc.dart';
import 'package:real_amis/presentation/match/pages/match_viewer.dart';
import 'package:real_amis/presentation/match/widgets/team_score_column.dart';

class MatchCard extends StatelessWidget {
  final MatchEntity match;
  final Color color;

  const MatchCard({super.key, required this.match, required this.color});

  @override
  Widget build(BuildContext context) {
    final textColor = context.isDarkMode
        ? AppColors.textDarkPrimary
        : AppColors.textLightPrimary;

    return GestureDetector(
      onTap: () async {
        await Navigator.push(context, MatchViewerPage.route(match.id));
        if (context.mounted) {
          context.read<MatchBloc>().add(MatchFetchAllMatches());
        }
      },
      child: Container(
        margin: const EdgeInsets.all(16).copyWith(bottom: 4),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(10),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                Text(
                  match.matchDay ?? '',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 20,
                    color: textColor,
                  ),
                ),
              ],
            ),
            Text(
              formatDateByddMMYYYYnHHmm(match.matchDate),
              textAlign: TextAlign.center,
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 16,
                color: textColor,
              ),
            ),
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Expanded(child: TeamScoreColumn(match: match, isHome: true)),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 8),
                  child: Text(
                    'VS',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 24,
                      color: textColor,
                    ),
                  ),
                ),
                Expanded(child: TeamScoreColumn(match: match, isHome: false)),
              ],
            ),
            const SizedBox(height: 8),
            if (match.matchDate.isBefore(DateTime.now()))
              Text(
                'FULL TIME',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 20,
                  color: textColor,
                ),
                textAlign: TextAlign.center,
              ),
          ],
        ),
      ),
    );
  }
}
