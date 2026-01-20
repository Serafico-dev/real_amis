import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:real_amis/common/helpers/is_dark_mode.dart';
import 'package:real_amis/common/widgets/appBar/app_bar_yes_nav.dart';
import 'package:real_amis/core/configs/theme/app_colors.dart';
import 'package:real_amis/domain/entities/team/team_entity.dart';
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

  final matchDayController = TextEditingController();
  final homeTeamScoreController = TextEditingController();
  final awayTeamScoreController = TextEditingController();
  final formKey = GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();
    context.read<TeamBloc>().add(TeamFetchAllTeams());
  }

  @override
  void dispose() {
    matchDayController.dispose();
    homeTeamScoreController.dispose();
    awayTeamScoreController.dispose();
    super.dispose();
  }

  void _uploadMatch() {
    if (formKey.currentState!.validate() &&
        selectedDate != null &&
        homeTeam != null &&
        awayTeam != null) {
      context.read<MatchBloc>().add(
        MatchUpload(
          matchDate: selectedDate!,
          homeTeamId: homeTeam!.id,
          awayTeamId: awayTeam!.id,
          homeTeamScore: int.tryParse(homeTeamScoreController.text.trim()) ?? 0,
          awayTeamScore: int.tryParse(awayTeamScoreController.text.trim()) ?? 0,
          matchDay: matchDayController.text.toUpperCase().trim(),
        ),
      );
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
              color: isDark ? AppColors.iconDark : AppColors.iconPrimary,
              size: 25,
            ),
            onPressed: _uploadMatch,
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
