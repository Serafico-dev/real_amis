import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:real_amis/common/helpers/is_dark_mode.dart';
import 'package:real_amis/common/widgets/appBar/app_bar_no_nav.dart';
import 'package:real_amis/common/widgets/loader/loader.dart';
import 'package:real_amis/core/configs/theme/app_colors.dart';
import 'package:real_amis/core/utils/admin_only.dart';
import 'package:real_amis/core/utils/show_snackbar.dart';
import 'package:real_amis/domain/entities/league/league_entity.dart';
import 'package:real_amis/domain/entities/match/match_entity.dart';
import 'package:real_amis/presentation/choose_mode/bloc/theme_cubit.dart';
import 'package:real_amis/presentation/league/bloc/league_bloc.dart';
import 'package:real_amis/presentation/league/pages/leagues_page.dart';
import 'package:real_amis/presentation/match/bloc/match_bloc.dart';
import 'package:real_amis/presentation/match/pages/add_new_match.dart';
import 'package:real_amis/presentation/match/widgets/empty_matches.dart';
import 'package:real_amis/presentation/match/widgets/matches_list.dart';

enum _AddMenuAction { match, league }

class MatchesPage extends StatefulWidget {
  const MatchesPage({super.key});

  static MaterialPageRoute route() =>
      MaterialPageRoute(builder: (_) => const MatchesPage());

  @override
  State<MatchesPage> createState() => _MatchesPageState();
}

class _MatchesPageState extends State<MatchesPage> {
  LeagueEntity? selectedLeague;

  @override
  void initState() {
    super.initState();
    _fetchMatches();
    _fetchLeagues();
  }

  void _fetchMatches() {
    context.read<MatchBloc>().add(MatchFetchAllMatches());
  }

  void _fetchLeagues() {
    context.read<LeagueBloc>().add(LeagueFetchAllLeagues());
  }

  Future<void> _refresh() async {
    _fetchMatches();
    await Future.delayed(const Duration(milliseconds: 300));
  }

  @override
  Widget build(BuildContext context) {
    final isDark = context.isDarkMode;

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

                    if (mounted) _fetchMatches();
                    break;
                  case _AddMenuAction.league:
                    await Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => const LeaguesPage()),
                    );
                    if (mounted) _fetchLeagues();
                    break;
                }
              },
              itemBuilder: (context) => const [
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
      body: BlocBuilder<ThemeCubit, ThemeMode>(
        builder: (context, themeMode) {
          return Column(
            children: [
              BlocBuilder<LeagueBloc, LeagueState>(
                builder: (context, leagueState) {
                  if (leagueState is LeagueDisplaySuccess) {
                    final leagues = List<LeagueEntity>.from(leagueState.leagues)
                      ..sort((a, b) => b.year.compareTo(a.year));

                    if (leagues.isEmpty) return const SizedBox.shrink();

                    selectedLeague ??= leagues.first;

                    return SizedBox(
                      height: 50,
                      child: ListView.separated(
                        scrollDirection: Axis.horizontal,
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        itemCount: leagues.length,
                        separatorBuilder: (_, _) => const SizedBox(width: 8),
                        itemBuilder: (context, index) {
                          final league = leagues[index];
                          final isSelected = league.id == selectedLeague?.id;

                          return ChoiceChip(
                            label: Text('${league.name} - ${league.year}'),
                            selected: isSelected,
                            onSelected: (_) {
                              setState(() {
                                selectedLeague = league;
                              });
                            },
                            backgroundColor: context.isDarkMode
                                ? AppColors.cardDark.withValues(alpha: 0.15)
                                : AppColors.cardLight.withValues(alpha: 0.15),
                            selectedColor: context.isDarkMode
                                ? AppColors.tertiary.withValues(alpha: 0.35)
                                : AppColors.primary.withValues(alpha: 0.25),
                            labelStyle: TextStyle(
                              color: isSelected
                                  ? context.isDarkMode
                                        ? AppColors.textDarkPrimary
                                        : AppColors.textLightPrimary
                                  : context.isDarkMode
                                  ? AppColors.textDarkSecondary
                                  : AppColors.textLightSecondary,
                              fontWeight: FontWeight.w500,
                            ),
                            side: BorderSide(
                              color: isSelected
                                  ? (context.isDarkMode
                                        ? AppColors.tertiary
                                        : AppColors.primary)
                                  : (context.isDarkMode
                                        ? AppColors.textDarkSecondary
                                              .withValues(alpha: 0.3)
                                        : AppColors.textLightSecondary
                                              .withValues(alpha: 0.3)),
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
                  } else if (leagueState is LeagueFailure) {
                    return Text(
                      'Errore nel caricamento dei campionati',
                      style: TextStyle(color: AppColors.logoRed),
                    );
                  } else {
                    return const Center(child: CircularProgressIndicator());
                  }
                },
              ),

              const SizedBox(height: 8),

              Expanded(
                child: BlocConsumer<MatchBloc, MatchState>(
                  listener: (context, state) {
                    if (state is MatchFailure) {
                      showSnackBar(context, state.error);
                    }
                    if (state is MatchUpdateSuccess ||
                        state is MatchDeleteSuccess) {
                      _fetchMatches();
                    }
                  },
                  builder: (context, state) {
                    if (state is MatchLoading) return const Loader();

                    if (state is MatchDisplaySuccess) {
                      final matches = _sortedMatches(state.matches)
                          .where(
                            (m) =>
                                selectedLeague == null ||
                                m.leagueId == selectedLeague!.id,
                          )
                          .toList();

                      if (matches.isEmpty) return const EmptyMatches();

                      return RefreshIndicator(
                        onRefresh: _refresh,
                        child: MatchesList(matches: matches, isDark: isDark),
                      );
                    }

                    return const SizedBox.shrink();
                  },
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  List<MatchEntity> _sortedMatches(List<MatchEntity> matches) {
    final list = List<MatchEntity>.from(matches);
    list.sort((a, b) => b.matchDate.compareTo(a.matchDate));
    return list;
  }
}
