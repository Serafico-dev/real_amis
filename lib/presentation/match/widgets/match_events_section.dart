import 'package:flutter/material.dart';
import 'package:real_amis/core/configs/theme/app_colors.dart';
import 'package:real_amis/domain/entities/event/event_entity.dart';
import 'package:real_amis/domain/entities/match/match_entity.dart';
import 'package:real_amis/presentation/match/widgets/event_column.dart';

class MatchEventsSection extends StatelessWidget {
  final MatchEntity match;
  final List<EventEntity> events;
  final void Function(EventEntity) onEdit;

  const MatchEventsSection({
    super.key,
    required this.match,
    required this.events,
    required this.onEdit,
  });

  @override
  Widget build(BuildContext context) {
    final homeEvents =
        events.where((e) => e.teamId == match.homeTeamId).toList()
          ..sort((a, b) => a.minutes.compareTo(b.minutes));

    final awayEvents =
        events.where((e) => e.teamId == match.awayTeamId).toList()
          ..sort((a, b) => a.minutes.compareTo(b.minutes));

    if (homeEvents.isEmpty && awayEvents.isEmpty) {
      return const Padding(
        padding: EdgeInsets.all(16),
        child: Center(child: Text('Nessun evento registrato')),
      );
    }

    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.tertiary.withValues(alpha: 0.15),
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
