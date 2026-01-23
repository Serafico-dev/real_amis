import 'dart:io';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:real_amis/common/helpers/is_dark_mode.dart';
import 'package:real_amis/common/widgets/appBar/app_bar_yes_nav.dart';
import 'package:real_amis/common/widgets/button/basic_app_button.dart';
import 'package:real_amis/common/widgets/loader/loader.dart';
import 'package:real_amis/core/configs/theme/app_colors.dart';
import 'package:real_amis/core/utils/pick_image.dart';
import 'package:real_amis/core/utils/show_snackbar.dart';
import 'package:real_amis/domain/entities/team/team_entity.dart';
import 'package:real_amis/presentation/team/bloc/team_bloc.dart';

class EditTeamPage extends StatefulWidget {
  static MaterialPageRoute route(TeamEntity team) =>
      MaterialPageRoute(builder: (context) => EditTeamPage(team: team));

  final TeamEntity team;
  const EditTeamPage({super.key, required this.team});

  @override
  State<EditTeamPage> createState() => _EditTeamPageState();
}

class _EditTeamPageState extends State<EditTeamPage> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _nameController;
  File? _image;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.team.name);
  }

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  Future<void> _selectImage() async {
    final picked = await pickImage();
    if (picked != null) setState(() => _image = picked);
  }

  void _onSave() {
    if (!(_formKey.currentState?.validate() ?? false)) return;

    final updatedName = _nameController.text.trim();

    context.read<TeamBloc>().add(
      TeamUpdate(
        team: widget.team,
        name: updatedName.isNotEmpty ? updatedName : widget.team.name,
        image: _image,
      ),
    );
  }

  Future<void> _confirmAndDelete() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Conferma eliminazione'),
        content: const Text(
          'Sei sicuro di voler eliminare questa squadra? Questa azione non è reversibile.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Annulla'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Elimina', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );

    if (confirmed == true && mounted) {
      context.read<TeamBloc>().add(TeamDelete(teamId: widget.team.id));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBarYesNav(
        title: const Text('Modifica squadra'),
        actions: [
          IconButton(
            onPressed: _onSave,
            icon: const Icon(Icons.done_rounded, size: 25),
            tooltip: 'Salva',
            color: context.isDarkMode
                ? AppColors.iconDark
                : AppColors.iconLight,
          ),
        ],
      ),
      body: BlocConsumer<TeamBloc, TeamState>(
        listener: (context, state) {
          if (state is TeamFailure) {
            showSnackBar(context, state.error);
          } else if (state is TeamUpdateSuccess) {
            Navigator.pop(context, state.updatedTeam);
          } else if (state is TeamDeleteSuccess) {
            Navigator.pop(context);
          }
        },

        builder: (context, state) {
          final isLoading = state is TeamLoading;

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
                          ? Image.file(_image!, height: 200, fit: BoxFit.cover)
                          : CachedNetworkImage(
                              imageUrl: widget.team.imageUrl,
                              height: 200,
                              fit: BoxFit.cover,
                              placeholder: (_, _) =>
                                  const SizedBox(height: 200, child: Loader()),
                              errorWidget: (_, _, _) => Container(
                                height: 200,
                                color: context.isDarkMode
                                    ? AppColors.cardDark
                                    : AppColors.cardLight,
                                child: Icon(
                                  Icons.broken_image,
                                  size: 64,
                                  color: context.isDarkMode
                                      ? AppColors.textDarkSecondary
                                      : AppColors.textLightSecondary,
                                ),
                              ),
                            ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  TextButton.icon(
                    onPressed: _selectImage,
                    icon: Icon(
                      Icons.add_a_photo_outlined,
                      color: context.isDarkMode
                          ? AppColors.textDarkPrimary
                          : AppColors.textLightPrimary,
                    ),
                    label: Text(
                      'Modifica logo',
                      style: TextStyle(
                        color: context.isDarkMode
                            ? AppColors.textDarkPrimary
                            : AppColors.textLightPrimary,
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  TextFormField(
                    controller: _nameController,
                    decoration: InputDecoration(
                      hintText: 'Nome squadra',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                      filled: true,
                    ),
                    validator: (v) {
                      if (v == null || v.trim().isEmpty) {
                        return 'Inserisci il nome della squadra';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 20),
                  BasicAppButton(
                    title: isLoading ? 'Elaborazione...' : 'Elimina squadra',
                    onPressed: isLoading ? null : _confirmAndDelete,
                  ),
                  if (isLoading)
                    const Padding(
                      padding: EdgeInsets.only(top: 20),
                      child: Loader(),
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
