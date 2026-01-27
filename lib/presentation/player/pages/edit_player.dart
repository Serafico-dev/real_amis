import 'dart:io';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_datetime_picker_plus/flutter_datetime_picker_plus.dart';
import 'package:intl/intl.dart';
import 'package:real_amis/common/helpers/is_dark_mode.dart';
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
      MaterialPageRoute(builder: (_) => EditPlayerPage(player: player));

  final PlayerEntity player;
  const EditPlayerPage({super.key, required this.player});

  @override
  State<EditPlayerPage> createState() => _EditPlayerPageState();
}

class _EditPlayerPageState extends State<EditPlayerPage> {
  final _formKey = GlobalKey<FormState>();

  late final TextEditingController _userNameController;
  late final TextEditingController _fullNameController;
  late final TextEditingController _attendancesController;
  late final TextEditingController _goalsController;
  late final TextEditingController _yellowCardsController;
  late final TextEditingController _redCardsController;

  late DateTime? _birthday;
  PlayerRole? _selectedRole;
  File? _image;
  bool _isActive = true;

  @override
  void initState() {
    super.initState();
    _userNameController = TextEditingController(text: widget.player.userName);
    _fullNameController = TextEditingController(text: widget.player.fullName);
    _attendancesController = TextEditingController(
      text: widget.player.attendances.toString(),
    );
    _goalsController = TextEditingController(
      text: widget.player.goals.toString(),
    );
    _yellowCardsController = TextEditingController(
      text: widget.player.yellowCards.toString(),
    );
    _redCardsController = TextEditingController(
      text: widget.player.redCards.toString(),
    );

    _selectedRole = widget.player.role;
    _isActive = widget.player.active;
    _birthday = widget.player.birthday;
  }

  @override
  void dispose() {
    _userNameController.dispose();
    _fullNameController.dispose();
    _attendancesController.dispose();
    _goalsController.dispose();
    _yellowCardsController.dispose();
    _redCardsController.dispose();
    super.dispose();
  }

  int _parseOrFallback(String? text, int fallback) =>
      int.tryParse(text?.trim() ?? '') ?? fallback;

  Future<void> _selectImage() async {
    final picked = await pickImage();
    if (picked != null) setState(() => _image = picked);
  }

  void _updatePlayer() {
    context.read<PlayerBloc>().add(
      PlayerUpdate(
        player: widget.player,
        userName: _userNameController.text.trim().isNotEmpty
            ? _userNameController.text.trim()
            : widget.player.userName,
        fullName: _fullNameController.text.trim().isNotEmpty
            ? _fullNameController.text.trim()
            : widget.player.fullName,
        image: _image,
        role: _selectedRole ?? widget.player.role,
        attendances: _parseOrFallback(
          _attendancesController.text,
          widget.player.attendances!,
        ),
        goals: _parseOrFallback(_goalsController.text, widget.player.goals!),
        yellowCards: _parseOrFallback(
          _yellowCardsController.text,
          widget.player.yellowCards!,
        ),
        redCards: _parseOrFallback(
          _redCardsController.text,
          widget.player.redCards!,
        ),
        active: _isActive,
        birthday: _birthday,
      ),
    );
  }

  Future<void> _confirmAndDelete() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Conferma eliminazione'),
        content: const Text('Sei sicuro di voler eliminare questo giocatore?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text(
              'Annulla',
              style: TextStyle(color: AppColors.textDarkSecondary),
            ),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Elimina', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );

