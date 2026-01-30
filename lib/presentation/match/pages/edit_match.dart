import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:real_amis/common/helpers/is_dark_mode.dart';
import 'package:real_amis/common/widgets/appBar/app_bar_yes_nav.dart';
import 'package:real_amis/core/configs/theme/app_colors.dart';
import 'package:real_amis/core/utils/show_snackbar.dart';
import 'package:real_amis/domain/entities/league/league_entity.dart';
import 'package:real_amis/domain/entities/match/match_entity.dart';
import 'package:real_amis/domain/entities/team/team_entity.dart';
import 'package:real_amis/domain/usecases/match/update_match.dart';
import 'package:real_amis/presentation/match/widgets/match_form_section.dart';
import 'package:real_amis/presentation/match/widgets/teams_dropdown_section.dart';
import 'package:real_amis/presentation/team/providers/team_notifier.dart';
import 'package:real_amis/presentation/league/providers/league_notifier.dart';
import 'package:real_amis/presentation/match/providers/match_notifier.dart';

class EditMatchPage extends ConsumerStatefulWidget {
  static MaterialPageRoute route(MatchEntity match) =>
      MaterialPageRoute(builder: (_) => EditMatchPage(match: match));

  final MatchEntity match;
  const EditMatchPage({super.key, required this.match});

  @override
  ConsumerState<EditMatchPage> createState() => _EditMatchPageState();
}

class _EditMatchPageState extends ConsumerState<EditMatchPage> {
  DateTime? selectedDate;
  TeamEntity? homeTeam;
  TeamEntity? awayTeam;
  LeagueEntity? selectedLeague;

  final matchDayController = TextEditingController();
  final formKey = GlobalKey<FormState>();

  List<TeamEntity> filteredTeams = [];

  @override
  void initState() {
    super.initState();
    selectedDate = widget.match.matchDate;
    homeTeam = widget.match.homeTeam;
    awayTeam = widget.match.awayTeam;

    matchDayController.text = widget.match.matchDay ?? '';

    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(teamNotifierProvider.notifier).fetchAllTeams();
      ref.read(leagueNotifierProvider.notifier).fetchAllLeagues();
    });
  }

  @override
  void dispose() {
    matchDayController.dispose();
    super.dispose();
  }

  void _updateFilteredTeams(List<TeamEntity> allTeams, LeagueEntity? league) {
    if (league == null) {
      filteredTeams = [];
      return;
    }

    List<TeamEntity> leagueTeams = league.teamIds.isEmpty
        ? List<TeamEntity>.from(allTeams)
        : allTeams.where((t) => league.teamIds.contains(t.id)).toList();

    Map<String, TeamEntity> teamMap = {for (var t in leagueTeams) t.id: t};

    if (homeTeam != null) teamMap[homeTeam!.id] = homeTeam!;
    if (awayTeam != null) teamMap[awayTeam!.id] = awayTeam!;

    filteredTeams = teamMap.values.toList()
      ..sort((a, b) => a.name.toLowerCase().compareTo(b.name.toLowerCase()));
  }

  Future<void> _updateMatch() async {
    if (!formKey.currentState!.validate() ||
        selectedDate == null ||
        homeTeam == null ||
        awayTeam == null ||
        selectedLeague == null) {
      if (selectedLeague == null) {
        showSnackBar(context, 'Seleziona un campionato!');
      }
      return;
    }

    if (homeTeam!.id == awayTeam!.id) {
      showSnackBar(
        context,
        'Le squadre in casa e ospite non possono essere uguali!',
      );
      return;
    }

    try {
      await ref
          .read(matchNotifierProvider.notifier)
          .updateMatch(
            UpdateMatchParams(
              match: widget.match,
              matchDate: selectedDate!,
              homeTeamId: homeTeam!.id,
              awayTeamId: awayTeam!.id,
              matchDay: matchDayController.text.trim().isNotEmpty
                  ? matchDayController.text.toUpperCase().trim()
                  : widget.match.matchDay,
              leagueId: selectedLeague!.id,
            ),
          );

      if (mounted) {
        showSnackBar(context, 'Partita aggiornata con successo');
        Navigator.of(context).pop();
      }
    } catch (e) {
      if (mounted) showSnackBar(context, 'Errore: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = context.isDarkMode;
    final allTeams = ref.watch(teamNotifierProvider).value ?? [];
    final allLeagues = ref.watch(leagueNotifierProvider).value ?? [];

    if (selectedLeague == null && allLeagues.isNotEmpty) {
      selectedLeague = allLeagues.firstWhere(
        (l) => l.id == widget.match.leagueId,
        orElse: () => allLeagues.first,
      );
    }

    if (allTeams.isNotEmpty && selectedLeague != null) {
      _updateFilteredTeams(allTeams, selectedLeague);
    }

    return Scaffold(
      appBar: AppBarYesNav(
        title: const Text('Modifica partita'),
        actions: [
          IconButton(
            icon: Icon(
              Icons.done_rounded,
              size: 25,
              color: isDark ? AppColors.iconDark : AppColors.iconLight,
            ),
            tooltip: 'Salva',
            onPressed: _updateMatch,
          ),
        ],
      ),
      body: allTeams.isEmpty || allLeagues.isEmpty
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              physics: const AlwaysScrollableScrollPhysics(),
              child: Column(
                children: [
                  if (selectedLeague != null)
                    SizedBox(
                      height: 60,
                      child: SingleChildScrollView(
                        scrollDirection: Axis.horizontal,
                        child: Align(
                          alignment: Alignment.centerLeft,
                          child: Text(
                            '${selectedLeague!.name} - ${selectedLeague!.year}',
                            style: TextStyle(
                              fontSize: 16,
                              color: isDark
                                  ? AppColors.textDarkPrimary
                                  : AppColors.textLightPrimary,
                            ),
                          ),
                        ),
                      ),
                    ),
                  const SizedBox(height: 16),
                  TeamsDropdownSection(
                    homeTeam: homeTeam,
                    awayTeam: awayTeam,
                    filteredTeams: filteredTeams,
                    onHomeChanged: (t) => setState(() => homeTeam = t),
                    onAwayChanged: (t) => setState(() => awayTeam = t),
                  ),
                  const SizedBox(height: 16),
                  MatchFormSection(
                    formKey: formKey,
                    selectedDate: selectedDate,
                    onDatePicked: (d) => setState(() => selectedDate = d),
                    matchDayController: matchDayController,
                    match: widget.match,
                    showDeleteButton: true,
                  ),
                ],
              ),
            ),
    );
  }
}
