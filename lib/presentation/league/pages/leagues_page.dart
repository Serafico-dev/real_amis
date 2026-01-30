import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:real_amis/common/widgets/appBar/app_bar_yes_nav.dart';
import 'package:real_amis/core/configs/theme/app_colors.dart';
import 'package:real_amis/domain/entities/league/league_entity.dart';
import 'package:real_amis/presentation/league/pages/add_new_league.dart';
import 'package:real_amis/presentation/league/pages/edit_league.dart';
import 'package:real_amis/presentation/league/providers/league_notifier.dart';

class LeaguesPage extends ConsumerStatefulWidget {
  const LeaguesPage({super.key});

  static MaterialPageRoute route() =>
      MaterialPageRoute(builder: (_) => const LeaguesPage());

  @override
  ConsumerState<LeaguesPage> createState() => _LeaguesPageState();
}

class _LeaguesPageState extends ConsumerState<LeaguesPage> {
  @override
  void initState() {
    super.initState();
  }

  Future<void> _refresh() async {
    await ref.read(leagueNotifierProvider.notifier).fetchAllLeagues();
  }

  @override
  Widget build(BuildContext context) {
    final leagueState = ref.watch(leagueNotifierProvider);

    return Scaffold(
      appBar: AppBarYesNav(
        title: const Text('Gestisci campionati'),
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () async {
              await Navigator.push(context, AddNewLeaguePage.route());
              if (mounted) _refresh();
            },
          ),
        ],
      ),
      body: leagueState.when(
        data: (leagues) {
          final sortedLeagues = List<LeagueEntity>.from(leagues)
            ..sort((a, b) => b.year.compareTo(a.year));

          if (sortedLeagues.isEmpty) {
            return const Center(child: Text('Nessun campionato disponibile'));
          }

          return RefreshIndicator(
            onRefresh: _refresh,
            child: ListView.separated(
              padding: const EdgeInsets.all(16),
              itemCount: sortedLeagues.length,
              separatorBuilder: (_, _) => const SizedBox(height: 8),
              itemBuilder: (context, index) {
                final league = sortedLeagues[index];
                return Card(
                  child: ListTile(
                    title: Text('${league.name} - ${league.year}'),
                    subtitle: Text('Squadre: ${league.teamIds.length}'),
                    trailing: const Icon(Icons.edit),
                    onTap: () async {
                      await Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => EditLeaguePage(league: league),
                        ),
                      );
                      if (mounted) _refresh();
                    },
                  ),
                );
              },
            ),
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, _) => Center(
          child: Text(
            'Errore nel caricamento dei campionati',
            style: const TextStyle(color: AppColors.logoRed),
          ),
        ),
      ),
    );
  }
}
