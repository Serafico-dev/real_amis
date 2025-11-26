import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:real_amis/common/cubits/app_user/app_user_cubit.dart';
import 'package:real_amis/common/widgets/appBar/app_bar_yes_nav.dart';
import 'package:real_amis/common/widgets/loader/loader.dart';
import 'package:real_amis/core/configs/theme/app_colors.dart';
import 'package:real_amis/core/utils/format_data.dart';
import 'package:real_amis/core/utils/show_snackbar.dart';
import 'package:real_amis/domain/entities/match/match_entity.dart';
import 'package:real_amis/presentation/match/bloc/match_bloc.dart';
import 'package:real_amis/presentation/match/pages/edit_match.dart';

class MatchViewerPage extends StatelessWidget {
  static MaterialPageRoute route(String matchId) => MaterialPageRoute(
    builder: (context) => MatchViewerPage(matchId: matchId),
  );
  final String matchId;
  const MatchViewerPage({super.key, required this.matchId});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBarYesNav(
        title: Text('Dettaglio partita'),
        actions: [
          BlocSelector<AppUserCubit, AppUserState, bool?>(
            selector: (state) =>
                state is AppUserLoggedIn ? state.user.isAdmin : false,
            builder: (context, isAdmin) {
              if (isAdmin != true) return SizedBox.shrink();
              return IconButton(
                onPressed: () async {
                  final bloc = context.read<MatchBloc>();
                  final currentState = bloc.state;
                  MatchEntity? currentMatch;
                  if (currentState is MatchDisplaySuccess) {
                    final matches = currentState.matches.where(
                      (p) => p.id == matchId,
                    );
                    if (matches.isEmpty) {
                      currentMatch = null;
                    } else {
                      currentMatch = matches.first;
                    }
                  }
                  if (currentState is MatchUpdateSuccess) {
                    currentMatch = currentState.updatedMatch;
                  }
                  final matchToEdit = currentMatch;
                  if (matchToEdit == null) {
                    showSnackBar(context, 'Partita non trovata');
                    return;
                  }
                  await Navigator.push(
                    context,
                    EditMatchPage.route(matchToEdit),
                  );
                },
                icon: Icon(Icons.edit, size: 25),
              );
            },
          ),
        ],
      ),
      body: BlocBuilder<MatchBloc, MatchState>(
        builder: (context, state) {
          if (state is MatchLoading) {
            return Loader();
          }
          MatchEntity? match;
          if (state is MatchDisplaySuccess) {
            final matches = state.matches.where((p) => p.id == matchId);
            if (matches.isEmpty) {
              match = null;
            } else {
              match = matches.first;
            }
          }
          if (state is MatchUpdateSuccess) {
            match = state.updatedMatch;
          }
          if (match == null || state is MatchDeleteSuccess) {
            return Center(child: Text('Partita non trovata.'));
          }

          return Scrollbar(
            child: SingleChildScrollView(
              child: Container(
                margin: EdgeInsets.all(16.0),
                padding: const EdgeInsets.all(16.0),
                decoration: BoxDecoration(
                  color: AppColors.tertiary,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        Text(
                          match.matchDay ?? '',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 20,
                          ),
                        ),
                      ],
                    ),
                    Text(
                      formatDateByddMMYYYYnHHmm(match.matchDate),
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        Column(
                          children: [
                            Image.network(match.homeTeam!.imageUrl, width: 100),
                            SizedBox(height: 10),
                            Text(
                              match.homeTeamScore.toString(),
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 24,
                              ),
                            ),
                          ],
                        ),
                        Text(
                          'VS',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 24,
                          ),
                        ),
                        Column(
                          children: [
                            Image.network(match.awayTeam!.imageUrl, width: 100),
                            SizedBox(height: 10),
                            Text(
                              match.awayTeamScore.toString(),
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 24,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
