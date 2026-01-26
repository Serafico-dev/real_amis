import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:real_amis/common/helpers/is_dark_mode.dart';
import 'package:real_amis/common/widgets/appBar/app_bar_yes_nav.dart';
import 'package:real_amis/common/widgets/button/basic_app_button.dart';
import 'package:real_amis/core/configs/theme/app_colors.dart';
import 'package:real_amis/domain/entities/league/league_entity.dart';
import 'package:real_amis/domain/entities/team/team_entity.dart';
import 'package:real_amis/presentation/league/bloc/league_bloc.dart';
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
    final isDark = context.isDarkMode;
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Conferma eliminazione'),
        content: const Text('Sei sicuro di voler eliminare questo campionato?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text(
              'Annulla',
              style: TextStyle(color: isDark ? Colors.white70 : Colors.black54),
            ),
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
    final isDark = context.isDarkMode;

    return Scaffold(
      appBar: AppBarYesNav(
        title: const Text('Modifica campionato'),
        actions: [
          IconButton(
            icon: Icon(
              Icons.done_rounded,
              color: isDark ? AppColors.iconDark : AppColors.iconLight,
            ),
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
                  TextFormField(
                    controller: _nameController,
                    decoration: const InputDecoration(labelText: 'Nome'),
                    validator: (v) => v == null || v.trim().isEmpty
                        ? 'Inserisci un nome'
                        : null,
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _yearController,
                    decoration: const InputDecoration(labelText: 'Anno'),
                    keyboardType: TextInputType.number,
                    validator: (v) => v == null || v.trim().isEmpty
                        ? 'Inserisci un anno'
                        : null,
                  ),
                  const SizedBox(height: 24),
                  BlocBuilder<TeamBloc, TeamState>(
                    builder: (context, state) {
                      if (state is TeamLoading) {
                        return const CircularProgressIndicator();
                      }
                      if (state is TeamDisplaySuccess) {
                        allTeams = state.teams;
                        selectedTeams = allTeams
                            .where((t) => widget.league.teamIds.contains(t.id))
                            .toList();
                        return _buildTeamsSelector();
                      }
                      if (state is TeamFailure) {
                        return Text(
                          'Errore nel caricamento dei team: ${state.error}',
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
    );
  }

  Widget _buildTeamsSelector() {
    if (allTeams.isEmpty) return const SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Seleziona le squadre',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 8),
        ...allTeams.map((team) {
          final selected = selectedTeams.contains(team);
          return CheckboxListTile(
            title: Text(team.name),
            value: selected,
            onChanged: (value) {
              setState(() {
                if (value == true) {
                  selectedTeams.add(team);
                } else {
                  selectedTeams.remove(team);
                }
              });
            },
          );
        }),
      ],
    );
  }
}
