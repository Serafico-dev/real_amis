import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:real_amis/common/helpers/is_dark_mode.dart';
import 'package:real_amis/common/widgets/appBar/app_bar_yes_nav.dart';
import 'package:real_amis/core/configs/theme/app_colors.dart';
import 'package:real_amis/core/utils/show_snackbar.dart';
import 'package:real_amis/domain/entities/league/league_entity.dart';
import 'package:real_amis/domain/entities/player/player_entity.dart';
import 'package:real_amis/domain/entities/player/player_role.dart';
import 'package:real_amis/domain/entities/team/team_entity.dart';
import 'package:real_amis/domain/usecases/match/upload_match.dart';
import 'package:real_amis/presentation/match/widgets/match_form_section.dart';
import 'package:real_amis/presentation/match/widgets/teams_dropdown_section.dart';
import 'package:real_amis/presentation/player/providers/player_notifier.dart';
import 'package:real_amis/presentation/team/providers/team_notifier.dart';
import 'package:real_amis/presentation/league/providers/league_notifier.dart';
import 'package:real_amis/presentation/match/providers/match_notifier.dart';

class AddNewMatchPage extends ConsumerStatefulWidget {
  final LeagueEntity? selectedLeague;

  static MaterialPageRoute route({LeagueEntity? selectedLeague}) =>
      MaterialPageRoute(
        builder: (_) => AddNewMatchPage(selectedLeague: selectedLeague),
      );

  const AddNewMatchPage({super.key, this.selectedLeague});

  @override
  ConsumerState<AddNewMatchPage> createState() => _AddNewMatchPageState();
}

class _AddNewMatchPageState extends ConsumerState<AddNewMatchPage> {
  DateTime? selectedDate;
  TeamEntity? homeTeam;
  TeamEntity? awayTeam;
  LeagueEntity? selectedLeague;
  final Set<String> _calledUpIds = {};

  final matchDayController = TextEditingController();
  final formKey = GlobalKey<FormState>();
  List<TeamEntity> filteredTeams = [];

  @override
  void initState() {
    super.initState();
    selectedLeague = widget.selectedLeague;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(teamNotifierProvider.notifier).fetchAllTeams();
      ref.read(leagueNotifierProvider.notifier).fetchAllLeagues();
      ref.read(playerNotifierProvider.notifier).fetchAllPlayers();
    });
  }

  @override
  void dispose() {
    matchDayController.dispose();
    super.dispose();
  }

  void _updateFilteredTeams(List<TeamEntity> allTeams, [LeagueEntity? league]) {
    if (league != null) {
      filteredTeams =
          allTeams.where((t) => league.teamIds.contains(t.id)).toList()..sort(
            (a, b) => a.name.toLowerCase().compareTo(b.name.toLowerCase()),
          );

      if (homeTeam != null && !filteredTeams.contains(homeTeam)) {
        filteredTeams.insert(0, homeTeam!);
      }
      if (awayTeam != null && !filteredTeams.contains(awayTeam)) {
        filteredTeams.insert(0, awayTeam!);
      }
    } else {
      filteredTeams = List<TeamEntity>.from(allTeams)
        ..sort((a, b) => a.name.toLowerCase().compareTo(b.name.toLowerCase()));
    }
  }

  Future<void> _uploadMatch() async {
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

    try {
      await ref
          .read(matchNotifierProvider.notifier)
          .uploadMatch(
            UploadMatchParams(
              matchDate: selectedDate!,
              homeTeamId: homeTeam!.id,
              awayTeamId: awayTeam!.id,
              matchDay: matchDayController.text.toUpperCase().trim(),
              leagueId: selectedLeague!.id,
              calledUpIds: _calledUpIds.toList(),
            ),
          );
      if (mounted) {
        showSnackBar(context, 'Partita aggiunta con successo');
        Navigator.of(context).pop();
      }
    } catch (e) {
      if (mounted) showSnackBar(context, 'Errore: $e');
    }
  }

  Widget _buildCalledUpSection(List<PlayerEntity> allPlayers, bool isDark) {
    final activePlayers = allPlayers.where((p) => p.active).toList()
      ..sort((a, b) => a.fullName.compareTo(b.fullName));

    if (activePlayers.isEmpty) return const SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 8),
        Text(
          'Convocati (${_calledUpIds.length})',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 16,
            color: isDark
                ? AppColors.textDarkPrimary
                : AppColors.textLightPrimary,
          ),
        ),
        const SizedBox(height: 4),
        ...activePlayers.map(
          (player) => CheckboxListTile(
            dense: true,
            contentPadding: EdgeInsets.zero,
            title: Text(
              player.fullName,
              style: TextStyle(
                color: isDark
                    ? AppColors.textDarkPrimary
                    : AppColors.textLightPrimary,
              ),
            ),
            subtitle: Text(
              player.role.value,
              style: TextStyle(
                fontSize: 12,
                color: isDark
                    ? AppColors.textDarkSecondary
                    : AppColors.textLightSecondary,
              ),
            ),
            value: _calledUpIds.contains(player.id),
            activeColor: isDark ? AppColors.tertiary : AppColors.primary,
            onChanged: (checked) => setState(() {
              if (checked == true) {
                _calledUpIds.add(player.id);
              } else {
                _calledUpIds.remove(player.id);
              }
            }),
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = context.isDarkMode;
    final allTeams = ref.watch(teamNotifierProvider).value ?? [];
    final allPlayers = ref.watch(playerNotifierProvider).value ?? [];
    _updateFilteredTeams(allTeams);

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
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(
              height: 60,
              child: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    selectedLeague != null
                        ? '${selectedLeague!.name} - ${selectedLeague!.year}'
                        : 'Seleziona un campionato',
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
            ),
            const Divider(height: 32),
            _buildCalledUpSection(allPlayers, isDark),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }
}
