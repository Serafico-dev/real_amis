import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:real_amis/common/widgets/appBar/app_bar_yes_nav.dart';
import 'package:real_amis/core/configs/theme/app_colors.dart';
import 'package:real_amis/domain/entities/league/league_entity.dart';
import 'package:real_amis/presentation/league/bloc/league_bloc.dart';
import 'package:real_amis/presentation/league/pages/add_new_league.dart';
import 'package:real_amis/presentation/league/pages/edit_league.dart';

class LeaguesPage extends StatefulWidget {
  const LeaguesPage({super.key});

  static MaterialPageRoute route() =>
      MaterialPageRoute(builder: (_) => const LeaguesPage());

  @override
  State<LeaguesPage> createState() => _LeaguesPageState();
}

class _LeaguesPageState extends State<LeaguesPage> {
  @override
  void initState() {
    super.initState();
    _fetchLeagues();
  }

  void _fetchLeagues() {
    context.read<LeagueBloc>().add(LeagueFetchAllLeagues());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBarYesNav(
        title: const Text('Gestisci campionati'),
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () async {
              await Navigator.push(context, AddNewLeaguePage.route());
              if (mounted) _fetchLeagues();
            },
          ),
        ],
      ),
      body: BlocBuilder<LeagueBloc, LeagueState>(
        builder: (context, state) {
          if (state is LeagueDisplaySuccess) {
            final leagues = List<LeagueEntity>.from(state.leagues)
              ..sort((a, b) => b.year.compareTo(a.year));

            if (leagues.isEmpty) {
              return const Center(child: Text('Nessun campionato disponibile'));
            }

            return ListView.separated(
              padding: const EdgeInsets.all(16),
              itemCount: leagues.length,
              separatorBuilder: (_, _) => const SizedBox(height: 8),
              itemBuilder: (context, index) {
                final league = leagues[index];
                return Card(
                  child: ListTile(
                    title: Text('${league.name} - ${league.year}'),
                    trailing: const Icon(Icons.edit),
                    onTap: () async {
                      await Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => EditLeaguePage(league: league),
                        ),
                      );
                      if (mounted) _fetchLeagues();
                    },
                  ),
                );
              },
            );
          } else if (state is LeagueFailure) {
            return Center(
              child: Text(
                'Errore nel caricamento dei campionati',
                style: TextStyle(color: AppColors.logoRed),
              ),
            );
          }

          return const Center(child: CircularProgressIndicator());
        },
      ),
    );
  }
}
