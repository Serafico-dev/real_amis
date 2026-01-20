import 'package:flutter/material.dart';
import 'package:real_amis/core/configs/theme/app_colors.dart';
import 'package:real_amis/domain/entities/match/match_entity.dart';
import 'package:real_amis/presentation/match/widgets/full_time_label.dart';
import 'package:real_amis/presentation/match/widgets/match_date.dart';
import 'package:real_amis/presentation/match/widgets/match_day.dart';
import 'package:real_amis/presentation/match/widgets/match_score_row.dart';

class MatchSummary extends StatelessWidget {
  final MatchEntity match;
  final Color? backgroundColor;
  final void Function()? onTap;
  final bool showFullTime;

  const MatchSummary({
    super.key,
    required this.match,
    this.backgroundColor,
    this.onTap,
    this.showFullTime = true,
  });

  @override
  Widget build(BuildContext context) {
    final content = Column(
      children: [
        MatchDay(day: match.matchDay),
        MatchDate(date: match.matchDate),
        const SizedBox(height: 12),
        MatchScoreRow(match: match),
        if (showFullTime && match.matchDate.isBefore(DateTime.now()))
          const Padding(
            padding: EdgeInsets.only(top: 8),
            child: FullTimeLabel(),
          ),
      ],
    );

    if (onTap != null) {
      return InkWell(
        borderRadius: BorderRadius.circular(10),
        onTap: onTap,
        child: _buildContainer(content),
      );
    }

    return _buildContainer(content);
  }

  Widget _buildContainer(Widget child) {
    return Container(
      margin: const EdgeInsets.all(16).copyWith(bottom: 4),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: backgroundColor ?? AppColors.tertiary,
        borderRadius: BorderRadius.circular(10),
      ),
      child: child,
    );
  }
}
