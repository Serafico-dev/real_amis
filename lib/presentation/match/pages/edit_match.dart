import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:real_amis/common/helpers/is_dark_mode.dart';
import 'package:real_amis/common/widgets/appBar/app_bar_yes_nav.dart';
import 'package:real_amis/core/configs/theme/app_colors.dart';
import 'package:real_amis/domain/entities/league/league_entity.dart';
import 'package:real_amis/domain/entities/match/match_entity.dart';
import 'package:real_amis/domain/entities/team/team_entity.dart';
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
  final homeTeamScoreController = TextEditingController();
  final awayTeamScoreController = TextEditingController();
  final formKey = GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();
    context.read<TeamBloc>().add(TeamFetchAllTeams());

    selectedDate = widget.match.matchDate;
    selectedLeague = widget.match.league;
    matchDayController.text = widget.match.matchDay ?? '';
    homeTeamScoreController.text = (widget.match.homeTeamScore ?? 0).toString();
    awayTeamScoreController.text = (widget.match.awayTeamScore ?? 0).toString();
  }

  @override
  void dispose() {
    matchDayController.dispose();
    homeTeamScoreController.dispose();
    awayTeamScoreController.dispose();
    super.dispose();
  }

  void _updateMatch() {
    if (selectedLeague == null) return;

    context.read<MatchBloc>().add(
      MatchUpdate(
        match: widget.match,
        matchDate: selectedDate ?? widget.match.matchDate,
        homeTeamId: homeTeam?.id ?? widget.match.homeTeamId,
        awayTeamId: awayTeam?.id ?? widget.match.awayTeamId,
        homeTeamScore:
            int.tryParse(homeTeamScoreController.text.trim()) ??
            widget.match.homeTeamScore,
        awayTeamScore:
            int.tryParse(awayTeamScoreController.text.trim()) ??
            widget.match.awayTeamScore,
        matchDay: matchDayController.text.trim().isNotEmpty
            ? matchDayController.text.toUpperCase().trim()
            : widget.match.matchDay,
        leagueId: selectedLeague!.id,
      ),
    );
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
            TeamsDropdownSection(
              homeTeam: homeTeam,
              awayTeam: awayTeam,
              onHomeChanged: (t) => setState(() => homeTeam = t),
              onAwayChanged: (t) => setState(() => awayTeam = t),
              hintHome: 'Squadra in Casa (${widget.match.homeTeam?.name})',
              hintAway: 'Squadra Ospite (${widget.match.awayTeam?.name})',
            ),
            const SizedBox(height: 16),

            MatchFormSection(
              formKey: formKey,
              selectedDate: selectedDate,
              onDatePicked: (d) => setState(() => selectedDate = d),
              matchDayController: matchDayController,
              homeTeamScoreController: homeTeamScoreController,
              awayTeamScoreController: awayTeamScoreController,
              match: widget.match,
              selectedLeague: selectedLeague,
              onLeagueSelected: (league) =>
                  setState(() => selectedLeague = league),
              showDeleteButton: true,
            ),
          ],
        ),
      ),
    );
  }
}
