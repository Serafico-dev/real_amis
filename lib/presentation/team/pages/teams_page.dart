import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:real_amis/common/cubits/app_user/app_user_cubit.dart';
import 'package:real_amis/common/helpers/is_dark_mode.dart';
import 'package:real_amis/common/widgets/appBar/app_bar_no_nav.dart';
import 'package:real_amis/common/widgets/loader/loader.dart';
import 'package:real_amis/core/configs/theme/app_colors.dart';
import 'package:real_amis/core/utils/show_snackbar.dart';
import 'package:real_amis/domain/entities/team/team_entity.dart';
import 'package:real_amis/presentation/team/bloc/team_bloc.dart';
import 'package:real_amis/presentation/team/pages/add_new_team.dart';
import 'package:real_amis/presentation/team/pages/edit_team.dart';

class TeamsPage extends StatefulWidget {
  const TeamsPage({super.key});

  static MaterialPageRoute route() =>
      MaterialPageRoute(builder: (_) => const TeamsPage());

  @override
  State<TeamsPage> createState() => _TeamsPageState();
}

class _TeamsPageState extends State<TeamsPage> {
  final PageStorageBucket _bucket = PageStorageBucket();

  @override
  void initState() {
    super.initState();
    _fetchTeams();
  }

  void _fetchTeams() {
    context.read<TeamBloc>().add(TeamFetchAllTeams());
  }

  Future<void> _refreshTeams() async {
    _fetchTeams();
    await Future.delayed(const Duration(milliseconds: 500));
  }

  @override
  Widget build(BuildContext context) {
    final isDarkMode = context.isDarkMode;

    return Scaffold(
      appBar: AppBarNoNav(
        actions: [
          BlocSelector<AppUserCubit, AppUserState, bool>(
            selector: (state) => state is AppUserLoggedIn && state.user.isAdmin,
            builder: (context, isAdmin) {
              if (!isAdmin) return const SizedBox.shrink();
              return IconButton(
                onPressed: () async {
                  await Navigator.push(context, AddNewTeamPage.route());
                  if (context.mounted) _fetchTeams();
                },
                icon: const Icon(Icons.add, size: 30),
                tooltip: 'Aggiungi squadra',
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
          if (state is TeamUpdateSuccess || state is TeamDeleteSuccess) {
            _fetchTeams();
          }
        },
        builder: (context, state) {
          if (state is TeamLoading) return const Loader();

          if (state is TeamDisplaySuccess) {
            final sortedTeams = List<TeamEntity>.from(state.teams)
              ..sort((a, b) => (b.score ?? 0).compareTo(a.score ?? 0));

            return PageStorage(
              bucket: _bucket,
              child: RefreshIndicator(
                onRefresh: _refreshTeams,
                color: AppColors.tertiary,
                child: sortedTeams.isEmpty
                    ? ListView(
                        physics: const AlwaysScrollableScrollPhysics(),
                        children: [
                          const SizedBox(height: 200),
                          Center(
                            child: Text(
                              'Nessuna squadra trovata',
                              style: TextStyle(
                                color: isDarkMode
                                    ? AppColors.textDarkPrimary
                                    : AppColors.textLightPrimary,
                              ),
                            ),
                          ),
                        ],
                      )
                    : ListView.builder(
                        key: const PageStorageKey('teams_list'),
                        padding: const EdgeInsets.all(20),
                        itemCount: sortedTeams.length + 1,
                        itemBuilder: (context, index) {
                          if (index == 0) return _buildHeaderRow();
                          final team = sortedTeams[index - 1];
                          return _buildTeamRow(team);
                        },
                      ),
              ),
            );
          }

          return const SizedBox.shrink();
        },
      ),
      backgroundColor: isDarkMode
          ? AppColors.bgDark
          : AppColors.bgLight, // sfondo coerente
    );
  }

  Widget _buildHeaderRow() {
    final isDarkMode = context.isDarkMode;
    final textColor = isDarkMode
        ? AppColors.textDarkPrimary
        : AppColors.textLightPrimary;

    return Container(
      padding: const EdgeInsets.all(10),
      child: Row(
        children: [
          Expanded(
            child: Text(
              'Squadra',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: textColor,
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
                color: textColor,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTeamRow(TeamEntity team) {
    final isDarkMode = context.isDarkMode;

    return BlocSelector<AppUserCubit, AppUserState, bool>(
      selector: (state) => state is AppUserLoggedIn && state.user.isAdmin,
      builder: (context, isAdmin) {
        return InkWell(
          onTap: isAdmin
              ? () async {
                  await Navigator.push(context, EditTeamPage.route(team));
                  if (context.mounted) _fetchTeams();
                }
              : null,
          child: Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              border: Border(
                bottom: BorderSide(
                  color: isDarkMode
                      ? AppColors.dividerDark
                      : AppColors.dividerLight,
                ),
              ),
            ),
            child: Row(
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(10),
                  child: SizedBox(
                    height: 35,
                    width: 35,
                    child: CachedNetworkImage(
                      imageUrl: team.imageUrl,
                      fit: BoxFit.cover,
                      placeholder: (_, _) => const SizedBox.shrink(),
                      errorWidget: (_, _, _) => Icon(
                        Icons.broken_image,
                        size: 20,
                        color: isDarkMode
                            ? AppColors.textDarkSecondary
                            : AppColors.textLightSecondary,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 15),
                Expanded(
                  flex: 6,
                  child: Text(
                    team.name,
                    style: TextStyle(
                      fontSize: 16,
                      color: isDarkMode
                          ? AppColors.textDarkPrimary
                          : AppColors.textLightPrimary,
                    ),
                  ),
                ),
                Expanded(
                  flex: 2,
                  child: Text(
                    (team.score ?? 0).toString(),
                    textAlign: TextAlign.right,
                    style: TextStyle(
                      fontSize: 16,
                      color: isDarkMode
                          ? AppColors.textDarkPrimary
                          : AppColors.textLightPrimary,
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
