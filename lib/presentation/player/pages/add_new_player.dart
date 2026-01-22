import 'dart:io';

import 'package:dotted_border/dotted_border.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:real_amis/common/helpers/is_dark_mode.dart';
import 'package:real_amis/common/widgets/appBar/app_bar_yes_nav.dart';
import 'package:real_amis/common/widgets/loader/loader.dart';
import 'package:real_amis/common/widgets/textFields/number_field_nullable.dart';
import 'package:real_amis/common/widgets/textFields/text_field_required.dart';
import 'package:real_amis/core/configs/theme/app_colors.dart';
import 'package:real_amis/core/utils/pick_image.dart';
import 'package:real_amis/core/utils/show_snackbar.dart';
import 'package:real_amis/domain/entities/player/player_role.dart';
import 'package:real_amis/presentation/player/bloc/player_bloc.dart';

class AddNewPlayerPage extends StatefulWidget {
  static MaterialPageRoute route() =>
      MaterialPageRoute(builder: (_) => const AddNewPlayerPage());

  const AddNewPlayerPage({super.key});

  @override
  State<AddNewPlayerPage> createState() => _AddNewPlayerPageState();
}

class _AddNewPlayerPageState extends State<AddNewPlayerPage> {
  final _formKey = GlobalKey<FormState>();

  final TextEditingController _userNameController = TextEditingController();
  final TextEditingController _fullNameController = TextEditingController();
  final TextEditingController _attendancesController = TextEditingController();
  final TextEditingController _goalsController = TextEditingController();
  final TextEditingController _yellowCardsController = TextEditingController();
  final TextEditingController _redCardsController = TextEditingController();

  PlayerRole? _selectedRole;
  File? _image;
  bool _isActive = true;

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

  int _parseOrZero(String? text) {
    if (text == null || text.trim().isEmpty) return 0;
    return int.tryParse(text.trim()) ?? 0;
  }

  Future<void> _selectImage() async {
    final pickedImage = await pickImage();
    if (pickedImage != null) setState(() => _image = pickedImage);
  }

  void _uploadPlayer() {
    if (!(_formKey.currentState?.validate() ?? false)) return;

    if (_selectedRole == null) {
      showSnackBar(context, 'Seleziona un ruolo');
      return;
    }
    if (_image == null) {
      showSnackBar(context, 'Seleziona un\'immagine');
      return;
    }

    context.read<PlayerBloc>().add(
      PlayerUpload(
        userName: _userNameController.text.trim(),
        fullName: _fullNameController.text.trim(),
        image: _image!,
        role: _selectedRole!,
        attendances: _parseOrZero(_attendancesController.text),
        goals: _parseOrZero(_goalsController.text),
        yellowCards: _parseOrZero(_yellowCardsController.text),
        redCards: _parseOrZero(_redCardsController.text),
        active: _isActive,
      ),
    );
  }

  Widget _buildImagePicker() {
    final borderColor = context.isDarkMode
        ? AppColors.tertiary
        : AppColors.secondary;

    if (_image != null) {
      return GestureDetector(
        onTap: _selectImage,
        child: SizedBox(
          width: double.infinity,
          height: 150,
          child: ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: Image.file(_image!, fit: BoxFit.cover),
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
            children: const [
              Icon(Icons.folder_open, size: 50),
              SizedBox(height: 15),
              Text('Seleziona un\'immagine', style: TextStyle(fontSize: 15)),
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
        title: const Text('Aggiungi un giocatore'),
        actions: [
          IconButton(
            onPressed: _uploadPlayer,
            icon: Icon(
              Icons.done_rounded,
              color: context.isDarkMode
                  ? AppColors.iconDark
                  : AppColors.iconLight,
              size: 25,
            ),
            tooltip: 'Salva',
          ),
        ],
      ),
      body: BlocConsumer<PlayerBloc, PlayerState>(
        listener: (context, state) {
          if (state is PlayerFailure) showSnackBar(context, state.error);
          if (state is PlayerUploadSuccess) Navigator.pop(context);
        },
        builder: (context, state) {
          if (state is PlayerLoading) return const Loader();

          return SingleChildScrollView(
            padding: const EdgeInsets.all(16.0),
            child: Form(
              key: _formKey,
              child: Column(
                children: [
                  _buildImagePicker(),
                  const SizedBox(height: 30),
                  TextFieldRequired(
                    controller: _fullNameController,
                    hintText: 'Nome e cognome',
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
                  TextFieldRequired(
                    controller: _userNameController,
                    hintText: 'Soprannome',
                  ),
                  const SizedBox(height: 15),
                  NumberFieldNullable(
                    controller: _attendancesController,
                    hintText: 'Presenze',
                  ),
                  const SizedBox(height: 15),
                  NumberFieldNullable(
                    controller: _goalsController,
                    hintText: 'Goal',
                  ),
                  const SizedBox(height: 15),
                  NumberFieldNullable(
                    controller: _yellowCardsController,
                    hintText: 'Cartellini gialli',
                  ),
                  const SizedBox(height: 15),
                  NumberFieldNullable(
                    controller: _redCardsController,
                    hintText: 'Cartellini rossi',
                  ),
                  const SizedBox(height: 15),
                  SegmentedButton<int>(
                    segments: const [
                      ButtonSegment(value: 0, label: Text('Attivo')),
                      ButtonSegment(value: 1, label: Text('Non attivo')),
                    ],
                    selected: _isActive ? {0} : {1},
                    onSelectionChanged: (newSelection) {
                      setState(() => _isActive = newSelection.contains(0));
                    },
                    multiSelectionEnabled: false,
                    style: ButtonStyle(
                      tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                      visualDensity: VisualDensity.compact,

                      backgroundColor: WidgetStateProperty.resolveWith((
                        states,
                      ) {
                        final isSelected = states.contains(
                          WidgetState.selected,
                        );

                        if (isSelected) {
                          return context.isDarkMode
                              ? AppColors.tertiary.withValues(alpha: 0.35)
                              : AppColors.primary.withValues(alpha: 0.25);
                        }
                        return Colors.transparent;
                      }),

                      foregroundColor: WidgetStateProperty.resolveWith((
                        states,
                      ) {
                        final isSelected = states.contains(
                          WidgetState.selected,
                        );

                        if (isSelected) {
                          return context.isDarkMode
                              ? AppColors.textDarkPrimary
                              : AppColors.textLightPrimary;
                        }

                        return context.isDarkMode
                            ? AppColors.textDarkSecondary
                            : AppColors.textLightSecondary;
                      }),

                      side: WidgetStateProperty.resolveWith((states) {
                        final isSelected = states.contains(
                          WidgetState.selected,
                        );

                        return BorderSide(
                          color: isSelected
                              ? (context.isDarkMode
                                    ? AppColors.tertiary
                                    : AppColors.primary)
                              : (context.isDarkMode
                                    ? AppColors.textDarkSecondary.withValues(
                                        alpha: 0.3,
                                      )
                                    : AppColors.textLightSecondary.withValues(
                                        alpha: 0.3,
                                      )),
                          width: 1,
                        );
                      }),

                      shape: WidgetStateProperty.all(
                        RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),

                      overlayColor: WidgetStateProperty.all(
                        (context.isDarkMode
                                ? AppColors.tertiary
                                : AppColors.primary)
                            .withValues(alpha: 0.08),
                      ),
                    ),
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
