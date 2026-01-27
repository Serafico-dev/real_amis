import 'dart:io';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:real_amis/common/helpers/is_dark_mode.dart';
import 'package:real_amis/common/widgets/appBar/app_bar_yes_nav.dart';
import 'package:real_amis/common/widgets/loader/loader.dart';
import 'package:real_amis/common/widgets/textFields/text_field_required.dart';
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

    context.read<TeamBloc>().add(
      TeamUpdate(
        team: widget.team,
        name: _nameController.text.trim().isNotEmpty
            ? _nameController.text.trim()
            : widget.team.name,
        image: _image,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = context.isDarkMode;

    return Scaffold(
      appBar: AppBarYesNav(
        title: const Text('Modifica squadra'),
        actions: [
          IconButton(
            onPressed: _onSave,
            icon: Icon(
              Icons.done_rounded,
              size: 25,
              color: isDark ? AppColors.iconDark : AppColors.iconLight,
            ),
            tooltip: 'Salva',
          ),
        ],
      ),
      body: BlocConsumer<TeamBloc, TeamState>(
        listener: (context, state) {
          if (state is TeamFailure) showSnackBar(context, state.error);
          if (state is TeamUpdateSuccess) {
            Navigator.pop(context, state.updatedTeam);
          }
          if (state is TeamDeleteSuccess) Navigator.pop(context);
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
                          ? Image.file(_image!, height: 150, fit: BoxFit.cover)
                          : CachedNetworkImage(
                              imageUrl: widget.team.imageUrl,
                              cacheKey: widget.team.id,
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
                  const SizedBox(height: 12),
                  TextButton.icon(
                    onPressed: _selectImage,
                    icon: Icon(
                      Icons.add_a_photo_outlined,
                      color: isDark
                          ? AppColors.textDarkPrimary
                          : AppColors.textLightPrimary,
                    ),
                    label: Text(
                      'Modifica logo',
                      style: TextStyle(
                        color: isDark
                            ? AppColors.textDarkPrimary
                            : AppColors.textLightPrimary,
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  TextFieldRequired(
                    controller: _nameController,
                    labelText: 'Nome squadra',
                    hintText: 'Inserisci il nome',
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
