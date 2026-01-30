import 'dart:io';

import 'package:dotted_border/dotted_border.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:real_amis/common/helpers/is_dark_mode.dart';
import 'package:real_amis/common/widgets/appBar/app_bar_yes_nav.dart';
import 'package:real_amis/common/widgets/loader/loader.dart';
import 'package:real_amis/common/widgets/textFields/text_field_required.dart';
import 'package:real_amis/core/configs/theme/app_colors.dart';
import 'package:real_amis/core/utils/pick_image.dart';
import 'package:real_amis/core/utils/show_snackbar.dart';
import 'package:real_amis/presentation/team/providers/team_notifier.dart';

class AddNewTeamPage extends ConsumerStatefulWidget {
  static MaterialPageRoute route() =>
      MaterialPageRoute(builder: (_) => const AddNewTeamPage());

  const AddNewTeamPage({super.key});

  @override
  ConsumerState<AddNewTeamPage> createState() => _AddNewTeamPageState();
}

class _AddNewTeamPageState extends ConsumerState<AddNewTeamPage> {
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

  Future<void> _uploadTeam() async {
    if (!(_formKey.currentState?.validate() ?? false)) return;
    if (_image == null) {
      showSnackBar(context, "Seleziona un'immagine");
      return;
    }

    final notifier = ref.read(teamNotifierProvider.notifier);
    await notifier.uploadTeam(
      name: _nameController.text.trim(),
      image: _image!,
    );

    final state = ref.read(teamNotifierProvider);
    if (state is AsyncData && mounted) {
      Navigator.pop(context);
    } else if (state is AsyncError && mounted) {
      showSnackBar(context, state.error.toString());
    }
  }

  Widget _buildImagePicker(BuildContext context) {
    final isDark = context.isDarkMode;
    final borderColor = isDark ? AppColors.tertiary : AppColors.secondary;
    final iconColor = isDark
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
    final isDark = context.isDarkMode;
    final teamState = ref.watch(teamNotifierProvider);

    return Scaffold(
      appBar: AppBarYesNav(
        title: const Text('Aggiungi una squadra'),
        actions: [
          IconButton(
            onPressed: _uploadTeam,
            icon: Icon(
              Icons.done_rounded,
              size: 25,
              color: isDark ? AppColors.iconDark : AppColors.iconLight,
            ),
            tooltip: 'Salva',
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              _buildImagePicker(context),
              const SizedBox(height: 20),
              TextFieldRequired(
                controller: _nameController,
                labelText: 'Nome squadra',
                hintText: 'Inserisci il nome',
              ),
              if (teamState is AsyncLoading)
                const Padding(
                  padding: EdgeInsets.only(top: 20),
                  child: Loader(),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
