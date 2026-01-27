import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:real_amis/common/widgets/appBar/app_bar_yes_nav.dart';
import 'package:real_amis/common/widgets/loader/loader.dart';
import 'package:real_amis/common/widgets/textFields/text_field_required.dart';
import 'package:real_amis/domain/entities/team/team_entity.dart';
import 'package:real_amis/presentation/league/bloc/league_bloc.dart';
import 'package:real_amis/presentation/league/widgets/teams_checkbox_selector.dart';
import 'package:real_amis/presentation/team/bloc/team_bloc.dart';

class AddNewLeaguePage extends StatefulWidget {
  static MaterialPageRoute route() =>
      MaterialPageRoute(builder: (_) => const AddNewLeaguePage());

  const AddNewLeaguePage({super.key});

  @override
  State<AddNewLeaguePage> createState() => _AddNewLeaguePageState();
}

class _AddNewLeaguePageState extends State<AddNewLeaguePage> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _yearController = TextEditingController();

  List<TeamEntity> allTeams = [];
  List<TeamEntity> selectedTeams = [];

  @override
  void initState() {
    super.initState();
    context.read<TeamBloc>().add(TeamFetchAllTeams());
  }

  @override
  void dispose() {
    _nameController.dispose();
    _yearController.dispose();
    super.dispose();
  }

  void _uploadLeague() {
    if (_formKey.currentState!.validate()) {
      context.read<LeagueBloc>().add(
        LeagueUpload(
          name: _nameController.text.trim(),
          year: _yearController.text.trim(),
          teamIds: selectedTeams.map((t) => t.id).toList(),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
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
                  BlocBuilder<TeamBloc, TeamState>(
                    builder: (context, state) {
                      if (state is TeamLoading) return const Loader();
                      if (state is TeamFailure) {
                        return Text('Errore caricamento team: ${state.error}');
                      }
                      if (state is TeamDisplaySuccess) {
                        allTeams = state.teams;
                        return TeamsCheckboxSelector(
                          allTeams: allTeams,
                          selectedTeams: selectedTeams,
                          onChanged: (updated) {
                            setState(() {
                              selectedTeams = updated;
                            });
                          },
                        );
                      }
                      return const SizedBox.shrink();
                    },
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
