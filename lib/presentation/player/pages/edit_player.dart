import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:real_amis/common/widgets/appBar/app_bar_yes_nav.dart';
import 'package:real_amis/common/widgets/button/basic_app_button.dart';
import 'package:real_amis/common/widgets/loader/loader.dart';
import 'package:real_amis/common/widgets/textFields/number_field_nullable.dart';
import 'package:real_amis/common/widgets/textFields/text_field_nullable.dart';
import 'package:real_amis/core/configs/theme/app_colors.dart';
import 'package:real_amis/core/utils/pick_image.dart';
import 'package:real_amis/core/utils/show_snackbar.dart';
import 'package:real_amis/domain/entities/player/player_entity.dart';
import 'package:real_amis/domain/entities/player/player_role.dart';
import 'package:real_amis/presentation/player/bloc/player_bloc.dart';

class EditPlayerPage extends StatefulWidget {
  static MaterialPageRoute route(PlayerEntity player) =>
      MaterialPageRoute(builder: (context) => EditPlayerPage(player: player));
  final PlayerEntity player;
  const EditPlayerPage({super.key, required this.player});

  @override
  State<EditPlayerPage> createState() => _EditPlayerState();
}

class _EditPlayerState extends State<EditPlayerPage> {
  final userNameController = TextEditingController();
  final fullNameController = TextEditingController();
  PlayerRole? _selectedRole = PlayerRole.nessuno;
  final attendancesController = TextEditingController();
  final goalsController = TextEditingController();
  final yellowCardsController = TextEditingController();
  final redCardsController = TextEditingController();
  final formKey = GlobalKey<FormState>();
  File? image;
  Set<int> _selected = {0};
  bool get isActive => _selected.contains(0);

  void selectImage() async {
    final pickedImage = await pickImage();
    if (pickedImage != null) {
      setState(() {
        image = pickedImage;
      });
    }
  }

  void updatePlayer() async {
    context.read<PlayerBloc>().add(
      PlayerUpdate(
        player: widget.player,
        userName: userNameController.text.trim().isNotEmpty
            ? userNameController.text.trim()
            : widget.player.userName,
        fullName: fullNameController.text.trim().isNotEmpty
            ? fullNameController.text.trim()
            : widget.player.fullName,
        image: image,
        role: _selectedRole ?? widget.player.role,
        attendances: attendancesController.text.trim().isNotEmpty
            ? int.parse(attendancesController.text.trim())
            : widget.player.attendances,
        goals: goalsController.text.trim().isNotEmpty
            ? int.parse(goalsController.text.trim())
            : widget.player.goals,
        yellowCards: yellowCardsController.text.trim().isNotEmpty
            ? int.parse(yellowCardsController.text.trim())
            : widget.player.yellowCards,
        redCards: redCardsController.text.trim().isNotEmpty
            ? int.parse(redCardsController.text.trim())
            : widget.player.redCards,
        active: isActive,
      ),
    );
  }

