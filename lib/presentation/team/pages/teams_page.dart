import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:real_amis/common/cubits/app_user/app_user_cubit.dart';
import 'package:real_amis/common/widgets/appBar/app_bar_no_nav.dart';
import 'package:real_amis/common/widgets/loader/loader.dart';
import 'package:real_amis/core/utils/show_snackbar.dart';
import 'package:real_amis/domain/entities/team/team_entity.dart';
import 'package:real_amis/presentation/team/bloc/team_bloc.dart';
import 'package:real_amis/presentation/team/pages/add_new_team.dart';
import 'package:real_amis/presentation/team/pages/edit_team.dart';

class TeamsPage extends StatefulWidget {
  const TeamsPage({super.key});

  static MaterialPageRoute route() =>
      MaterialPageRoute(builder: (context) => TeamsPage());

  @override
  State<TeamsPage> createState() => _TeamsPageState();
}

class _TeamsPageState extends State<TeamsPage> {
  @override
  void initState() {
    super.initState();
    context.read<TeamBloc>().add(TeamFetchAllTeams());
  }

  Future<void> _refreshTeams() async {
    context.read<TeamBloc>().add(TeamFetchAllTeams());
    await Future.delayed(Duration(milliseconds: 500));
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
                  await Navigator.push(context, AddNewTeamPage.route());
                  if (context.mounted) {
                    context.read<TeamBloc>().add(TeamFetchAllTeams());
                  }
                },
                icon: Icon(Icons.add, size: 30),
              );
            },
          ),
        ],
      ),
      body: BlocConsumer<TeamBloc, TeamState>(
        listener: (context, state) {
          if (state is TeamFailure) {
            showSnackBar(context, state.error);
          }
        },
        builder: (context, state) {
          if (state is TeamLoading) {
            return Loader();
          }
          if (state is TeamUpdateSuccess ||
              state is TeamDeleteSuccess ||
              state is TeamFailure) {
            context.read<TeamBloc>().add(TeamFetchAllTeams());
          }
          if (state is TeamDisplaySuccess) {
            final sortedTeams = List<TeamEntity>.from(state.teams)
              ..sort((a, b) => b.score!.compareTo(a.score!));
            return RefreshIndicator(
              onRefresh: _refreshTeams,
              child: sortedTeams.isEmpty
                  ? ListView(
                      physics: AlwaysScrollableScrollPhysics(),
                      children: [
                        SizedBox(height: 200),
                        Center(child: Text('Nessuna squadra trovata')),
                      ],
                    )
                  : ListView.builder(
                      padding: EdgeInsets.all(20),
                      itemCount: sortedTeams.length + 1,
                      itemBuilder: (context, index) {
                        if (index == 0) {
                          return Container(
                            padding: EdgeInsets.all(10),
                            child: Row(
                              children: [
                                Expanded(
                                  child: Text(
                                    'Squadra',
                                    style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                                Expanded(
                                  child: Text(
                                    'Punteggio',
                                    textAlign: TextAlign.right,
                                    style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          );
                        }
                        final team = sortedTeams[index - 1];
                        return BlocSelector<AppUserCubit, AppUserState, bool?>(
                          selector: (state) => state is AppUserLoggedIn
                              ? state.user.isAdmin
                              : false,
                          builder: (context, isAdmin) {
                            return InkWell(
                              onTap: isAdmin == true
                                  ? () async {
                                      await Navigator.push(
                                        context,
                                        EditTeamPage.route(team),
                                      );
                                      if (context.mounted) {
                                        context.read<TeamBloc>().add(
                                          TeamFetchAllTeams(),
                                        );
                                      }
                                    }
                                  : null,
                              child: Container(
                                padding: EdgeInsets.all(12),
                                decoration: BoxDecoration(
                                  border: Border(
                                    bottom: BorderSide(
                                      color: Colors.grey.shade300,
                                    ),
                                  ),
                                ),
                                child: Row(
                                  children: [
                                    ClipRRect(
                                      borderRadius: BorderRadius.circular(10),
                                      child: CachedNetworkImage(
                                        imageUrl: team.imageUrl,
                                        height: 35,
                                        fit: BoxFit.cover,
                                      ),
                                    ),
                                    SizedBox(width: 15),
                                    Expanded(
                                      flex: 6,
                                      child: Text(
                                        team.name,
                                        style: TextStyle(fontSize: 16),
                                      ),
                                    ),
                                    Expanded(
                                      flex: 2,
                                      child: Text(
                                        team.score!.toString(),
                                        textAlign: TextAlign.right,
                                        style: TextStyle(fontSize: 16),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            );
                          },
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
