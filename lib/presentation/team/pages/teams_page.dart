import 'package:cached_network_image/cached_network_image.dart';
import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:real_amis/presentation/auth/providers/app_user_state.dart';
import 'package:uuid/uuid.dart';

import 'package:real_amis/common/helpers/is_dark_mode.dart';
import 'package:real_amis/common/widgets/appBar/app_bar_no_nav.dart';
import 'package:real_amis/core/configs/theme/app_colors.dart';
import 'package:real_amis/core/utils/admin_only.dart';
import 'package:real_amis/domain/entities/league/league_entity.dart';
import 'package:real_amis/domain/entities/score/score_entity.dart';
import 'package:real_amis/domain/entities/team/team_entity.dart';
import 'package:real_amis/presentation/auth/providers/app_user_provider.dart';
import 'package:real_amis/presentation/league/providers/league_notifier.dart';
import 'package:real_amis/presentation/score/pages/update_score.dart';
import 'package:real_amis/presentation/score/providers/score_notifier.dart';
import 'package:real_amis/presentation/team/pages/add_new_team.dart';
import 'package:real_amis/presentation/team/pages/edit_team.dart';
import 'package:real_amis/presentation/team/providers/team_notifier.dart';

class TeamsPage extends ConsumerStatefulWidget {
  const TeamsPage({super.key});

  static MaterialPageRoute route() =>
      MaterialPageRoute(builder: (_) => const TeamsPage());

  @override
  ConsumerState<TeamsPage> createState() => _TeamsPageState();
}

class _TeamsPageState extends ConsumerState<TeamsPage> {
  LeagueEntity? selectedLeague;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _refresh());
  }

  Future<void> _refresh() async {
    final user = ref.read(appUserProvider).value?.user;
    if (user == null) return;

    await ref.read(teamNotifierProvider.notifier).fetchAllTeams();
    if (selectedLeague != null) {
      await ref
          .read(scoreNotifierProvider.notifier)
          .fetchScoresByLeague(selectedLeague!.id);
    }
  }

  int _scoreForTeam(String teamId, List<ScoreEntity> scores) {
    return scores
        .where((s) => s.teamId == teamId)
        .fold(0, (sum, s) => sum + s.score);
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

        final leaguesAsync = ref.watch(leagueNotifierProvider);
        final teamsAsync = ref.watch(teamNotifierProvider);
        final scoresAsync = ref.watch(scoreNotifierProvider);

        return Scaffold(
          backgroundColor: isDark ? AppColors.bgDark : AppColors.bgLight,
          appBar: AppBarNoNav(
            actions: [
              AdminOnly(
                child: IconButton(
                  tooltip: 'Aggiungi squadra',
                  icon: const Icon(Icons.add, size: 30),
                  onPressed: () async {
                    await Navigator.push(context, AddNewTeamPage.route());
                    if (!mounted) return;
                    _refresh();
                  },
                ),
              ),
            ],
          ),
          body: Column(
            children: [
              leaguesAsync.when(
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
                          onSelected: (_) {
                            setState(() => selectedLeague = league);
                            _refresh();
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
                error: (err, _) => Center(child: Text('Errore: $err')),
              ),
              const SizedBox(height: 8),
              Expanded(
                child: teamsAsync.when(
                  data: (teams) {
                    return scoresAsync.when(
                      data: (scores) {
                        if (selectedLeague == null) {
                          return const SizedBox.shrink();
                        }

                        final sortedTeams =
                            List<TeamEntity>.from(teams)
                                .where(
                                  (t) => selectedLeague!.teamIds.contains(t.id),
                                )
                                .toList()
                              ..sort((a, b) {
                                final scoreA = _scoreForTeam(a.id, scores);
                                final scoreB = _scoreForTeam(b.id, scores);
                                final scoreCompare = scoreB.compareTo(scoreA);
                                if (scoreCompare != 0) return scoreCompare;
                                return a.name.toLowerCase().compareTo(
                                  b.name.toLowerCase(),
                                );
                              });

                        if (sortedTeams.isEmpty) {
                          return const Center(
                            child: Text('Nessuna squadra trovata'),
                          );
                        }

                        return RefreshIndicator(
                          onRefresh: _refresh,
                          child: ListView.builder(
                            padding: const EdgeInsets.all(16),
                            itemCount: sortedTeams.length,
                            itemBuilder: (context, index) {
                              final team = sortedTeams[index];
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
                                onTap: user.isAdmin
                                    ? () async {
                                        await Navigator.push(
                                          context,
                                          EditTeamPage.route(team),
                                        );
                                        _refresh();
                                      }
                                    : null,
                                onEditScore: user.isAdmin
                                    ? () async {
                                        final result =
                                            await Navigator.push<ScoreEntity?>(
                                              context,
                                              UpdateScorePage.route(
                                                scoreEntity: scoreEntity,
                                                teamId: team.id,
                                                leagueId: selectedLeague!.id,
                                              ),
                                            );

                                        if (!mounted || result == null) return;

                                        final scoresNotifier = ref.read(
                                          scoreNotifierProvider.notifier,
                                        );
                                        final allScores =
                                            ref
                                                .read(scoreNotifierProvider)
                                                .value ??
                                            [];

                                        final exists = allScores.any(
                                          (s) => s.id == result.id,
                                        );
                                        if (exists) {
                                          await scoresNotifier.updateScore(
                                            result,
                                          );
                                        } else {
                                          await scoresNotifier.uploadScore(
                                            result,
                                          );
                                        }

                                        await scoresNotifier
                                            .fetchScoresByLeague(
                                              selectedLeague!.id,
                                            );
                                      }
                                    : null,
                              );
                            },
                          ),
                        );
                      },
                      loading: () =>
                          const Center(child: CircularProgressIndicator()),
                      error: (_, _) => const Center(
                        child: Text('Errore caricamento punteggi'),
                      ),
                    );
                  },
                  loading: () =>
                      const Center(child: CircularProgressIndicator()),
                  error: (_, _) =>
                      const Center(child: Text('Errore caricamento squadre')),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

class _TeamRow extends StatelessWidget {
  final TeamEntity team;
  final int score;
  final int index;
  final VoidCallback? onTap;
  final VoidCallback? onEditScore;

  const _TeamRow({
    required this.team,
    required this.score,
    required this.index,
    this.onTap,
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
                if (onEditScore != null)
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
