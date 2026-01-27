import 'package:cached_network_image/cached_network_image.dart';
import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:real_amis/common/helpers/is_dark_mode.dart';
import 'package:real_amis/common/widgets/appBar/app_bar_no_nav.dart';
import 'package:real_amis/common/widgets/loader/loader.dart';
import 'package:real_amis/core/configs/theme/app_colors.dart';
import 'package:real_amis/core/utils/admin_only.dart';
import 'package:real_amis/domain/entities/league/league_entity.dart';
import 'package:real_amis/domain/entities/score/score_entity.dart';
import 'package:real_amis/domain/entities/team/team_entity.dart';
import 'package:real_amis/presentation/league/bloc/league_bloc.dart';
import 'package:real_amis/presentation/score/bloc/score_bloc.dart';
import 'package:real_amis/presentation/score/pages/update_score.dart';
import 'package:real_amis/presentation/team/bloc/team_bloc.dart';
import 'package:real_amis/presentation/team/pages/add_new_team.dart';
import 'package:real_amis/presentation/team/pages/edit_team.dart';
import 'package:uuid/uuid.dart';

class TeamsPage extends StatefulWidget {
  const TeamsPage({super.key});

  static MaterialPageRoute route() =>
      MaterialPageRoute(builder: (_) => const TeamsPage());

  @override
  State<TeamsPage> createState() => _TeamsPageState();
}

