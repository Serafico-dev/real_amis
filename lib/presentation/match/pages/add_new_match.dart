import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:real_amis/common/helpers/is_dark_mode.dart';
import 'package:real_amis/common/widgets/appBar/app_bar_yes_nav.dart';
import 'package:real_amis/core/configs/theme/app_colors.dart';
import 'package:real_amis/core/utils/show_snackbar.dart';
import 'package:real_amis/domain/entities/league/league_entity.dart';
import 'package:real_amis/domain/entities/team/team_entity.dart';
import 'package:real_amis/presentation/league/bloc/league_bloc.dart';
import 'package:real_amis/presentation/match/bloc/match_bloc.dart';
import 'package:real_amis/presentation/match/widgets/match_form_section.dart';
import 'package:real_amis/presentation/match/widgets/teams_dropdown_section.dart';
import 'package:real_amis/presentation/team/bloc/team_bloc.dart';

class AddNewMatchPage extends StatefulWidget {
  static MaterialPageRoute route() =>
      MaterialPageRoute(builder: (_) => const AddNewMatchPage());

  const AddNewMatchPage({super.key});

  @override
  State<AddNewMatchPage> createState() => _AddNewMatchPageState();
}

class _AddNewMatchPageState extends State<AddNewMatchPage> {
  DateTime? selectedDate;
  TeamEntity? homeTeam;
  TeamEntity? awayTeam;
  LeagueEntity? selectedLeague;

  final matchDayController = TextEditingController();
  final homeTeamScoreController = TextEditingController();
  final awayTeamScoreController = TextEditingController();
  final formKey = GlobalKey<FormState>();

  List<TeamEntity> filteredTeams = [];

  @override
  void initState() {
    super.initState();
    context.read<TeamBloc>().add(TeamFetchAllTeams());
    context.read<LeagueBloc>().add(LeagueFetchAllLeagues());
  }

  @override
  void dispose() {
    matchDayController.dispose();
    homeTeamScoreController.dispose();
    awayTeamScoreController.dispose();
    super.dispose();
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

  void _uploadMatch() {
    if (formKey.currentState!.validate() &&
        selectedDate != null &&
        homeTeam != null &&
        awayTeam != null &&
        selectedLeague != null) {
      context.read<MatchBloc>().add(
        MatchUpload(
          matchDate: selectedDate!,
          homeTeamId: homeTeam!.id,
          awayTeamId: awayTeam!.id,
          homeTeamScore: int.tryParse(homeTeamScoreController.text.trim()) ?? 0,
          awayTeamScore: int.tryParse(awayTeamScoreController.text.trim()) ?? 0,
          matchDay: matchDayController.text.toUpperCase().trim(),
          leagueId: selectedLeague!.id,
        ),
      );
    } else if (selectedLeague == null) {
      showSnackBar(context, 'Seleziona un campionato!');
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = context.isDarkMode;

    return Scaffold(
      appBar: AppBarYesNav(
        title: const Text('Aggiungi una partita'),
        actions: [
          IconButton(
            icon: Icon(
              Icons.done_rounded,
              color: isDark ? AppColors.iconDark : AppColors.iconLight,
              size: 25,
            ),
            tooltip: 'Salva',
            onPressed: _uploadMatch,
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
                  final leaguesList = List<LeagueEntity>.from(state.leagues)
                    ..sort((a, b) => b.year.compareTo(a.year));

                  return DropdownButtonFormField<LeagueEntity>(
                    decoration: const InputDecoration(
                      labelText: 'Campionato',
                      border: OutlineInputBorder(),
                      floatingLabelBehavior: FloatingLabelBehavior.always,
                    ),
                    isExpanded: true,
                    items: leaguesList
                        .map(
                          (league) => DropdownMenuItem(
                            value: league,
                            child: Text('${league.name} - ${league.year}'),
                          ),
                        )
                        .toList(),
                    initialValue: selectedLeague,
                    onChanged: (league) {
                      setState(() {
                        selectedLeague = league;
                        _updateFilteredTeams();
                      });
                    },
                    validator: (value) =>
                        value == null ? 'Seleziona un campionato' : null,
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
              homeTeamScoreController: homeTeamScoreController,
              awayTeamScoreController: awayTeamScoreController,
            ),
          ],
        ),
      ),
    );
  }
}
