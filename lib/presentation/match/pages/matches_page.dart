import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:real_amis/common/cubits/app_user/app_user_cubit.dart';
import 'package:real_amis/common/widgets/appBar/app_bar_no_nav.dart';
import 'package:real_amis/common/widgets/loader/loader.dart';
import 'package:real_amis/core/configs/theme/app_colors.dart';
import 'package:real_amis/core/utils/show_snackbar.dart';
import 'package:real_amis/domain/entities/match/match_entity.dart';
import 'package:real_amis/presentation/match/bloc/match_bloc.dart';
import 'package:real_amis/presentation/match/pages/add_new_match.dart';
import 'package:real_amis/presentation/match/widgets/match_card.dart';

class MatchesPage extends StatefulWidget {
  const MatchesPage({super.key});

  static MaterialPageRoute route() =>
      MaterialPageRoute(builder: (context) => MatchesPage());

  @override
  State<MatchesPage> createState() => _MatchesPageState();
}

class _MatchesPageState extends State<MatchesPage> {
  @override
  void initState() {
    super.initState();
    context.read<MatchBloc>().add(MatchFetchAllMatches());
  }

  Future<void> _refreshMatches() async {
    context.read<MatchBloc>().add(MatchFetchAllMatches());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBarNoNav(
        actions: [
          BlocSelector<AppUserCubit, AppUserState, bool?>(
            selector: (state) =>
                state is AppUserLoggedIn ? state.user.isAdmin : false,
            builder: (context, isAdmin) {
              if (isAdmin != true) return SizedBox.shrink();
              return IconButton(
                onPressed: () async {
                  await Navigator.push(context, AddNewMatchPage.route());
                  context.read<MatchBloc>().add(MatchFetchAllMatches());
                },
                icon: Icon(Icons.add, size: 30),
              );
            },
          ),
        ],
      ),
      body: BlocConsumer<MatchBloc, MatchState>(
        listener: (context, state) {
          if (state is MatchFailure) {
            showSnackBar(context, state.error);
          }
        },
        builder: (context, state) {
          if (state is MatchLoading) {
            return Loader();
          }
          if (state is MatchUpdateSuccess ||
              state is MatchDeleteSuccess ||
              state is MatchFailure) {
            context.read<MatchBloc>().add(MatchFetchAllMatches());
          }
          if (state is MatchDisplaySuccess) {
            final sortedMatches = List<MatchEntity>.from(state.matches)
              ..sort((a, b) => b.matchDate.compareTo(a.matchDate));

            return RefreshIndicator(
              onRefresh: _refreshMatches,
              child: sortedMatches.isEmpty
                  ? ListView(
                      physics: AlwaysScrollableScrollPhysics(),
                      children: [
                        SizedBox(height: 200),
                        Center(child: Text('Nessuna partita trovata')),
                      ],
                    )
                  : ListView.builder(
                      itemCount: sortedMatches.length,
                      itemBuilder: (context, index) {
                        final match = sortedMatches[index];
                        return MatchCard(
                          match: match,
                          color: index.isEven
                              ? AppColors.tertiary
                              : AppColors.primary,
                        );
                      },
                    ),
            );
          }
          return SizedBox();
        },
      ),
    );
  }
}