class _TeamsPageState extends State<TeamsPage> {
  LeagueEntity? selectedLeague;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _fetchInitialData();
    });
  }

  void _fetchInitialData() {
    final teamBloc = context.read<TeamBloc>();
    final leagueBloc = context.read<LeagueBloc>();
    final scoreBloc = context.read<ScoreBloc>();

    teamBloc.add(TeamFetchAllTeams());
    leagueBloc.add(LeagueFetchAllLeagues());
    scoreBloc.add(ScoreFetchAllScores());
  }

  Future<void> _refresh() async {
    context.read<TeamBloc>().add(TeamFetchAllTeams());
    if (selectedLeague != null) {
      context.read<ScoreBloc>().add(
        ScoreFetchByLeague(leagueId: selectedLeague!.id),
      );
    }
    await Future.delayed(const Duration(milliseconds: 300));
  }

  int _scoreForTeam(String teamId, List<ScoreEntity> scores) => scores
      .where((s) => s.teamId == teamId)
      .fold(0, (sum, s) => sum + s.score);

  @override
  Widget build(BuildContext context) {
    final isDark = context.isDarkMode;

    return Scaffold(
      appBar: AppBarNoNav(
        actions: [
          AdminOnly(
            child: IconButton(
              tooltip: 'Aggiungi squadra',
              icon: const Icon(Icons.add, size: 30),
              onPressed: () async {
                await Navigator.push(context, AddNewTeamPage.route());
                if (mounted) _refresh();
              },
            ),
          ),
        ],
      ),
      backgroundColor: isDark ? AppColors.bgDark : AppColors.bgLight,
      body: Column(
        children: [
          BlocBuilder<LeagueBloc, LeagueState>(
            builder: (context, state) {
              if (state is! LeagueDisplaySuccess || state.leagues.isEmpty) {
                return const SizedBox.shrink();
              }

              final leagues = List<LeagueEntity>.from(state.leagues)
                ..sort((a, b) => b.year.compareTo(a.year));

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
                        if (selectedLeague?.id != league.id) {
                          setState(() => selectedLeague = league);
                          context.read<ScoreBloc>().add(
                            ScoreFetchByLeague(leagueId: league.id),
                          );
                        }
                      },
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
                            ? (isDark ? AppColors.tertiary : AppColors.primary)
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
          ),

          Expanded(
            child: BlocBuilder<TeamBloc, TeamState>(
              builder: (context, teamsState) {
                if (teamsState is TeamLoading || teamsState is TeamInitial) {
                  return const Center(child: Loader());
                }
                if (teamsState is! TeamDisplaySuccess) {
                  return const SizedBox.shrink();
                }

                return BlocBuilder<ScoreBloc, ScoreState>(
                  builder: (context, scoreState) {
                    if (scoreState is ScoreFailure) {
                      return Center(child: Text(scoreState.error));
                    }
                    if (scoreState is ScoreLoading ||
                        scoreState is ScoreInitial) {
                      return const Center(child: Loader());
                    }
                    if (scoreState is! ScoreDisplaySuccess) {
                      return const SizedBox.shrink();
                    }

                    final scores = scoreState.scores;
                    if (selectedLeague == null) return const Loader();

                    final teams = List<TeamEntity>.from(teamsState.teams)
                      ..sort((a, b) {
                        final scoreA = _scoreForTeam(a.id, scores);
                        final scoreB = _scoreForTeam(b.id, scores);

                        final scoreCompare = scoreB.compareTo(scoreA);
                        if (scoreCompare != 0) return scoreCompare;
                        return a.name.toLowerCase().compareTo(
                          b.name.toLowerCase(),
                        );
                      });

                    if (teams.isEmpty) {
                      return const Center(
                        child: Text('Nessuna squadra trovata'),
                      );
                    }

                    return RefreshIndicator(
                      onRefresh: _refresh,
                      child: ListView.builder(
                        padding: const EdgeInsets.all(16),
                        itemCount: teams.length,
                        itemBuilder: (context, index) {
                          final team = teams[index];

                          final scoreEntity =
                              scores.firstWhereOrNull(
                                (s) =>
                                    s.teamId == team.id &&
                                    s.leagueId == selectedLeague!.id,
                              ) ??
                              ScoreEntity(
                                id: const Uuid().v4(),
                                teamId: team.id,
                                leagueId: selectedLeague!.id,
                                score: 0,
                              );

                          return _TeamRow(
                            team: team,
                            score: scoreEntity.score,
                            index: index,
                            onTap: () async {
                              final result = await Navigator.push(
                                context,
                                EditTeamPage.route(team),
                              );
                              if (!mounted) return;
                              if (result != null) _refresh();
                            },
                            onEditScore: () async {
                              final result = await Navigator.push<ScoreEntity?>(
                                context,
                                UpdateScorePage.route(
                                  scoreEntity: scoreEntity,
                                  teamId: team.id,
                                  leagueId: selectedLeague!.id,
                                ),
                              );
                              if (!context.mounted || result == null) return;

                              final bloc = context.read<ScoreBloc>();
                              if (scores.any((s) => s.id == result.id)) {
                                bloc.add(
                                  ScoreUpdate(
                                    scoreEntity: result,
                                    teamId: result.teamId,
                                    leagueId: result.leagueId,
                                    score: result.score,
                                  ),
                                );
                              } else {
                                bloc.add(
                                  ScoreUpload(
                                    teamId: result.teamId,
                                    leagueId: result.leagueId,
                                    score: result.score,
                                  ),
                                );
                              }

                              bloc.add(
                                ScoreFetchByLeague(
                                  leagueId: selectedLeague!.id,
                                ),
                              );
                            },
                          );
                        },
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class _TeamRow extends StatelessWidget {
  final TeamEntity team;
  final int score;
  final int index;
  final VoidCallback onTap;
  final VoidCallback? onEditScore;

  const _TeamRow({
    required this.team,
    required this.score,
    required this.index,
    required this.onTap,
    this.onEditScore,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = context.isDarkMode;
    final rowColor = index.isEven
        ? (isDark ? AppColors.tertiary : AppColors.primary)
        : (isDark ? AppColors.cardDark : AppColors.cardLight);

    return InkWell(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(12),
        margin: const EdgeInsets.only(bottom: 6),
        decoration: BoxDecoration(
          color: rowColor.withValues(alpha: 0.25),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Row(
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(10),
              child: CachedNetworkImage(
                imageUrl: team.imageUrl,
                cacheKey: team.id,
                width: 40,
                height: 40,
                fit: BoxFit.cover,
                placeholder: (_, _) => const SizedBox(
                  width: 40,
                  height: 40,
                  child: Center(
                    child: CircularProgressIndicator(strokeWidth: 2),
                  ),
                ),
                errorWidget: (_, _, _) =>
                    const Icon(Icons.broken_image, size: 40),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                team.name,
                style: TextStyle(
                  color: isDark
                      ? AppColors.textDarkPrimary
                      : AppColors.textLightPrimary,
                  fontSize: 16,
                ),
              ),
            ),
            Row(
              children: [
                Text(
                  score.toString(),
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                    color: isDark
                        ? AppColors.textDarkPrimary
                        : AppColors.textLightPrimary,
                  ),
                ),
                const SizedBox(width: 8),
                IconButton(
                  icon: const Icon(Icons.edit, size: 20),
                  onPressed: onEditScore,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
