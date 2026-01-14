import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:real_amis/common/cubits/app_user/app_user_cubit.dart';
import 'package:real_amis/common/widgets/appBar/app_bar_yes_nav.dart';
import 'package:real_amis/common/widgets/loader/loader.dart';
import 'package:real_amis/core/configs/assets/app_vectors.dart';
import 'package:real_amis/core/configs/theme/app_colors.dart';
import 'package:real_amis/core/utils/show_snackbar.dart';
import 'package:real_amis/domain/entities/player/player_entity.dart';
import 'package:real_amis/domain/entities/player/player_role.dart';
import 'package:real_amis/presentation/player/pages/edit_player.dart';
import 'package:real_amis/presentation/player/bloc/player_bloc.dart';

class PlayerViewerPage extends StatelessWidget {
  static MaterialPageRoute route(String playerId) => MaterialPageRoute(
    builder: (context) => PlayerViewerPage(playerId: playerId),
  );
  final String playerId;
  const PlayerViewerPage({super.key, required this.playerId});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBarYesNav(
        title: Text('Dettaglio giocatore'),
        actions: [
          BlocSelector<AppUserCubit, AppUserState, bool?>(
            selector: (state) =>
                state is AppUserLoggedIn ? state.user.isAdmin : false,
            builder: (context, isAdmin) {
              if (isAdmin != true) return SizedBox.shrink();
              return IconButton(
                onPressed: () async {
                  final bloc = context.read<PlayerBloc>();
                  final currentState = bloc.state;
                  PlayerEntity? currentPlayer;
                  if (currentState is PlayerDisplaySuccess) {
                    final players = currentState.players.where(
                      (p) => p.id == playerId,
                    );
                    if (players.isEmpty) {
                      currentPlayer = null;
                    } else {
                      currentPlayer = players.first;
                    }
                  }
                  if (currentState is PlayerUpdateSuccess) {
                    currentPlayer = currentState.updatedPlayer;
                  }
                  final playerToEdit = currentPlayer;
                  if (playerToEdit == null) {
                    showSnackBar(context, 'Giocatore non trovato');
                    return;
                  }
                  await Navigator.push(
                    context,
                    EditPlayerPage.route(playerToEdit),
                  );
                },
                icon: Icon(Icons.edit, size: 25),
              );
            },
          ),
        ],
      ),
      body: BlocBuilder<PlayerBloc, PlayerState>(
        builder: (context, state) {
          if (state is PlayerLoading) {
            return Loader();
          }
          PlayerEntity? player;
          if (state is PlayerDisplaySuccess) {
            final players = state.players.where((p) => p.id == playerId);
            if (players.isEmpty) {
              player = null;
            } else {
              player = players.first;
            }
          }
          if (state is PlayerUpdateSuccess) {
            player = state.updatedPlayer;
          }
          if (player == null || state is PlayerDeleteSuccess) {
            return Center(child: Text('Giocatore non trovato.'));
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
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(player.role.value, style: TextStyle(fontSize: 16)),
                    Text(
                      player.fullName,
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text("'${player.userName}'"),
                    ClipRRect(
                      borderRadius: BorderRadiusGeometry.circular(10),
                      child: CachedNetworkImage(
                        imageUrl: player.imageUrl,

                        fit: BoxFit.cover,
                      ),
                    ),
                    SizedBox(height: 30),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          player.attendances.toString(),
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                        SizedBox(width: 5),
                        Icon(Icons.stadium, size: 40),
                        SizedBox(width: 30),
                        Text(
                          player.goals.toString(),
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                        SizedBox(width: 5),
                        Icon(Icons.sports_soccer, size: 40),
                        SizedBox(width: 30),
                        Text(
                          player.yellowCards.toString(),
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                        SizedBox(width: 5),
                        SvgPicture.asset(AppVectors.yellowCard, width: 30),
                        SizedBox(width: 30),
                        Text(
                          player.redCards.toString(),
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                        SizedBox(width: 5),
                        SvgPicture.asset(AppVectors.redCard, width: 30),
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