    if (confirmed == true && mounted) {
      context.read<PlayerBloc>().add(PlayerDelete(playerId: widget.player.id));
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = context.isDarkMode;

    return Scaffold(
      appBar: AppBarYesNav(
        title: const Text('Modifica giocatore'),
        actions: [
          IconButton(
            onPressed: _updatePlayer,
            icon: Icon(
              Icons.done_rounded,
              color: isDark ? AppColors.iconDark : AppColors.iconLight,
              size: 25,
            ),
            tooltip: 'Salva',
          ),
        ],
      ),
      body: BlocConsumer<PlayerBloc, PlayerState>(
        listener: (context, state) {
          if (state is PlayerFailure) showSnackBar(context, state.error);
          if (state is PlayerUpdateSuccess) {
            Navigator.pop(context, state.updatedPlayer);
          }
          if (state is PlayerDeleteSuccess) Navigator.pop(context, true);
        },
        builder: (context, state) {
          if (state is PlayerLoading) return const Loader();

          return SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Form(
              key: _formKey,
              child: Column(
                children: [
                  GestureDetector(
                    onTap: _selectImage,
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(10),
                      child: _image != null
                          ? Image.file(_image!, height: 150, fit: BoxFit.cover)
                          : CachedNetworkImage(
                              imageUrl: widget.player.imageUrl,
                              cacheKey: widget.player.id,
                              height: 150,
                              fit: BoxFit.cover,
                              placeholder: (_, _) => const Loader(),
                              errorWidget: (_, _, _) => Container(
                                height: 150,
                                color: isDark
                                    ? AppColors.cardDark
                                    : AppColors.cardLight,
                                child: Icon(
                                  Icons.broken_image,
                                  size: 64,
                                  color: isDark
                                      ? AppColors.textDarkSecondary
                                      : AppColors.textLightSecondary,
                                ),
                              ),
                            ),
                    ),
                  ),
                  const SizedBox(height: 10),
                  TextButton.icon(
                    onPressed: _selectImage,
                    icon: Icon(
                      Icons.add_a_photo_outlined,
                      color: isDark
                          ? AppColors.textDarkPrimary
                          : AppColors.textLightPrimary,
                    ),
                    label: Text(
                      'Modifica foto',
                      style: TextStyle(
                        color: isDark
                            ? AppColors.textDarkPrimary
                            : AppColors.textLightPrimary,
                      ),
                    ),
                  ),

                  TextFieldNullable(
                    controller: _fullNameController,
                    labelText: 'Nome e Cognome',
                    hintText: widget.player.fullName,
                  ),
                  const SizedBox(height: 10),

                  DropdownButtonFormField<PlayerRole>(
                    initialValue: _selectedRole,
                    items: PlayerRole.values
                        .map(
                          (r) =>
                              DropdownMenuItem(value: r, child: Text(r.value)),
                        )
                        .toList(),
                    onChanged: (v) => setState(() => _selectedRole = v),
                    decoration: const InputDecoration(
                      labelText: 'Ruolo',
                      border: OutlineInputBorder(),
                    ),
                    validator: (v) => v == null ? 'Seleziona un ruolo' : null,
                  ),
                  const SizedBox(height: 10),

                  TextFieldNullable(
                    controller: _userNameController,
                    labelText: 'Soprannome',
                    hintText: widget.player.userName,
                  ),
                  const SizedBox(height: 10),

                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        _birthday == null
                            ? 'Data di nascita non selezionata'
                            : 'Data di nascita: ${DateFormat('dd/MM/yyyy').format(_birthday!)}',
                        style: TextStyle(
                          color: isDark
                              ? AppColors.textDarkPrimary
                              : AppColors.textLightPrimary,
                        ),
                      ),
                      ElevatedButton.icon(
                        onPressed: () async {
                          final picked = await DatePicker.showDatePicker(
                            context,
                            showTitleActions: true,
                            minTime: DateTime(1950),
                            maxTime: DateTime.now(),
                            currentTime: _birthday ?? DateTime(2000),
                            locale: LocaleType.it,
                          );
                          if (picked != null) {
                            setState(() => _birthday = picked);
                          }
                        },
                        icon: const Icon(Icons.cake, color: Colors.white),
                        label: const Text('Seleziona'),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),

                  NumberFieldNullable(
                    controller: _attendancesController,
                    labelText: 'Presenze',
                    hintText: '${widget.player.attendances}',
                  ),
                  const SizedBox(height: 10),
                  NumberFieldNullable(
                    controller: _goalsController,
                    labelText: 'Goal',
                    hintText: '${widget.player.goals}',
                  ),
                  const SizedBox(height: 10),
                  NumberFieldNullable(
                    controller: _yellowCardsController,
                    labelText: 'Cartellini gialli',
                    hintText: '${widget.player.yellowCards}',
                  ),
                  const SizedBox(height: 10),
                  NumberFieldNullable(
                    controller: _redCardsController,
                    labelText: 'Cartellini rossi',
                    hintText: '${widget.player.redCards}',
                  ),
                  const SizedBox(height: 10),

                  SegmentedButton<int>(
                    segments: const [
                      ButtonSegment(value: 0, label: Text('Attivo')),
                      ButtonSegment(value: 1, label: Text('Non attivo')),
                    ],
                    selected: _isActive ? {0} : {1},
                    onSelectionChanged: (newSelection) =>
                        setState(() => _isActive = newSelection.contains(0)),
                  ),
                  const SizedBox(height: 15),

                  BasicAppButton(
                    onPressed: state is PlayerLoading
                        ? null
                        : _confirmAndDelete,
                    title: state is PlayerLoading
                        ? 'Eliminazione in corso...'
                        : 'Elimina giocatore',
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
