import 'dart:io';

import 'package:dotted_border/dotted_border.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:real_amis/common/helpers/is_dark_mode.dart';
import 'package:real_amis/common/widgets/appBar/app_bar_yes_nav.dart';
import 'package:real_amis/common/widgets/loader/loader.dart';
import 'package:real_amis/common/widgets/textFields/text_field_required.dart';
import 'package:real_amis/core/configs/theme/app_colors.dart';
import 'package:real_amis/core/utils/pick_image.dart';
import 'package:real_amis/core/utils/show_snackbar.dart';
import 'package:real_amis/presentation/team/bloc/team_bloc.dart';

class AddNewTeamPage extends StatefulWidget {
  static MaterialPageRoute route() =>
      MaterialPageRoute(builder: (_) => const AddNewTeamPage());

  const AddNewTeamPage({super.key});

  @override
  State<AddNewTeamPage> createState() => _AddNewTeamPageState();
}

class _AddNewTeamPageState extends State<AddNewTeamPage> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  File? _image;

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  Future<void> _selectImage() async {
    final picked = await pickImage();
    if (picked != null) setState(() => _image = picked);
  }

  void _uploadTeam() {
    if (!(_formKey.currentState?.validate() ?? false)) return;
    if (_image == null) {
      showSnackBar(context, "Seleziona un'immagine");
      return;
    }

    context.read<TeamBloc>().add(
      TeamUpload(name: _nameController.text.trim(), image: _image!),
    );
  }

  Widget _buildImagePicker(BuildContext context) {
    final isDarkMode = context.isDarkMode;
    final borderColor = isDarkMode ? AppColors.tertiary : AppColors.secondary;
    final iconColor = isDarkMode
        ? AppColors.textDarkPrimary
        : AppColors.textLightPrimary;

    if (_image != null) {
      return GestureDetector(
        onTap: _selectImage,
        child: ClipRRect(
          borderRadius: BorderRadius.circular(10),
          child: Image.file(
            _image!,
            width: double.infinity,
            height: 150,
            fit: BoxFit.cover,
          ),
        ),
      );
    }

    return GestureDetector(
      onTap: _selectImage,
      child: DottedBorder(
        options: RoundedRectDottedBorderOptions(
          radius: const Radius.circular(10),
          color: borderColor,
          dashPattern: const [20, 4],
          strokeCap: StrokeCap.round,
        ),
        child: SizedBox(
          height: 150,
          width: double.infinity,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.folder_open, size: 50, color: iconColor),
              const SizedBox(height: 15),
              Text(
                'Seleziona un logo',
                style: TextStyle(fontSize: 15, color: iconColor),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBarYesNav(
        title: const Text('Aggiungi una squadra'),
        actions: [
          IconButton(
            onPressed: _uploadTeam,
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
          } else if (state is TeamUploadSuccess) {
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
                  _buildImagePicker(context),
                  const SizedBox(height: 30),
                  TextFieldRequired(
                    controller: _nameController,
                    hintText: 'Nome',
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
