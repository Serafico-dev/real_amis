import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:real_amis/common/cubits/app_user/app_user_cubit.dart';
import 'package:real_amis/common/widgets/appBar/app_bar_no_nav.dart';
import 'package:real_amis/common/widgets/loader/loader.dart';
import 'package:real_amis/core/configs/theme/app_colors.dart';
import 'package:real_amis/core/utils/show_snackbar.dart';
import 'package:real_amis/domain/entities/player/player_entity.dart';
import 'package:real_amis/presentation/player/bloc/player_bloc.dart';
import 'package:real_amis/presentation/player/pages/add_new_player.dart';
import 'package:real_amis/presentation/player/widgets/player_card.dart';

class PlayersPage extends StatefulWidget {
  const PlayersPage({super.key});

  static MaterialPageRoute route() =>
      MaterialPageRoute(builder: (context) => PlayersPage());

  @override
  State<PlayersPage> createState() => _PlayersPageState();
}

class _PlayersPageState extends State<PlayersPage> {
  final TextEditingController _searchController = TextEditingController();
  String _query = '';

  @override
  void initState() {
    super.initState();
    context.read<PlayerBloc>().add(PlayerFetchAllPlayers());
    _searchController.addListener(() {
      setState(() => _query = _searchController.text.trim());
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  List<PlayerEntity> _filterPlayers(List<PlayerEntity> players, String query) {
    if (query.isEmpty) return players;
    final q = query.toLowerCase();
    return players.where((p) => p.fullName.toLowerCase().contains(q)).toList();
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
                  await Navigator.push(context, AddNewPlayerPage.route());
                  context.read<PlayerBloc>().add(PlayerFetchAllPlayers());
                },
                icon: Icon(Icons.add, size: 30),
              );
            },
          ),
        ],
      ),
      body: BlocConsumer<PlayerBloc, PlayerState>(
        listener: (context, state) {
          if (state is PlayerFailure) {
            showSnackBar(context, state.error);
          }
        },
        builder: (context, state) {
          if (state is PlayerLoading) {
            return Loader();
          }
          if (state is PlayerUpdateSuccess ||
              state is PlayerDeleteSuccess ||
              state is PlayerFailure) {
            context.read<PlayerBloc>().add(PlayerFetchAllPlayers());
          }
          if (state is PlayerDisplaySuccess) {
            final sortedPlayers = List<PlayerEntity>.from(state.players)
              ..sort((a, b) => a.fullName.compareTo(b.fullName));

            final filtered = _filterPlayers(sortedPlayers, _query);
            return Column(
              children: [
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  child: TextField(
                    controller: _searchController,
                    decoration: InputDecoration(
                      hintText: 'Cerca giocatore',
                      prefixIcon: Icon(Icons.search),
                      suffixIcon: _query.isNotEmpty
                          ? IconButton(
                              icon: Icon(Icons.clear),
                              onPressed: () {
                                _searchController.clear();
                                setState(() => _query = '');
                              },
                            )
                          : null,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                        borderSide: BorderSide.none,
                      ),
                      filled: true,
                      fillColor: AppColors.primary,
                    ),
                  ),
                ),
                Expanded(
                  child: RefreshIndicator(
                    onRefresh: () async {
                      context.read<PlayerBloc>().add(PlayerFetchAllPlayers());
                    },
                    child: filtered.isEmpty
                        ? ListView(
                            physics: AlwaysScrollableScrollPhysics(),
                            children: [
                              SizedBox(height: 200),
                              Center(child: Text('Nessun giocatore trovato')),
                            ],
                          )
                        : ListView.builder(
                            itemCount: filtered.length,
                            itemBuilder: (context, index) {
                              final player = filtered[index];
                              return PlayerCard(
                                player: player,
                                color: index.isEven
                                    ? AppColors.tertiary
                                    : AppColors.primary,
                              );
                            },
                          ),
                  ),
                ),
              ],
            );
          }
          return SizedBox();
        },
      ),
    );
  }
}
