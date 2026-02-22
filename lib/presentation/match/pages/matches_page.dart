import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:real_amis/common/helpers/is_dark_mode.dart';
import 'package:real_amis/common/widgets/appBar/app_bar_no_nav.dart';
import 'package:real_amis/common/widgets/loader/loader.dart';
import 'package:real_amis/core/configs/theme/app_colors.dart';
import 'package:real_amis/core/utils/admin_only.dart';
import 'package:real_amis/core/utils/show_snackbar.dart';
import 'package:real_amis/domain/entities/league/league_entity.dart';
import 'package:real_amis/domain/entities/match/match_entity.dart';
import 'package:real_amis/presentation/auth/providers/app_user_provider.dart';
import 'package:real_amis/presentation/auth/providers/app_user_state.dart';
import 'package:real_amis/presentation/event/providers/all_events_notifier.dart';
import 'package:real_amis/presentation/league/pages/leagues_page.dart';
import 'package:real_amis/presentation/league/providers/league_notifier.dart';
import 'package:real_amis/presentation/match/pages/add_new_match.dart';
import 'package:real_amis/presentation/match/providers/match_notifier.dart';
import 'package:real_amis/presentation/match/widgets/empty_matches.dart';
import 'package:real_amis/presentation/match/widgets/matches_list.dart';

enum _AddMenuAction { match, league }

class MatchesPage extends ConsumerStatefulWidget {
  const MatchesPage({super.key});

  static MaterialPageRoute route() =>
      MaterialPageRoute(builder: (_) => const MatchesPage());

  @override
  ConsumerState<MatchesPage> createState() => _MatchesPageState();
}

class _MatchesPageState extends ConsumerState<MatchesPage> {
  LeagueEntity? selectedLeague;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final user = ref.read(appUserProvider).value?.user;
      if (user != null) {
        Future.wait([
          ref.read(matchNotifierProvider.notifier).fetchAllMatches(),
          ref.read(leagueNotifierProvider.notifier).fetchAllLeagues(),
        ]);
      }
    });
  }

  Future<void> _refresh() async {
    await ref.read(matchNotifierProvider.notifier).fetchAllMatches();
    await ref.read(allEventsNotifierProvider.notifier).fetchAllEvents();
    await Future.delayed(const Duration(milliseconds: 300));
  }

  List<MatchEntity> _sortedMatches(List<MatchEntity> matches) {
    final list = List<MatchEntity>.from(matches);
    list.sort((a, b) => b.matchDate.compareTo(a.matchDate));
    return list;
  }

  @override
  Widget build(BuildContext context) {
    final isDark = context.isDarkMode;
    final userAsync = ref.watch(appUserProvider);

    return userAsync.when(
      loading: () =>
          const Scaffold(body: Center(child: CircularProgressIndicator())),
      error: (_, _) =>
          const Scaffold(body: Center(child: Text('Errore utente'))),
      data: (userState) {
        final user = userState.user;
        if (user == null) {
          return const Scaffold(
            body: Center(child: Text('Utente non loggato')),
          );
        }

        final leagueState = ref.watch(leagueNotifierProvider);
        final matchState = ref.watch(matchNotifierProvider);
        final eventsState = ref.watch(allEventsNotifierProvider);

        return Scaffold(
          appBar: AppBarNoNav(
            actions: [
              AdminOnly(
                child: PopupMenuButton<_AddMenuAction>(
                  tooltip: 'Aggiungi',
                  icon: const Icon(Icons.menu, size: 30),
                  onSelected: (value) async {
                    switch (value) {
                      case _AddMenuAction.match:
                        await Navigator.push(
                          context,
                          AddNewMatchPage.route(selectedLeague: selectedLeague),
                        );
                        if (!mounted) return;
                        await ref
                            .read(matchNotifierProvider.notifier)
                            .fetchAllMatches();
                        break;
                      case _AddMenuAction.league:
                        await Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => const LeaguesPage(),
                          ),
                        );
                        if (!mounted) return;
                        await ref
                            .read(leagueNotifierProvider.notifier)
                            .fetchAllLeagues();
                        break;
                    }
                  },
                  itemBuilder: (_) => const [
                    PopupMenuItem(
                      value: _AddMenuAction.match,
                      child: Row(
                        children: [
                          Icon(Icons.sports_soccer),
                          SizedBox(width: 8),
                          Text('Crea partita'),
                        ],
                      ),
                    ),
                    PopupMenuItem(
                      value: _AddMenuAction.league,
                      child: Row(
                        children: [
                          Icon(Icons.emoji_events),
                          SizedBox(width: 8),
                          Text('Gestisci campionati'),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          body: Column(
            children: [
              leagueState.when(
                data: (leagues) {
                  if (leagues.isEmpty) return const SizedBox.shrink();
                  selectedLeague ??= leagues.first;

                  final sortedLeagues = List<LeagueEntity>.from(leagues)
                    ..sort((a, b) => b.year.compareTo(a.year));

                  return SizedBox(
                    height: 50,
                    child: ListView.separated(
                      scrollDirection: Axis.horizontal,
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      separatorBuilder: (_, _) => const SizedBox(width: 8),
                      itemCount: sortedLeagues.length,
                      itemBuilder: (context, index) {
                        final league = sortedLeagues[index];
                        final isSelected = league.id == selectedLeague?.id;
                        return ChoiceChip(
                          label: Text('${league.name} - ${league.year}'),
                          selected: isSelected,
                          onSelected: (_) =>
                              setState(() => selectedLeague = league),
                          backgroundColor: isDark
                              ? AppColors.cardDark.withValues(alpha: 0.15)
                              : AppColors.cardLight.withValues(alpha: 0.15),
                          selectedColor: isDark
                              ? AppColors.tertiary.withValues(alpha: 0.35)
                              : AppColors.primary.withValues(alpha: 0.25),
                          labelStyle: TextStyle(
                            color: isSelected
                                ? (isDark
                                      ? AppColors.textDarkPrimary
                                      : AppColors.textLightPrimary)
                                : (isDark
                                      ? AppColors.textDarkSecondary
                                      : AppColors.textLightSecondary),
                            fontWeight: FontWeight.w500,
                          ),
                          side: BorderSide(
                            color: isSelected
                                ? (isDark
                                      ? AppColors.tertiary
                                      : AppColors.primary)
                                : (isDark
                                      ? AppColors.textDarkSecondary.withValues(
                                          alpha: 0.3,
                                        )
                                      : AppColors.textLightSecondary.withValues(
                                          alpha: 0.3,
                                        )),
                            width: 1,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                          padding: const EdgeInsets.symmetric(horizontal: 12),
                        );
                      },
                    ),
                  );
                },
                loading: () => const SizedBox(
                  height: 50,
                  child: LinearProgressIndicator(),
                ),
                error: (e, _) => Text(
                  'Errore caricamento campionati',
                  style: TextStyle(color: AppColors.logoRed),
                ),
              ),
              const SizedBox(height: 8),
              Expanded(
                child: matchState.when(
                  data: (matches) {
                    final filtered = matches
                        .where(
                          (m) =>
                              selectedLeague == null ||
                              m.leagueId == selectedLeague!.id,
                        )
                        .toList();
                    if (filtered.isEmpty) return const EmptyMatches();
                    final sorted = _sortedMatches(filtered);

                    final allEvents = eventsState.value ?? [];

                    return RefreshIndicator(
                      onRefresh: _refresh,
                      child: MatchesList(
                        matches: sorted,
                        allEvents: allEvents,
                        isDark: isDark,
                      ),
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
              ),
            ],
          ),
        );
      },
    );
  }
}
