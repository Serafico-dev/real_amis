import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:real_amis/common/helpers/is_dark_mode.dart';
import 'package:real_amis/common/widgets/appBar/app_bar_yes_nav.dart';
import 'package:real_amis/core/configs/theme/app_colors.dart';
import 'package:real_amis/domain/entities/team/team_entity.dart';
import 'package:real_amis/presentation/league/bloc/league_bloc.dart';
import 'package:real_amis/presentation/league/widgets/league_form_section.dart';
import 'package:real_amis/presentation/team/bloc/team_bloc.dart';

class AddNewLeaguePage extends StatefulWidget {
  static MaterialPageRoute route() =>
      MaterialPageRoute(builder: (_) => const AddNewLeaguePage());

  const AddNewLeaguePage({super.key});

  @override
  State<AddNewLeaguePage> createState() => _AddNewLeaguePageState();
}

class _AddNewLeaguePageState extends State<AddNewLeaguePage> {
  final formKey = GlobalKey<FormState>();
  final nameController = TextEditingController();
  final yearController = TextEditingController();

  List<TeamEntity> allTeams = [];
  List<TeamEntity> selectedTeams = [];

  @override
  void initState() {
    super.initState();
    // Dispara l'evento per caricare tutti i team
    context.read<TeamBloc>().add(TeamFetchAllTeams());
  }

  @override
  void dispose() {
    nameController.dispose();
    yearController.dispose();
    super.dispose();
  }

  void _uploadLeague() {
    if (formKey.currentState!.validate()) {
      context.read<LeagueBloc>().add(
        LeagueUpload(
          name: nameController.text.trim(),
          year: yearController.text.trim(),
          teamIds: selectedTeams.map((t) => t.id).toList(),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = context.isDarkMode;

    return Scaffold(
      appBar: AppBarYesNav(
        title: const Text('Aggiungi un campionato'),
        actions: [
          IconButton(
            icon: Icon(
              Icons.done_rounded,
              color: isDark ? AppColors.iconDark : AppColors.iconLight,
              size: 25,
            ),
            tooltip: 'Salva',
            onPressed: _uploadLeague,
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            LeagueFormSection(
              formKey: formKey,
              nameController: nameController,
              yearController: yearController,
            ),
            const SizedBox(height: 16),
            BlocBuilder<TeamBloc, TeamState>(
              builder: (context, state) {
                if (state is TeamLoading) {
                  return const Center(child: CircularProgressIndicator());
                }
                if (state is TeamDisplaySuccess) {
                  allTeams = state.teams;
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
          ],
        ),
      ),
    );
  }

  Widget _buildTeamsSelector() {
    if (allTeams.isEmpty) {
      return const SizedBox.shrink();
    }

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
