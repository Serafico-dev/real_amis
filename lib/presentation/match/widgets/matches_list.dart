import 'package:flutter/material.dart';
import 'package:real_amis/common/helpers/app_colors_helper.dart';
import 'package:real_amis/core/configs/theme/app_colors.dart';
import 'package:real_amis/domain/entities/match/match_entity.dart';
import 'package:real_amis/domain/entities/event/event_entity.dart';
import 'package:real_amis/presentation/match/pages/match_viewer.dart';
import 'package:real_amis/presentation/match/widgets/match_summary.dart';

/// Testo relativo alla data di una partita: "In corso", "Oggi", "Domani",
/// "Tra N giorni".
String nextMatchWhenLabel(DateTime matchDate, DateTime now) {
  if (!matchDate.isAfter(now)) return 'In corso';
  final days = DateUtils.dateOnly(
    matchDate,
  ).difference(DateUtils.dateOnly(now)).inDays;
  if (days == 0) return 'Oggi';
  if (days == 1) return 'Domani';
  return 'Tra $days giorni';
}

class MatchesList extends StatelessWidget {
  /// Partite già ordinate nel modo scelto dall'utente.
  final List<MatchEntity> matches;
  final List<EventEntity> allEvents;
  final bool isDark;

  /// Prossima partita da giocare: se presente appare evidenziata in cima.
  final MatchEntity? nextMatch;

  /// `true` = dalla più vecchia alla più recente.
  final bool ascending;

  /// Se `null` l'intestazione con l'ordinamento non viene mostrata.
  final ValueChanged<bool>? onSortChanged;

  const MatchesList({
    super.key,
    required this.matches,
    required this.allEvents,
    required this.isDark,
    this.nextMatch,
    this.ascending = true,
    this.onSortChanged,
  });

  @override
  Widget build(BuildContext context) {
    final textColor = isDark
        ? AppColors.textDarkPrimary
        : AppColors.textLightPrimary;
    final secondaryColor = isDark
        ? AppColors.textDarkSecondary
        : AppColors.textLightSecondary;

    final next = nextMatch;
    final headerCount =
        (next != null ? 1 : 0) + (onSortChanged != null ? 1 : 0);

    return ListView.builder(
      key: const PageStorageKey('matches_list'),
      padding: const EdgeInsets.symmetric(vertical: 8),
      itemCount: matches.length + headerCount,
      itemBuilder: (context, position) {
        var index = position;

        if (next != null) {
          if (index == 0) {
            return _buildNextMatch(context, next, textColor, secondaryColor);
          }
          index -= 1;
        }
        if (onSortChanged != null) {
          if (index == 0) return _buildSortHeader(textColor);
          index -= 1;
        }

        final match = matches[index];
        return _buildMatchCard(
          context,
          match,
          index,
          highlight: match.id == next?.id,
        );
      },
    );
  }

  Widget _buildMatchCard(
    BuildContext context,
    MatchEntity match,
    int colorIndex, {
    bool highlight = false,
  }) {
    final color = AppColorsHelper.cardForIndex(
      context,
      colorIndex,
      isDark: isDark,
    );

    final matchEvents = allEvents.where((e) => e.matchId == match.id).toList();

    return MatchSummary(
      match: match,
      events: matchEvents,
      backgroundColor: color,
      highlight: highlight,
      onTap: () async {
        await Navigator.push(
          context,
          MatchViewerPage.route(match.id, backgroundColor: color),
        );
      },
    );
  }

  Widget _buildNextMatch(
    BuildContext context,
    MatchEntity next,
    Color textColor,
    Color secondaryColor,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(20, 8, 20, 0),
          child: Row(
            children: [
              Expanded(
                child: Semantics(
                  header: true,
                  child: Text(
                    'Prossima partita',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 18,
                      color: textColor,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Text(
                nextMatchWhenLabel(next.matchDate, DateTime.now()),
                style: TextStyle(fontSize: 14, color: secondaryColor),
              ),
            ],
          ),
        ),
        _buildMatchCard(context, next, 0, highlight: true),
      ],
    );
  }

  Widget _buildSortHeader(Color textColor) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 20, 8, 0),
      child: Row(
        children: [
          Expanded(
            child: Semantics(
              header: true,
              child: Text(
                'Tutte le partite',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 18,
                  color: textColor,
                ),
              ),
            ),
          ),
          PopupMenuButton<bool>(
            tooltip: 'Ordina le partite',
            initialValue: ascending,
            onSelected: onSortChanged,
            itemBuilder: (_) => [
              CheckedPopupMenuItem<bool>(
                value: true,
                checked: ascending,
                child: const Text('Dalla più vecchia'),
              ),
              CheckedPopupMenuItem<bool>(
                value: false,
                checked: !ascending,
                child: const Text('Dalla più recente'),
              ),
            ],
            child: ConstrainedBox(
              constraints: const BoxConstraints(minHeight: 48),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.swap_vert, color: textColor),
                  const SizedBox(width: 6),
                  Text(
                    ascending ? 'Dalla più vecchia' : 'Dalla più recente',
                    style: TextStyle(color: textColor),
                  ),
                  const SizedBox(width: 8),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
