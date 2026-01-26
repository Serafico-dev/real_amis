import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:intl/intl.dart';
import 'package:real_amis/core/cubits/app_user/app_user_cubit.dart';
import 'package:real_amis/common/helpers/is_dark_mode.dart';
import 'package:real_amis/common/widgets/appBar/app_bar_yes_nav.dart';
import 'package:real_amis/common/widgets/loader/loader.dart';
import 'package:real_amis/core/configs/assets/app_vectors.dart';
import 'package:real_amis/core/configs/theme/app_colors.dart';
import 'package:real_amis/core/utils/show_snackbar.dart';
import 'package:real_amis/domain/entities/player/player_entity.dart';
import 'package:real_amis/domain/entities/player/player_role.dart';
import 'package:real_amis/presentation/player/bloc/player_bloc.dart';
import 'package:real_amis/presentation/player/pages/edit_player.dart';

class PlayerViewerPage extends StatelessWidget {
  static MaterialPageRoute route(String playerId, {Color? cardColor}) =>
      MaterialPageRoute(
        builder: (_) =>
            PlayerViewerPage(playerId: playerId, cardColor: cardColor),
      );

  final String playerId;
  final Color? cardColor;

  const PlayerViewerPage({super.key, required this.playerId, this.cardColor});

  PlayerEntity? _findCurrentPlayer(PlayerState state) {
    if (state is PlayerUpdateSuccess) return state.updatedPlayer;
    if (state is PlayerDisplaySuccess) {
      final players = state.players.where((p) => p.id == playerId);
      return players.isEmpty ? null : players.first;
    }
    return null;
  }

  Widget _statTile(BuildContext context, String value, Widget icon) => Column(
    children: [
      Text(
        value,
        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
          fontWeight: FontWeight.bold,
          fontSize: 16,
        ),
      ),
      const SizedBox(height: 4),
      icon,
    ],
  );

  @override
  Widget build(BuildContext context) {
    final isDark = context.isDarkMode;

    return Scaffold(
      appBar: AppBarYesNav(
        title: const Text('Dettaglio giocatore'),
        actions: [
          BlocSelector<AppUserCubit, AppUserState, bool?>(
            selector: (state) =>
                state is AppUserLoggedIn ? state.user.isAdmin : false,
            builder: (context, isAdmin) {
              if (isAdmin != true) return const SizedBox.shrink();
              return IconButton(
                onPressed: () async {
                  final bloc = context.read<PlayerBloc>();
                  final currentPlayer = _findCurrentPlayer(bloc.state);
                  if (currentPlayer == null) {
                    showSnackBar(context, 'Giocatore non trovato');
                    return;
                  }
                  await Navigator.push(
                    context,
                    EditPlayerPage.route(currentPlayer),
                  );
                  if (context.mounted) {
                    bloc.add(PlayerFetchAllPlayers());
                  }
                },
                icon: const Icon(Icons.edit, size: 25),
                tooltip: 'Modifica giocatore',
              );
            },
          ),
        ],
      ),

      body: BlocBuilder<PlayerBloc, PlayerState>(
        builder: (context, state) {
          if (state is PlayerLoading) return const Loader();

          final player = _findCurrentPlayer(state);
          if (player == null || state is PlayerDeleteSuccess) {
            return Center(child: Text('Giocatore non trovato.'));
          }

          final bgColor =
              cardColor?.withValues(alpha: 0.25) ??
              (isDark ? AppColors.cardDark : AppColors.cardLight);

          return Scrollbar(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: bgColor,
                  borderRadius: BorderRadius.circular(10),
                  boxShadow: [
                    BoxShadow(
                      color: Theme.of(context).shadowColor,
                      blurRadius: 4,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      player.role.value,
                      style: Theme.of(
                        context,
                      ).textTheme.bodySmall?.copyWith(fontSize: 16),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      player.fullName,
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text("'${player.userName}'"),
                    const SizedBox(height: 4),
                    if (player.birthday != null)
                      Text(
                        '🎂 ${DateFormat('dd/MM/yyyy').format(player.birthday!)}',
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: context.isDarkMode
                              ? AppColors.textDarkPrimary
                              : AppColors.textLightPrimary,
                        ),
                      ),

                    Center(
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(10),
                        child: CachedNetworkImage(
                          imageUrl: player.imageUrl,
                          cacheKey: player.id,
                          height: 200,
                          fit: BoxFit.cover,
                          placeholder: (context, url) => Container(
                            height: 200,
                            color: isDark
                                ? AppColors.cardDark
                                : AppColors.cardLight,
                            child: const Center(
                              child: CircularProgressIndicator(),
                            ),
                          ),
                          errorWidget: (context, url, error) => Container(
                            height: 200,
                            color: isDark
                                ? AppColors.cardDark
                                : AppColors.cardLight,
                            child: const Center(
                              child: Icon(Icons.broken_image, size: 40),
                            ),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 30),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        _statTile(
                          context,
                          player.attendances.toString(),
                          const Icon(Icons.stadium, size: 28),
                        ),
                        const SizedBox(width: 30),
                        _statTile(
                          context,
                          player.goals.toString(),
                          const Icon(Icons.sports_soccer, size: 28),
                        ),
                        const SizedBox(width: 30),
                        _statTile(
                          context,
                          player.yellowCards.toString(),
                          SvgPicture.asset(AppVectors.yellowCard, width: 28),
                        ),
                        const SizedBox(width: 30),
                        _statTile(
                          context,
                          player.redCards.toString(),
                          SvgPicture.asset(AppVectors.redCard, width: 28),
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