  @override
  void dispose() {
    super.dispose();
    userNameController.dispose();
    fullNameController.dispose();
    attendancesController.dispose();
    goalsController.dispose();
    yellowCardsController.dispose();
    redCardsController.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBarYesNav(
        title: Text('Modifica giocatore'),
        actions: [
          IconButton(
            onPressed: () {
              updatePlayer();
            },
            icon: Icon(Icons.done_rounded, size: 25),
          ),
        ],
      ),
      body: BlocConsumer<PlayerBloc, PlayerState>(
        listener: (context, state) {
          if (state is PlayerFailure) {
            showSnackBar(context, state.error);
          } else if (state is PlayerUpdateSuccess) {
            Navigator.pop(context, state.updatedPlayer);
          } else if (state is PlayerDeleteSuccess) {
            Navigator.pop(context, true);
          }
        },
        builder: (context, state) {
          if (state is PlayerLoading) {
            return Loader();
          }

          return SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Form(
                key: formKey,
                child: Column(
                  children: [
                    ClipRRect(
                      borderRadius: BorderRadius.circular(10),
                      child: Image.network(
                        widget.player.imageUrl,
                        fit: BoxFit.cover,
                      ),
                    ),
                    SizedBox(height: 15),
                    IconButton(
                      onPressed: () => selectImage(),
                      tooltip: 'Modifica foto',
                      icon: Icon(
                        Icons.add_a_photo_outlined,
                        color: AppColors.primary,
                        size: 50,
                      ),
                    ),
                    SizedBox(height: 15),
                    TextFieldNullable(
                      controller: fullNameController,
                      hintText: '${widget.player.fullName} (Nome e Cognome)',
                    ),
                    SizedBox(height: 15),
                    DropdownButtonFormField<PlayerRole>(
                      initialValue: widget.player.role,
                      items: PlayerRole.values
                          .map(
                            (r) => DropdownMenuItem(
                              value: r,
                              child: Text(r.value),
                            ),
                          )
                          .toList(),
                      onChanged: (v) => setState(() => _selectedRole = v),
                      decoration: InputDecoration(
                        hintText: '${widget.player.role} (Ruolo)',
                      ),
                      validator: (v) => v == null ? 'Seleziona un ruolo' : null,
                    ),
                    SizedBox(height: 15),
                    TextFieldNullable(
                      controller: userNameController,
                      hintText: '${widget.player.userName} (Soprannome)',
                    ),
                    SizedBox(height: 15),
                    NumberFieldNullable(
                      controller: attendancesController,
                      hintText:
                          '${widget.player.attendances.toString()} (Presenze)',
                    ),
                    SizedBox(height: 15),
                    NumberFieldNullable(
                      controller: goalsController,
                      hintText: '${widget.player.goals.toString()} (Goal)',
                    ),
                    SizedBox(height: 15),
                    NumberFieldNullable(
                      controller: yellowCardsController,
                      hintText:
                          '${widget.player.yellowCards.toString()} (Cartellini gialli)',
                    ),
                    SizedBox(height: 15),
                    NumberFieldNullable(
                      controller: redCardsController,
                      hintText:
                          '${widget.player.redCards.toString()} (Cartellini rossi)',
                    ),
                    SizedBox(height: 15),
                    SegmentedButton<int>(
                      segments: <ButtonSegment<int>>[
                        ButtonSegment(value: 0, label: Text('Attivo')),
                        ButtonSegment(value: 1, label: Text('Non attivo')),
                      ],
                      selected: _selected,
                      onSelectionChanged: (newSelection) {
                        setState(() {
                          _selected = newSelection;
                        });
                      },
                      multiSelectionEnabled: false,
                    ),
                    SizedBox(height: 15),
                    BlocBuilder<PlayerBloc, PlayerState>(
                      builder: (context, state) {
                        final isLoading = state is PlayerLoading;
                        return BasicAppButton(
                          onPressed: isLoading
                              ? null
                              : () async {
                                  final confirmed = await showDialog<bool>(
                                    context: context,
                                    builder: (context) => AlertDialog(
                                      title: Text('Conferma eliminazione'),
                                      content: Text(
                                        'Sei sicuro di voler eliminare questo giocatore?',
                                      ),
                                      actions: [
                                        TextButton(
                                          onPressed: () =>
                                              Navigator.of(context).pop(false),
                                          child: Text('Annulla'),
                                        ),
                                        TextButton(
                                          onPressed: () =>
                                              Navigator.of(context).pop(true),
                                          child: Text(
                                            'Elimina',
                                            style: TextStyle(color: Colors.red),
                                          ),
                                        ),
                                      ],
                                    ),
                                  );
                                  if (confirmed == true && context.mounted) {
                                    context.read<PlayerBloc>().add(
                                      PlayerDelete(playerId: widget.player.id),
                                    );
                                  }
                                },
                          title: isLoading
                              ? 'Eliminazione in corso...'
                              : 'Elimina giocatore',
                        );
                      },
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
