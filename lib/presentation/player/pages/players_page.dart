import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:real_amis/common/cubits/app_user/app_user_cubit.dart';
import 'package:real_amis/common/helpers/is_dark_mode.dart';
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
      MaterialPageRoute(builder: (_) => const PlayersPage());

  @override
  State<PlayersPage> createState() => _PlayersPageState();
}

class _PlayersPageState extends State<PlayersPage>
    with SingleTickerProviderStateMixin {
  final TextEditingController _searchController = TextEditingController();
  final PageStorageBucket _bucket = PageStorageBucket();
  String _query = '';
  late final TabController _tabController;

  final Set<PlayerRole> playerRoles = {
    PlayerRole.portiere,
    PlayerRole.difensore,
    PlayerRole.difensoreCentrale,
    PlayerRole.difensoreTerzino,
    PlayerRole.centrocampista,
    PlayerRole.mediano,
    PlayerRole.centrocampistaCentrale,
    PlayerRole.trequartista,
    PlayerRole.attaccante,
    PlayerRole.centravanti,
    PlayerRole.ala,
    PlayerRole.riserva,
    PlayerRole.nessuno,
  };

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

  bool _isPlayerRole(PlayerRole role) => playerRoles.contains(role);

  List<PlayerEntity> _filterPlayers(List<PlayerEntity> players, String query) {
    if (query.isEmpty) return players;
    final q = query.toLowerCase();
    return players.where((p) => p.fullName.toLowerCase().contains(q)).toList();
  }

  @override
  Widget build(BuildContext context) {
    final isDarkMode = context.isDarkMode;

    return Scaffold(
      appBar: AppBarNoNav(
        backgroundColor: isDarkMode ? AppColors.bgDark : AppColors.bgLight,
        actions: [
          BlocSelector<AppUserCubit, AppUserState, bool?>(
            selector: (state) =>
                state is AppUserLoggedIn ? state.user.isAdmin : false,
            builder: (context, isAdmin) {
              if (isAdmin != true) return const SizedBox.shrink();
              return IconButton(
                onPressed: () async {
                  await Navigator.push(context, AddNewPlayerPage.route());
                  if (context.mounted) {
                    context.read<PlayerBloc>().add(PlayerFetchAllPlayers());
                  }
                },
                icon: Icon(
                  Icons.add,
                  size: 30,
                  color: isDarkMode
                      ? AppColors.textDarkPrimary
                      : AppColors.textLightPrimary,
                ),
                tooltip: 'Aggiungi giocatore',
              );
            },
          ),
        ],
      ),
      body: BlocConsumer<PlayerBloc, PlayerState>(
        listener: (context, state) {
          if (state is PlayerFailure) showSnackBar(context, state.error);
          if (state is PlayerUpdateSuccess || state is PlayerDeleteSuccess) {
            context.read<PlayerBloc>().add(PlayerFetchAllPlayers());
          }
        },
        builder: (context, state) {
          if (state is PlayerLoading) return const Loader();

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

            return PageStorage(
              bucket: _bucket,
              child: Column(
                children: [
                  TabBar(
                    controller: _tabController,
                    tabs: const [
                      Tab(text: 'Giocatori'),
                      Tab(text: 'Leggende'),
                      Tab(text: 'Staff'),
                    ],
                    indicatorColor: AppColors.accent,
                    labelColor: isDarkMode
                        ? AppColors.textDarkPrimary
                        : AppColors.textLightPrimary,
                    unselectedLabelColor:
                        (isDarkMode
                                ? AppColors.textDarkPrimary
                                : AppColors.textLightPrimary)
                            .withValues(alpha: 0.7),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 8,
                    ),
                    child: TextField(
                      key: const PageStorageKey('players_search'),
                      controller: _searchController,
                      decoration: InputDecoration(
                        hintText: 'Cerca giocatore',
                        prefixIcon: const Icon(Icons.search),
                        suffixIcon: _query.isNotEmpty
                            ? IconButton(
                                icon: const Icon(Icons.clear),
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
                        fillColor: isDarkMode
                            ? AppColors.inputFillDark
                            : AppColors.inputFillLight,
                      ),
                      style: TextStyle(
                        color: isDarkMode
                            ? AppColors.textDarkPrimary
                            : AppColors.textLightPrimary,
                      ),
                    ),
                  ),
                  Expanded(
                    child: TabBarView(
                      controller: _tabController,
                      children: [
                        _buildListForGroup(
                          giocatori,
                          'giocatori_list',
                          isDarkMode,
                        ),
                        _buildListForGroup(
                          leggende,
                          'leggende_list',
                          isDarkMode,
                        ),
                        _buildListForGroup(staff, 'staff_list', isDarkMode),
                      ],
                    ),
                  ),
                ],
              ),
            );
          }

          return const SizedBox.shrink();
        },
      ),
    );
  }

  Widget _buildListForGroup(
    List<PlayerEntity> list,
    String storageKey,
    bool isDarkMode,
  ) {
    if (list.isEmpty) {
      return ListView(
        physics: const AlwaysScrollableScrollPhysics(),
        children: [
          const SizedBox(height: 200),
          Center(
            child: Text(
              'Nessun giocatore trovato',
              style: TextStyle(
                color: isDarkMode
                    ? AppColors.textDarkSecondary
                    : AppColors.textLightSecondary,
              ),
            ),
          ),
        ],
      );
    }

    return RefreshIndicator(
      onRefresh: () async {
        context.read<PlayerBloc>().add(PlayerFetchAllPlayers());
        await Future.delayed(const Duration(milliseconds: 300));
      },
      child: ListView.builder(
        key: PageStorageKey(storageKey),
        padding: const EdgeInsets.symmetric(vertical: 8),
        itemCount: list.length,
        itemBuilder: (context, index) {
          final player = list[index];
          final cardColor = index.isEven
              ? (isDarkMode ? AppColors.cardDark : AppColors.cardLight)
              : (isDarkMode ? AppColors.tertiary : AppColors.primary);
          return PlayerCard(player: player, color: cardColor);
        },
      ),
    );
  }
}
