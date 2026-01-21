import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:real_amis/common/widgets/appBar/app_bar_no_nav.dart';
import 'package:real_amis/common/widgets/loader/loader.dart';
import 'package:real_amis/core/configs/theme/app_colors.dart';
import 'package:real_amis/core/utils/admin_only.dart';
import 'package:real_amis/core/utils/show_snackbar.dart';
import 'package:real_amis/domain/entities/match/match_entity.dart';
import 'package:real_amis/presentation/choose_mode/bloc/theme_cubit.dart';
import 'package:real_amis/presentation/match/bloc/match_bloc.dart';
import 'package:real_amis/presentation/match/pages/add_new_match.dart';
import 'package:real_amis/presentation/match/widgets/empty_matches.dart';
import 'package:real_amis/presentation/match/widgets/matches_list.dart';

class MatchesPage extends StatefulWidget {
  const MatchesPage({super.key});

  static MaterialPageRoute route() =>
      MaterialPageRoute(builder: (_) => const MatchesPage());

  @override
  State<MatchesPage> createState() => _MatchesPageState();
}

class _MatchesPageState extends State<MatchesPage> {
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
    return BlocBuilder<ThemeCubit, ThemeMode>(
      builder: (context, themeMode) {
        final brightness = MediaQuery.of(context).platformBrightness;
        final isDark =
            themeMode == ThemeMode.dark ||
            (themeMode == ThemeMode.system && brightness == Brightness.dark);

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
                  color: isDark
                      ? AppColors.textDarkPrimary
                      : AppColors.textLightPrimary,
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

                if (matches.isEmpty) return const EmptyMatches();

                return RefreshIndicator(
                  onRefresh: _refresh,
                  child: MatchesList(matches: matches, isDark: isDark),
                );
              }

              return const SizedBox.shrink();
            },
          ),
        );
      },
    );
  }

  List<MatchEntity> _sortedMatches(List<MatchEntity> matches) {
    final list = List<MatchEntity>.from(matches);
    list.sort((a, b) => b.matchDate.compareTo(a.matchDate));
    return list;
  }
}
