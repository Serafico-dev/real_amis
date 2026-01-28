import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:real_amis/common/helpers/is_dark_mode.dart';
import 'package:real_amis/common/widgets/appBar/app_bar_yes_nav.dart';
import 'package:real_amis/core/configs/theme/app_colors.dart';
import 'package:real_amis/domain/entities/league/league_entity.dart';
import 'package:real_amis/domain/entities/match/match_entity.dart';
import 'package:real_amis/domain/entities/team/team_entity.dart';
import 'package:real_amis/presentation/league/bloc/league_bloc.dart';
import 'package:real_amis/presentation/match/bloc/match_bloc.dart';
import 'package:real_amis/presentation/match/widgets/match_form_section.dart';
import 'package:real_amis/presentation/match/widgets/teams_dropdown_section.dart';
import 'package:real_amis/presentation/team/bloc/team_bloc.dart';

class EditMatchPage extends StatefulWidget {
  static MaterialPageRoute route(MatchEntity match) =>
      MaterialPageRoute(builder: (_) => EditMatchPage(match: match));

  final MatchEntity match;
  const EditMatchPage({super.key, required this.match});

  @override
  State<EditMatchPage> createState() => _EditMatchPageState();
}

class _EditMatchPageState extends State<EditMatchPage> {
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
    context.read<TeamBloc>().add(TeamFetchAllTeams());
    context.read<LeagueBloc>().add(LeagueFetchAllLeagues());

    selectedDate = widget.match.matchDate;
    homeTeam = widget.match.homeTeam;
    awayTeam = widget.match.awayTeam;

    matchDayController.text = widget.match.matchDay ?? '';
  }

  @override
  void dispose() {
    matchDayController.dispose();
    super.dispose();
  }

  void _updateMatch() {
    if (!formKey.currentState!.validate()) return;

    context.read<MatchBloc>().add(
      MatchUpdate(
        match: widget.match,
        matchDate: selectedDate ?? widget.match.matchDate,
        homeTeamId: homeTeam?.id ?? widget.match.homeTeamId,
        awayTeamId: awayTeam?.id ?? widget.match.awayTeamId,
        matchDay: matchDayController.text.trim().isNotEmpty
            ? matchDayController.text.toUpperCase().trim()
            : widget.match.matchDay,
        leagueId: selectedLeague!.id,
      ),
    );
  }

  void _updateFilteredTeams() {
    final allTeamsState = context.read<TeamBloc>().state;
    if (allTeamsState is TeamDisplaySuccess && selectedLeague != null) {
      filteredTeams =
          allTeamsState.teams
              .where((t) => selectedLeague!.teamIds.contains(t.id))
              .toList()
            ..sort(
              (a, b) => a.name.toLowerCase().compareTo(b.name.toLowerCase()),
            );

      if (!filteredTeams.contains(homeTeam)) homeTeam = null;
      if (!filteredTeams.contains(awayTeam)) awayTeam = null;
    } else {
      filteredTeams = [];
      homeTeam = null;
      awayTeam = null;
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = context.isDarkMode;

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
      body: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            BlocBuilder<LeagueBloc, LeagueState>(
              builder: (context, state) {
                if (state is LeagueDisplaySuccess) {
                  final league = state.leagues.firstWhere(
                    (l) => l.id == widget.match.leagueId,
                  );
                  selectedLeague ??= league;

                  return SizedBox(
                    height: 60,
                    child: SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: Align(
                        alignment: Alignment.centerLeft,
                        child: Text(
                          '${league.name} - ${league.year}',
                          style: TextStyle(
                            fontSize: 16,
                            color: isDark
                                ? AppColors.textDarkPrimary
                                : AppColors.textLightPrimary,
                          ),
                        ),
                      ),
                    ),
                  );
                } else if (state is LeagueFailure) {
                  return Text(
                    'Errore nel caricamento dei campionati',
                    style: TextStyle(color: AppColors.logoRed),
                  );
                } else {
                  return const Center(child: CircularProgressIndicator());
                }
              },
            ),

            const SizedBox(height: 16),

            BlocListener<TeamBloc, TeamState>(
              listener: (context, state) {
                if (state is TeamDisplaySuccess && selectedLeague != null) {
                  setState(_updateFilteredTeams);
                }
              },
              child: TeamsDropdownSection(
                homeTeam: homeTeam,
                awayTeam: awayTeam,
                filteredTeams: filteredTeams,
                onHomeChanged: (t) => setState(() => homeTeam = t),
                onAwayChanged: (t) => setState(() => awayTeam = t),
              ),
            ),

            const SizedBox(height: 16),

            MatchFormSection(
              formKey: formKey,
              selectedDate: selectedDate,
              onDatePicked: (d) => setState(() => selectedDate = d),
              matchDayController: matchDayController,
              showDeleteButton: true,
            ),
          ],
        ),
      ),
    );
  }
}
