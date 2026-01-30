import 'package:flutter/material.dart';
import 'package:real_amis/common/helpers/app_colors_helper.dart';
import 'package:real_amis/domain/entities/match/match_entity.dart';
import 'package:real_amis/domain/entities/event/event_entity.dart';
import 'package:real_amis/presentation/match/pages/match_viewer.dart';
import 'package:real_amis/presentation/match/widgets/match_summary.dart';

class MatchesList extends StatelessWidget {
  final List<MatchEntity> matches;
  final List<EventEntity> allEvents; // Tutti gli eventi di tutte le partite
  final bool isDark;

  const MatchesList({
    super.key,
    required this.matches,
    required this.allEvents,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      key: const PageStorageKey('matches_list'),
      padding: const EdgeInsets.symmetric(vertical: 8),
      itemCount: matches.length,
      itemBuilder: (context, index) {
        final match = matches[index];
        final color = AppColorsHelper.cardForIndex(
          context,
          index,
          isDark: isDark,
        );

        final matchEvents = allEvents
            .where((e) => e.matchId == match.id)
            .toList();

        return MatchSummary(
          match: match,
          events: matchEvents,
          backgroundColor: color,
          onTap: () async {
            await Navigator.push(
              context,
              MatchViewerPage.route(match.id, backgroundColor: color),
            );
          },
        );
      },
    );
  }
}
