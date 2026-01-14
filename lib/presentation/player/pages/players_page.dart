import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:real_amis/common/cubits/app_user/app_user_cubit.dart';
import 'package:real_amis/common/widgets/appBar/app_bar_no_nav.dart';
import 'package:real_amis/common/widgets/loader/loader.dart';
import 'package:real_amis/core/configs/theme/app_colors.dart';
import 'package:real_amis/core/utils/show_snackbar.dart';
import 'package:real_amis/domain/entities/player/player_entity.dart';
import 'package:real_amis/domain/entities/player/player_role.dart';
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

class _PlayersPageState extends State<PlayersPage>
    with SingleTickerProviderStateMixin {
  final TextEditingController _searchController = TextEditingController();
  String _query = '';
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    context.read<PlayerBloc>().add(PlayerFetchAllPlayers());
    _searchController.addListener(
      () => setState(() => _query = _searchController.text.trim()),
    );
  }

  @override
  void dispose() {
    _tabController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  List<PlayerEntity> _filterPlayers(List<PlayerEntity> players, String query) {
    if (query.isEmpty) return players;
    final q = query.toLowerCase();
    return players.where((p) => p.fullName.toLowerCase().contains(q)).toList();
  }

  bool _isPlayerRole(PlayerRole r) {
    switch (r) {
      case PlayerRole.portiere:
      case PlayerRole.difensore:
      case PlayerRole.difensoreCentrale:
      case PlayerRole.difensoreTerzino:
      case PlayerRole.centrocampista:
      case PlayerRole.mediano:
      case PlayerRole.centrocampistaCentrale:
      case PlayerRole.trequartista:
      case PlayerRole.attaccante:
      case PlayerRole.centravanti:
      case PlayerRole.ala:
      case PlayerRole.riserva:
      case PlayerRole.nessuno:
        return true;
      default:
        return false;
    }
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
          if (state is PlayerFailure) showSnackBar(context, state.error);
        },
        builder: (context, state) {
          if (state is PlayerLoading) return Loader();
          if (state is PlayerUpdateSuccess ||
              state is PlayerDeleteSuccess ||
              state is PlayerFailure) {
            context.read<PlayerBloc>().add(PlayerFetchAllPlayers());
          }
          if (state is PlayerDisplaySuccess) {
            final allPlayers = List<PlayerEntity>.from(state.players)
              ..sort((a, b) => a.fullName.compareTo(b.fullName));
            final filteredBySearch = _filterPlayers(allPlayers, _query);

            final giocatori = filteredBySearch
                .where((p) => _isPlayerRole(p.role))
                .toList();
            final leggende = filteredBySearch
                .where((p) => p.role == PlayerRole.leggenda)
                .toList();
            final staff = filteredBySearch
                .where(
                  (p) =>
                      !_isPlayerRole(p.role) && p.role != PlayerRole.leggenda,
                )
                .toList();

            return Column(
              children: [
                TabBar(
                  controller: _tabController,
                  tabs: [
                    Tab(text: 'Giocatori'),
                    Tab(text: 'Leggende'),
                    Tab(text: 'Staff'),
                  ],
                  indicatorColor: Colors.white,
                  labelColor: Colors.white,
                  unselectedLabelColor: Colors.white70,
                ),

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
                  child: TabBarView(
                    controller: _tabController,
                    children: [
                      _buildListForGroup(giocatori),
                      _buildListForGroup(leggende),
                      _buildListForGroup(staff),
                    ],
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

  Widget _buildListForGroup(List<PlayerEntity> list) {
    return RefreshIndicator(
      onRefresh: () async =>
          context.read<PlayerBloc>().add(PlayerFetchAllPlayers()),
      child: list.isEmpty
          ? ListView(
              physics: AlwaysScrollableScrollPhysics(),
              children: [
                SizedBox(height: 200),
                Center(child: Text('Nessun giocatore trovato')),
              ],
            )
          : ListView.builder(
              itemCount: list.length,
              itemBuilder: (context, index) {
                final player = list[index];
                return PlayerCard(
                  player: player,
                  color: index.isEven ? AppColors.tertiary : AppColors.primary,
                );
              },
            ),
    );
  }
}
