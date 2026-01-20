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

  int _parseOrFallback(String? text, int fallback) {
    if (text == null || text.trim().isEmpty) return fallback;
    return int.tryParse(text.trim()) ?? fallback;
  }

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
            child: Text('Elimina', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );

    if (confirmed == true && mounted) {
      context.read<PlayerBloc>().add(PlayerDelete(playerId: widget.player.id));
    }
  }

  Widget _buildImagePicker() {
    if (_image != null) {
      return GestureDetector(
        onTap: _selectImage,
        child: ClipRRect(
          borderRadius: BorderRadius.circular(10),
          child: Image.file(
            _image!,
            fit: BoxFit.cover,
            height: 150,
            width: double.infinity,
          ),
        ),
      );
    }
    return GestureDetector(
      onTap: _selectImage,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(10),
        child: Image.network(
          widget.player.imageUrl,
          fit: BoxFit.cover,
          height: 150,
          width: double.infinity,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBarYesNav(
        title: const Text('Modifica giocatore'),
        actions: [
          IconButton(
            onPressed: _updatePlayer,
            icon: Icon(
              Icons.done_rounded,
              color: Theme.of(context).colorScheme.onPrimary,
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
                  _buildImagePicker(),
                  const SizedBox(height: 15),
                  TextFieldNullable(
                    controller: _fullNameController,
                    hintText: widget.player.fullName,
                  ),
                  const SizedBox(height: 15),
                  DropdownButtonFormField<PlayerRole>(
                    initialValue: _selectedRole,
                    items: PlayerRole.values
                        .map(
                          (r) => DropdownMenuItem(
                            value: r,
                            child: Text(
                              r.value,
                              style: Theme.of(context).textTheme.bodyMedium,
                            ),
                          ),
                        )
                        .toList(),
                    onChanged: (v) => setState(() => _selectedRole = v),
                    decoration: InputDecoration(
                      hintText: 'Ruolo',
                      filled: true,
                      fillColor: Theme.of(
                        context,
                      ).inputDecorationTheme.fillColor,
                      border: Theme.of(context).inputDecorationTheme.border,
                    ),
                    validator: (v) => v == null ? 'Seleziona un ruolo' : null,
                  ),
                  const SizedBox(height: 15),
                  TextFieldNullable(
                    controller: _userNameController,
                    hintText: widget.player.userName,
                  ),
                  const SizedBox(height: 15),
                  NumberFieldNullable(
                    controller: _attendancesController,
                    hintText: widget.player.attendances.toString(),
                  ),
                  const SizedBox(height: 15),
                  NumberFieldNullable(
                    controller: _goalsController,
                    hintText: widget.player.goals.toString(),
                  ),
                  const SizedBox(height: 15),
                  NumberFieldNullable(
                    controller: _yellowCardsController,
                    hintText: widget.player.yellowCards.toString(),
                  ),
                  const SizedBox(height: 15),
                  NumberFieldNullable(
                    controller: _redCardsController,
                    hintText: widget.player.redCards.toString(),
                  ),
                  const SizedBox(height: 15),
                  SegmentedButton<int>(
                    segments: const [
                      ButtonSegment(value: 0, label: Text('Attivo')),
                      ButtonSegment(value: 1, label: Text('Non attivo')),
                    ],
                    selected: _isActive ? {0} : {1},
                    onSelectionChanged: (newSelection) =>
                        setState(() => _isActive = newSelection.contains(0)),
                    multiSelectionEnabled: false,
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
