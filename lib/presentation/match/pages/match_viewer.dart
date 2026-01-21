import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:real_amis/common/helpers/app_colors_helper.dart';
import 'package:real_amis/common/helpers/is_dark_mode.dart';
import 'package:real_amis/common/widgets/appBar/app_bar_yes_nav.dart';
import 'package:real_amis/common/widgets/loader/loader.dart';
import 'package:real_amis/core/configs/theme/app_colors.dart';
import 'package:real_amis/core/utils/admin_only.dart';
import 'package:real_amis/core/utils/show_snackbar.dart';
import 'package:real_amis/domain/entities/event/event_entity.dart';
import 'package:real_amis/domain/entities/match/match_entity.dart';
import 'package:real_amis/presentation/event/bloc/event_bloc.dart';
import 'package:real_amis/presentation/event/pages/add_event_modal.dart';
import 'package:real_amis/presentation/event/pages/edit_event_modal.dart';
import 'package:real_amis/presentation/match/bloc/match_bloc.dart';
import 'package:real_amis/presentation/match/pages/edit_match.dart';
import 'package:real_amis/presentation/match/widgets/match_events_section.dart';
import 'package:real_amis/presentation/match/widgets/match_summary.dart';

class MatchViewerPage extends StatefulWidget {
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
  State<MatchViewerPage> createState() => _MatchViewerPageState();
}

class _MatchViewerPageState extends State<MatchViewerPage> {
  @override
  void initState() {
    super.initState();
    _refreshAll();
  }

  void _refreshAll() {
    context.read<MatchBloc>().add(MatchFetchAllMatches());
    context.read<EventBloc>().add(
      EventFetchMatchEvents(matchId: widget.matchId),
    );
  }

  MatchEntity? _getCurrentMatch(MatchState state) {
    if (state is MatchDisplaySuccess) {
      return state.matches.firstWhere((m) => m.id == widget.matchId);
    }
    if (state is MatchUpdateSuccess) return state.updatedMatch;
    return null;
  }

  Future<void> _openAddModal(MatchEntity match) async {
    final result = await showModalBottomSheet<String?>(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (_) => AddEventModal(match: match),
    );

    if (result != null && mounted) _refreshAll();
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

    if (result != null && mounted) _refreshAll();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = context.isDarkMode;

    return Scaffold(
      appBar: AppBarYesNav(
        title: const Text('Dettaglio partita'),
        actions: [
          AdminOnly(
            child: IconButton(
              icon: Icon(
                Icons.edit,
                color: isDark ? AppColors.iconDark : AppColors.iconPrimary,
                size: 25,
              ),
              onPressed: () async {
                final state = context.read<MatchBloc>().state;
                final match = _getCurrentMatch(state);

                if (match == null) {
                  showSnackBar(context, 'Partita non trovata');
                  return;
                }

                await Navigator.push(context, EditMatchPage.route(match));
                if (mounted) _refreshAll();
              },
            ),
          ),
        ],
      ),
      body: BlocBuilder<MatchBloc, MatchState>(
        builder: (context, matchState) {
          if (matchState is MatchLoading) return const Loader();

          final match = _getCurrentMatch(matchState);
          if (match == null || matchState is MatchDeleteSuccess) {
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

          return RefreshIndicator(
            color: AppColors.accent,
            onRefresh: () async => _refreshAll(),
            child: SingleChildScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              padding: const EdgeInsets.only(bottom: 80),
              child: Column(
                children: [
                  MatchSummary(
                    match: match,
                    showFullTime: true,
                    backgroundColor: cardColor,
                  ),
                  const SizedBox(height: 12),
                  BlocBuilder<EventBloc, EventState>(
                    builder: (context, eventState) {
                      final events = eventState is EventDisplaySuccess
                          ? eventState.events
                          : <EventEntity>[];
                      return MatchEventsSection(
                        match: match,
                        events: events,
                        onEdit: _openEditModal,
                        baseColor: cardColor,
                      );
                    },
                  ),
                  const SizedBox(height: 12),
                  AdminOnly(
                    child: ElevatedButton.icon(
                      onPressed: () => _openAddModal(match),
                      icon: Icon(Icons.add, color: AppColors.iconDark),
                      label: const Text('Aggiungi evento'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: isDark
                            ? AppColors.buttonPrimaryDark
                            : AppColors.buttonPrimary,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
