import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:real_amis/common/helpers/is_dark_mode.dart';
import 'package:real_amis/common/widgets/appBar/app_bar_no_nav.dart';
import 'package:real_amis/common/widgets/loader/loader.dart';
import 'package:real_amis/core/configs/theme/app_colors.dart';
import 'package:real_amis/core/utils/admin_only.dart';
import 'package:real_amis/core/utils/show_snackbar.dart';
import 'package:real_amis/domain/entities/match/match_entity.dart';
import 'package:real_amis/presentation/match/bloc/match_bloc.dart';
import 'package:real_amis/presentation/match/pages/add_new_match.dart';
import 'package:real_amis/presentation/match/pages/match_viewer.dart';
import 'package:real_amis/presentation/match/widgets/empty_matches.dart';
import 'package:real_amis/presentation/match/widgets/match_summary.dart';

class MatchesPage extends StatefulWidget {
  const MatchesPage({super.key});

  static MaterialPageRoute route() =>
      MaterialPageRoute(builder: (_) => const MatchesPage());

  @override
  State<MatchesPage> createState() => _MatchesPageState();
}

class _MatchesPageState extends State<MatchesPage> {
  final _bucket = PageStorageBucket();

  @override
  void initState() {
    super.initState();
    _fetchMatches();
  }

  void _fetchMatches() {
    context.read<MatchBloc>().add(MatchFetchAllMatches());
  }

  Future<void> _refresh() async {
    _fetchMatches();
    await Future.delayed(const Duration(milliseconds: 300));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBarNoNav(
        actions: [
          AdminOnly(
            child: IconButton(
              icon: const Icon(Icons.add, size: 30),
              tooltip: 'Aggiungi partita',
              onPressed: () async {
                await Navigator.push(context, AddNewMatchPage.route());
                if (mounted) _fetchMatches();
              },
            ),
          ),
        ],
      ),
      body: BlocConsumer<MatchBloc, MatchState>(
        listener: (context, state) {
          if (state is MatchFailure) showSnackBar(context, state.error);
          if (state is MatchUpdateSuccess || state is MatchDeleteSuccess) {
            _fetchMatches();
          }
        },
        builder: (context, state) {
          if (state is MatchLoading) return const Loader();

          if (state is MatchDisplaySuccess) {
            final matches = _sortedMatches(state.matches);

            return PageStorage(
              bucket: _bucket,
              child: RefreshIndicator(
                onRefresh: _refresh,
                child: matches.isEmpty
                    ? const EmptyMatches()
                    : ListView.builder(
                        key: const PageStorageKey('matches_list'),
                        padding: const EdgeInsets.symmetric(vertical: 8),
                        itemCount: matches.length,
                        itemBuilder: (context, index) {
                          final match = matches[index];
                          return MatchSummary(
                            match: match,
                            backgroundColor: index.isEven
                                ? (context.isDarkMode
                                          ? AppColors.cardDark
                                          : AppColors.cardLight)
                                      .withValues(alpha: 0.25)
                                : (context.isDarkMode
                                          ? AppColors.tertiary
                                          : AppColors.primary)
                                      .withValues(alpha: 0.25),
                            onTap: () async {
                              await Navigator.push(
                                context,
                                MatchViewerPage.route(match.id),
                              );
                              if (context.mounted) _fetchMatches();
                            },
                          );
                        },
                      ),
              ),
            );
          }

          return const SizedBox.shrink();
        },
      ),
    );
  }

  List<MatchEntity> _sortedMatches(List<MatchEntity> matches) {
    final list = List<MatchEntity>.from(matches);
    list.sort((a, b) => b.matchDate.compareTo(a.matchDate));
    return list;
  }
}
