import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:real_amis/common/widgets/appBar/app_bar_yes_nav.dart';
import 'package:real_amis/common/widgets/loader/loader.dart';
import 'package:real_amis/common/widgets/textFields/text_field_required.dart';
import 'package:real_amis/domain/entities/team/team_entity.dart';
import 'package:real_amis/presentation/league/providers/league_notifier.dart';
import 'package:real_amis/presentation/league/widgets/teams_checkbox_selector.dart';
import 'package:real_amis/presentation/team/providers/team_notifier.dart';

class AddNewLeaguePage extends ConsumerStatefulWidget {
  static MaterialPageRoute route() =>
      MaterialPageRoute(builder: (_) => const AddNewLeaguePage());

  const AddNewLeaguePage({super.key});

  @override
  ConsumerState<AddNewLeaguePage> createState() => _AddNewLeaguePageState();
}

class _AddNewLeaguePageState extends ConsumerState<AddNewLeaguePage> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _yearController = TextEditingController();

  List<TeamEntity> selectedTeams = [];

  @override
  void initState() {
    super.initState();
    ref.read(teamNotifierProvider.notifier).fetchAllTeams();
  }

  @override
  void dispose() {
    _nameController.dispose();
    _yearController.dispose();
    super.dispose();
  }

  Future<void> _uploadLeague() async {
    if (!_formKey.currentState!.validate()) return;

    try {
      await ref
          .read(leagueNotifierProvider.notifier)
          .uploadLeague(
            name: _nameController.text.trim(),
            year: _yearController.text.trim(),
            teamIds: selectedTeams.map((t) => t.id).toList(),
          );
      if (!mounted) return;
      Navigator.pop(context, 'created');
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Errore creazione campionato: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final teamState = ref.watch(teamNotifierProvider);

    return Scaffold(
      appBar: AppBarYesNav(
        title: const Text('Aggiungi un campionato'),
        actions: [
          IconButton(
            icon: const Icon(Icons.done_rounded),
            tooltip: 'Salva',
            onPressed: _uploadLeague,
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
                    hintText: 'Ad es. SuperLeague',
                  ),
                  const SizedBox(height: 16),
                  TextFieldRequired(
                    controller: _yearController,
                    labelText: 'Anno',
                    hintText: 'Ad es. 2025/2026',
                    keyboardType: TextInputType.number,
                  ),
                  const SizedBox(height: 24),
                  teamState.when(
                    data: (teams) {
                      return TeamsCheckboxSelector(
                        allTeams: teams,
                        selectedTeams: selectedTeams,
                        onChanged: (updated) {
                          setState(() => selectedTeams = updated);
                        },
                      );
                    },
                    loading: () => const Loader(),
                    error: (e, _) => Text('Errore caricamento team: $e'),
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
