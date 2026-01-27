import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:real_amis/common/widgets/appBar/app_bar_yes_nav.dart';
import 'package:real_amis/common/widgets/button/basic_app_button.dart';
import 'package:real_amis/common/widgets/loader/loader.dart';
import 'package:real_amis/common/widgets/textFields/text_field_required.dart';
import 'package:real_amis/core/configs/theme/app_colors.dart';
import 'package:real_amis/domain/entities/league/league_entity.dart';
import 'package:real_amis/domain/entities/team/team_entity.dart';
import 'package:real_amis/presentation/league/bloc/league_bloc.dart';
import 'package:real_amis/presentation/league/widgets/teams_checkbox_selector.dart';
import 'package:real_amis/presentation/team/bloc/team_bloc.dart';

class EditLeaguePage extends StatefulWidget {
  final LeagueEntity league;
  const EditLeaguePage({super.key, required this.league});

  static MaterialPageRoute route(LeagueEntity league) =>
      MaterialPageRoute(builder: (_) => EditLeaguePage(league: league));

  @override
  State<EditLeaguePage> createState() => _EditLeaguePageState();
}

class _EditLeaguePageState extends State<EditLeaguePage> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nameController;
  late TextEditingController _yearController;

  List<TeamEntity> allTeams = [];
  List<TeamEntity> selectedTeams = [];

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.league.name);
    _yearController = TextEditingController(text: widget.league.year);
    context.read<TeamBloc>().add(TeamFetchAllTeams());
  }

  @override
  void dispose() {
    _nameController.dispose();
    _yearController.dispose();
    super.dispose();
  }

  void _updateLeague() {
    if (_formKey.currentState!.validate()) {
      context.read<LeagueBloc>().add(
        LeagueUpdate(
          league: widget.league,
          name: _nameController.text.trim(),
          year: _yearController.text.trim(),
          teamIds: selectedTeams.map((t) => t.id).toList(),
        ),
      );
    }
  }

  void _deleteLeague() async {
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

    if (confirmed == true && mounted) {
      context.read<LeagueBloc>().add(LeagueDelete(leagueId: widget.league.id));
    }
  }

  @override
  Widget build(BuildContext context) {
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
      body: BlocListener<LeagueBloc, LeagueState>(
        listener: (context, state) {
          if (state is LeagueUpdateSuccess) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Campionato aggiornato!')),
            );
            Navigator.pop(context, true); // torna alla pagina precedente
          } else if (state is LeagueFailure) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('Errore aggiornamento: ${state.error}')),
            );
          }
        },
        child: SingleChildScrollView(
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
                    BlocBuilder<TeamBloc, TeamState>(
                      builder: (context, state) {
                        if (state is TeamLoading) return const Loader();
                        if (state is TeamFailure) {
                          return Text(
                            'Errore caricamento team: ${state.error}',
                          );
                        }
                        if (state is TeamDisplaySuccess) {
                          if (allTeams.isEmpty) {
                            allTeams = state.teams;
                            selectedTeams = allTeams
                                .where(
                                  (t) => widget.league.teamIds.contains(t.id),
                                )
                                .toList();
                          }

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
      ),
    );
  }
}
