import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:real_amis/common/helpers/app_colors_helper.dart';
import 'package:real_amis/common/helpers/is_dark_mode.dart';
import 'package:real_amis/common/widgets/appBar/app_bar_yes_nav.dart';
import 'package:real_amis/common/widgets/loader/loader.dart';
import 'package:real_amis/core/configs/theme/app_colors.dart';
import 'package:real_amis/core/utils/admin_only.dart';
import 'package:real_amis/core/utils/show_snackbar.dart';
import 'package:real_amis/domain/entities/event/event_entity.dart';
import 'package:real_amis/domain/entities/match/match_entity.dart';
import 'package:real_amis/presentation/event/pages/add_event_modal.dart';
import 'package:real_amis/presentation/event/pages/edit_event_modal.dart';
import 'package:real_amis/presentation/event/providers/event_notifier.dart';
import 'package:real_amis/presentation/match/pages/edit_match.dart';
import 'package:real_amis/presentation/match/providers/match_notifier.dart';
import 'package:real_amis/presentation/match/widgets/match_events_section.dart';
import 'package:real_amis/presentation/match/widgets/match_summary.dart';

class MatchViewerPage extends ConsumerStatefulWidget {
  final String matchId;
  final Color? backgroundColor;

  const MatchViewerPage({
    super.key,
    required this.matchId,
    this.backgroundColor,
  });

  static MaterialPageRoute route(String matchId, {Color? backgroundColor}) =>
      MaterialPageRoute(
        builder: (_) =>
            MatchViewerPage(matchId: matchId, backgroundColor: backgroundColor),
      );

  @override
  ConsumerState<MatchViewerPage> createState() => _MatchViewerPageState();
}

class _MatchViewerPageState extends ConsumerState<MatchViewerPage> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _refreshAll());
  }

  Future<void> _refreshAll() async {
    await Future.wait([
      ref.read(matchNotifierProvider.notifier).fetchAllMatches(),
      ref
          .read(eventNotifierProvider(widget.matchId).notifier)
          .fetchEventsByMatch(),
    ]);
  }

  MatchEntity? _getCurrentMatch(List<MatchEntity> matches) =>
      matches.firstWhereOrNull((m) => m.id == widget.matchId);

  Future<void> _openAddModal(MatchEntity match) async {
    final result = await showModalBottomSheet<String?>(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (_) => AddEventModal(match: match),
    );
    if (result != null && mounted) Future.microtask(() => _refreshAll());
  }

  Future<void> _openEditModal(EventEntity ev) async {
    final result = await showModalBottomSheet<String?>(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (_) => EditEventModal(event: ev),
    );
    if (result != null && mounted) Future.microtask(() => _refreshAll());
  }

  @override
  Widget build(BuildContext context) {
    final isDark = context.isDarkMode;
    final matchState = ref.watch(matchNotifierProvider);
    final eventState = ref.watch(eventNotifierProvider(widget.matchId));

    return Scaffold(
      appBar: AppBarYesNav(
        title: const Text('Dettaglio partita'),
        actions: [
          AdminOnly(
            child: IconButton(
              icon: Icon(
                Icons.edit,
                color: isDark ? AppColors.iconDark : AppColors.iconLight,
                size: 25,
              ),
              onPressed: () async {
                final matches = matchState.value ?? [];
                final match = _getCurrentMatch(matches);
                if (match == null) {
                  showSnackBar(context, 'Partita non trovata');
                  return;
                }
                await Navigator.push(context, EditMatchPage.route(match));
                if (mounted) Future.microtask(() => _refreshAll());
              },
            ),
          ),
          AdminOnly(
            child: IconButton(
              icon: Icon(
                Icons.check_circle_outline,
                color: isDark ? AppColors.iconDark : AppColors.iconLight,
                size: 25,
              ),
              tooltip: 'Segna come giocata',
              onPressed: () async {
                final matches = matchState.value ?? [];
                final match = _getCurrentMatch(matches);
                if (match == null) return;
                if (match.calledUpIds.isEmpty) {
                  showSnackBar(context, 'Nessun convocato per questa partita');
                  return;
                }
                final confirm = await showDialog<bool>( 
                  context: context,
                  builder: (_) => AlertDialog(
                    title: const Text('Segna come giocata'),
                    content: Text(
                      'Verranno incrementate le presenze di ${match.calledUpIds.length} giocatori. Continuare?',
                    ),
                    actions: [
                      TextButton(
                        onPressed: () => Navigator.pop(context, false),
                        child: const Text('Annulla'),
                      ),
                      TextButton(
                        onPressed: () => Navigator.pop(context, true),
                        child: const Text('Conferma'),
                      ),
                    ],
                  ),
                );
                if (confirm != true || !mounted) return;
                await ref
                    .read(matchNotifierProvider.notifier)
                    .markAsPlayed(match);
                if (context.mounted) {
                  showSnackBar(context, 'Presenze aggiornate!');
                }
              },
            ),
          ),
        ],
      ),
      body: matchState.when(
        data: (matches) {
          final match = _getCurrentMatch(matches);
          if (match == null) {
            final textColor = isDark
                ? AppColors.textDarkSecondary
                : AppColors.textLightSecondary;
            return Center(
              child: Text(
                'Partita non trovata.',
                style: TextStyle(color: textColor, fontSize: 16),
              ),
            );
          }

          final cardColor =
              widget.backgroundColor ??
              AppColorsHelper.cardForIndex(context, 0, isDark: isDark);

          return eventState.when(
            data: (events) {
              return RefreshIndicator(
                onRefresh: _refreshAll,
                child: SingleChildScrollView(
                  physics: const AlwaysScrollableScrollPhysics(),
                  padding: const EdgeInsets.only(bottom: 80),
                  child: Column(
                    children: [
                      MatchSummary(
                        match: match,
                        events: events,
                        backgroundColor: cardColor,
                      ),
                      const SizedBox(height: 12),
                      MatchEventsSection(
                        match: match,
                        events: events,
                        onEdit: _openEditModal,
                        baseColor: cardColor,
                      ),
                      const SizedBox(height: 12),
                      AdminOnly(
                        child: ElevatedButton.icon(
                          onPressed: () => _openAddModal(match),
                          icon: Icon(Icons.add, color: AppColors.iconDark),
                          label: const Text('Aggiungi evento'),
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
            loading: () => const Loader(),
            error: (e, _) => Center(child: Text('Errore caricamento eventi')),
          );
        },
        loading: () => const Loader(),
        error: (e, _) {
          WidgetsBinding.instance.addPostFrameCallback(
            (_) => showSnackBar(context, e.toString()),
          );
          return const SizedBox.shrink();
        },
      ),
    );
  }
}
