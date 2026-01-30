import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:real_amis/common/helpers/is_dark_mode.dart';
import 'package:real_amis/common/widgets/appBar/app_bar_no_nav.dart';
import 'package:real_amis/common/widgets/loader/loader.dart';
import 'package:real_amis/core/configs/theme/app_colors.dart';
import 'package:real_amis/core/utils/admin_only.dart';
import 'package:real_amis/core/utils/show_snackbar.dart';
import 'package:real_amis/domain/entities/player/player_entity.dart';
import 'package:real_amis/domain/entities/player/player_role.dart';
import 'package:real_amis/presentation/auth/providers/app_user_provider.dart';
import 'package:real_amis/presentation/player/pages/add_new_player.dart';
import 'package:real_amis/presentation/player/widgets/player_card.dart';
import 'package:real_amis/presentation/player/providers/player_notifier.dart';
import 'package:real_amis/presentation/auth/providers/app_user_notifier.dart';

class PlayersPage extends ConsumerStatefulWidget {
  const PlayersPage({super.key});

  static MaterialPageRoute route() =>
      MaterialPageRoute(builder: (_) => const PlayersPage());

  @override
  ConsumerState<PlayersPage> createState() => _PlayersPageState();
}

class _PlayersPageState extends ConsumerState<PlayersPage>
    with SingleTickerProviderStateMixin {
  final TextEditingController _searchController = TextEditingController();
  late final TabController _tabController;
  final PageStorageBucket _bucket = PageStorageBucket();
  String _query = '';

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
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(playerNotifierProvider.notifier).fetchAllPlayers();
    });
    _searchController.addListener(() {
      setState(() => _query = _searchController.text.trim());
    });
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

  Color _getCardColor(int index, bool isDarkMode) => index.isEven
      ? (isDarkMode ? AppColors.cardDark : AppColors.cardLight)
      : (isDarkMode ? AppColors.tertiary : AppColors.primary);

  @override
  Widget build(BuildContext context) {
    final isDarkMode = context.isDarkMode;
    final userAsync = ref.watch(appUserProvider);

    return userAsync.when(
      loading: () =>
          const Scaffold(body: Center(child: CircularProgressIndicator())),
      error: (_, _) =>
          const Scaffold(body: Center(child: Text('Errore utente'))),
      data: (userState) {
        final user = userState.user;
        if (user == null) {
          return const Scaffold(
            body: Center(child: Text('Utente non loggato')),
          );
        }

        final playerState = ref.watch(playerNotifierProvider);

        return Scaffold(
          appBar: AppBarNoNav(
            actions: [
              AdminOnly(
                child: IconButton(
                  onPressed: () async {
                    await Navigator.push(context, AddNewPlayerPage.route());
                    if (!mounted) return;
                    ref.read(playerNotifierProvider.notifier).fetchAllPlayers();
                  },
                  icon: Icon(
                    Icons.add,
                    size: 30,
                    color: isDarkMode
                        ? AppColors.textDarkPrimary
                        : AppColors.textLightPrimary,
                  ),
                  tooltip: 'Aggiungi giocatore',
                ),
              ),
            ],
          ),
          body: playerState.when(
            data: (players) {
              final filteredPlayers = _filterPlayers(players, _query);
              final giocatori = filteredPlayers
                  .where((p) => _isPlayerRole(p.role))
                  .toList();
              final leggende = filteredPlayers
                  .where((p) => p.role == PlayerRole.leggenda)
                  .toList();
              final staff = filteredPlayers
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
                      padding: const EdgeInsets.all(8.0),
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
            },
            loading: () => const Loader(),
            error: (err, _) {
              WidgetsBinding.instance.addPostFrameCallback(
                (_) => showSnackBar(context, err.toString()),
              );
              return const SizedBox.shrink();
            },
          ),
        );
      },
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
        await ref.read(playerNotifierProvider.notifier).fetchAllPlayers();
        await Future.delayed(const Duration(milliseconds: 300));
      },
      child: ListView.builder(
        key: PageStorageKey(storageKey),
        padding: const EdgeInsets.symmetric(vertical: 8),
        itemCount: list.length,
        itemBuilder: (context, index) {
          final player = list[index];
          return PlayerCard(
            player: player,
            color: _getCardColor(index, isDarkMode),
          );
        },
      ),
    );
  }
}
