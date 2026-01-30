import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:real_amis/common/widgets/appBar/app_bar_yes_nav.dart';
import 'package:real_amis/common/widgets/button/basic_app_button.dart';
import 'package:real_amis/common/widgets/loader/loader.dart';
import 'package:real_amis/common/widgets/textFields/text_field_required.dart';
import 'package:real_amis/core/configs/theme/app_colors.dart';
import 'package:real_amis/domain/entities/league/league_entity.dart';
import 'package:real_amis/domain/entities/team/team_entity.dart';
import 'package:real_amis/presentation/league/providers/league_notifier.dart';
import 'package:real_amis/presentation/league/widgets/teams_checkbox_selector.dart';
import 'package:real_amis/presentation/team/providers/team_notifier.dart';

class EditLeaguePage extends ConsumerStatefulWidget {
  final LeagueEntity league;
  const EditLeaguePage({super.key, required this.league});

  static MaterialPageRoute route(LeagueEntity league) =>
      MaterialPageRoute(builder: (_) => EditLeaguePage(league: league));

  @override
  ConsumerState<EditLeaguePage> createState() => _EditLeaguePageState();
}

class _EditLeaguePageState extends ConsumerState<EditLeaguePage> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nameController;
  late TextEditingController _yearController;

  List<TeamEntity> allTeams = [];
  List<TeamEntity> selectedTeams = [];

  bool _teamsInitialized = false;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.league.name);
    _yearController = TextEditingController(text: widget.league.year);

    final teamState = ref.read(teamNotifierProvider);
    teamState.when(
      data: (teams) {
        allTeams = teams;
        selectedTeams = allTeams
            .where((t) => widget.league.teamIds.contains(t.id))
            .toList();
        _teamsInitialized = true;
      },
      loading: () => ref.read(teamNotifierProvider.notifier).fetchAllTeams(),
      error: (err, _) => Text('Errore caricamento team: $err'),
    );
  }

  @override
  void dispose() {
    _nameController.dispose();
    _yearController.dispose();
    super.dispose();
  }

  Future<void> _updateLeague() async {
    if (!_formKey.currentState!.validate()) return;

    try {
      await ref
          .read(leagueNotifierProvider.notifier)
          .updateLeague(
            league: widget.league,
            name: _nameController.text.trim(),
            year: _yearController.text.trim(),
            teamIds: selectedTeams.map((t) => t.id).toList(),
          );

      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Campionato aggiornato!')));
      Navigator.pop(context, true);
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Errore aggiornamento: $e')));
    }
  }

  Future<void> _deleteLeague() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Conferma eliminazione'),
        content: const Text('Sei sicuro di voler eliminare questo campionato?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Annulla'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text(
              'Elimina',
              style: TextStyle(color: AppColors.logoRed),
            ),
          ),
        ],
      ),
    );

    if (confirmed != true) return;

    try {
      await ref
          .read(leagueNotifierProvider.notifier)
          .deleteLeague(widget.league.id);
      if (!mounted) return;
      Navigator.pop(context, true);
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Errore eliminazione: $e')));
    }
  }

  @override
  Widget build(BuildContext context) {
    final teamState = ref.watch(teamNotifierProvider);

    return Scaffold(
      appBar: AppBarYesNav(
        title: const Text('Modifica campionato'),
        actions: [
          IconButton(
            icon: const Icon(Icons.done_rounded),
            tooltip: 'Salva',
            onPressed: _updateLeague,
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Form(
              key: _formKey,
              child: Column(
                children: [
                  TextFieldRequired(
                    controller: _nameController,
                    labelText: 'Nome campionato',
                    hintText: widget.league.name,
                  ),
                  const SizedBox(height: 16),
                  TextFieldRequired(
                    controller: _yearController,
                    labelText: 'Anno',
                    hintText: widget.league.year,
                    keyboardType: TextInputType.number,
                  ),
                  const SizedBox(height: 24),
                  teamState.when(
                    data: (teams) {
                      if (!_teamsInitialized) {
                        allTeams = teams;
                        selectedTeams = allTeams
                            .where((t) => widget.league.teamIds.contains(t.id))
                            .toList();
                        _teamsInitialized = true;
                      }
                      return TeamsCheckboxSelector(
                        allTeams: allTeams,
                        selectedTeams: selectedTeams,
                        onChanged: (updated) =>
                            setState(() => selectedTeams = updated),
                      );
                    },
                    loading: () => const Loader(),
                    error: (err, _) => Text('Errore caricamento team: $err'),
                  ),
                  const SizedBox(height: 24),
                  BasicAppButton(
                    title: 'Elimina campionato',
                    onPressed: _deleteLeague,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
