import 'package:flutter/material.dart';
import 'package:real_amis/common/helpers/is_dark_mode.dart';
import 'package:real_amis/core/configs/theme/app_colors.dart';
import 'package:real_amis/core/utils/format_data.dart';
import 'package:real_amis/domain/entities/match/match_entity.dart';
import 'package:real_amis/presentation/match/widgets/full_time_label.dart';
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
    final isDark = context.isDarkMode;
    final textColor = isDark
        ? AppColors.textDarkPrimary
        : AppColors.textLightPrimary;

    Widget content() => Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        if (match.matchDay != null && match.matchDay!.isNotEmpty)
          Align(
            alignment: Alignment.centerRight,
            child: Text(
              match.matchDay!,
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 20,
                color: textColor,
              ),
            ),
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
        MatchScoreRow(match: match),
        if (showFullTime && match.matchDate.isBefore(DateTime.now()))
          const Padding(
            padding: EdgeInsets.only(top: 8),
            child: FullTimeLabel(),
          ),
      ],
    );

    return Container(
      margin: const EdgeInsets.all(16).copyWith(bottom: 4),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color:
            backgroundColor ??
            AppColors.matchCardColor(
              isDarkMode: context.isDarkMode,
              isEven: true,
            ),
        borderRadius: BorderRadius.circular(10),
      ),
      child: onTap != null
          ? InkWell(
              borderRadius: BorderRadius.circular(10),
              onTap: onTap,
              child: content(),
            )
          : content(),
    );
  }
}
