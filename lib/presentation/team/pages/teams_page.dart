import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:real_amis/common/cubits/app_user/app_user_cubit.dart';
import 'package:real_amis/common/widgets/appBar/app_bar_no_nav.dart';
import 'package:real_amis/common/widgets/loader/loader.dart';
import 'package:real_amis/core/configs/theme/app_colors.dart';
import 'package:real_amis/core/utils/show_snackbar.dart';
import 'package:real_amis/domain/entities/team/team_entity.dart';
import 'package:real_amis/presentation/team/bloc/team_bloc.dart';
import 'package:real_amis/presentation/team/pages/add_new_team.dart';
import 'package:real_amis/presentation/team/widgets/team_card.dart';

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
                  context.read<TeamBloc>().add(TeamFetchAllTeams());
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
              ..sort((a, b) => a.name.compareTo(b.name));

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
                  : GridView.builder(
                      padding: EdgeInsets.all(12),
                      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 2,
                        mainAxisSpacing: 1,
                        crossAxisSpacing: 1,
                        childAspectRatio: 1 / 1,
                      ),
                      itemCount: sortedTeams.length,
                      itemBuilder: (context, index) {
                        final team = sortedTeams[index];
                        return BlocSelector<AppUserCubit, AppUserState, bool?>(
                          selector: (state) => state is AppUserLoggedIn
                              ? state.user.isAdmin
                              : false,
                          builder: (context, isAdmin) {
                            return TeamCard(
                              team: team,
                              color: AppColors.quaternary,
                              isAdmin: isAdmin == true,
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
