import 'package:flutter/material.dart';
import 'package:real_amis/common/helpers/is_dark_mode.dart';
import 'package:real_amis/core/configs/theme/app_colors.dart';
import 'package:real_amis/domain/entities/match/match_entity.dart';

class TeamSelector extends StatelessWidget {
  final MatchEntity match;
  final String teamSide;
  final ValueChanged<dynamic> onChanged;

  const TeamSelector({
    super.key,
    required this.match,
    required this.teamSide,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return SegmentedButton<String>(
      segments: [
        ButtonSegment(
          value: 'home',
          label: Text(match.homeTeam?.name ?? 'Home'),
        ),
        ButtonSegment(
          value: 'away',
          label: Text(match.awayTeam?.name ?? 'Away'),
        ),
      ],
      selected: {teamSide},
      onSelectionChanged: (selection) {
        onChanged(selection.first);
      },
      style: ButtonStyle(
        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
        visualDensity: VisualDensity.compact,

        backgroundColor: WidgetStateProperty.resolveWith((states) {
          final isSelected = states.contains(WidgetState.selected);

          if (isSelected) {
            return context.isDarkMode
                ? AppColors.tertiary.withValues(alpha: 0.35)
                : AppColors.primary.withValues(alpha: 0.25);
          }
          return Colors.transparent;
        }),

        foregroundColor: WidgetStateProperty.resolveWith((states) {
          final isSelected = states.contains(WidgetState.selected);

          if (isSelected) {
            return context.isDarkMode
                ? AppColors.textDarkPrimary
                : AppColors.textLightPrimary;
          }

          return context.isDarkMode
              ? AppColors.textDarkSecondary
              : AppColors.textLightSecondary;
        }),

        side: WidgetStateProperty.resolveWith((states) {
          final isSelected = states.contains(WidgetState.selected);

          return BorderSide(
            color: isSelected
                ? (context.isDarkMode ? AppColors.tertiary : AppColors.primary)
                : (context.isDarkMode
                      ? AppColors.textDarkSecondary.withValues(alpha: 0.3)
                      : AppColors.textLightSecondary.withValues(alpha: 0.3)),
            width: 1,
          );
        }),

        shape: WidgetStateProperty.all(
          RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        ),

        overlayColor: WidgetStateProperty.all(
          (context.isDarkMode ? AppColors.tertiary : AppColors.primary)
              .withValues(alpha: 0.08),
        ),
      ),
    );
  }
}
