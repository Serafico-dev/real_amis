import 'package:flutter/material.dart';
import 'package:real_amis/common/helpers/app_colors_helper.dart';
import 'package:real_amis/common/helpers/is_dark_mode.dart';
import 'package:real_amis/core/configs/theme/app_colors.dart';
import 'package:real_amis/domain/entities/event/event_entity.dart';
import 'package:real_amis/domain/entities/match/match_entity.dart';
import 'package:real_amis/presentation/match/widgets/event_column.dart';

class MatchEventsSection extends StatelessWidget {
  final MatchEntity match;
  final List<EventEntity> events;
  final void Function(EventEntity) onEdit;
  final Color? baseColor;

  const MatchEventsSection({
    super.key,
    required this.match,
    required this.events,
    required this.onEdit,
    this.baseColor,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = context.isDarkMode;

    final defaultColor = AppColorsHelper.cardForIndex(
      context,
      0,
      alpha: 0.15,
      isDark: isDark,
    );
    final containerColor = baseColor?.withValues(alpha: (0.15)) ?? defaultColor;

    final homeEvents =
        events.where((e) => e.teamId == match.homeTeamId).toList()
          ..sort((a, b) => a.minutes.compareTo(b.minutes));

    final awayEvents =
        events.where((e) => e.teamId == match.awayTeamId).toList()
          ..sort((a, b) => a.minutes.compareTo(b.minutes));

    if (homeEvents.isEmpty && awayEvents.isEmpty) {
      final textColor = isDark
          ? AppColors.textDarkSecondary
          : AppColors.textLightSecondary;
      return Padding(
        padding: const EdgeInsets.all(16),
        child: Center(
          child: Text(
            'Nessun evento registrato',
            style: TextStyle(color: textColor),
          ),
        ),
      );
    }

    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: containerColor,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        children: [
          Expanded(
            child: EventColumn(
              title: match.homeTeam?.name ?? 'Casa',
              events: homeEvents,
              alignRight: false,
              onEdit: onEdit,
            ),
          ),
          Expanded(
            child: EventColumn(
              title: match.awayTeam?.name ?? 'Ospite',
              events: awayEvents,
              alignRight: true,
              onEdit: onEdit,
            ),
          ),
        ],
      ),
    );
  }
}
