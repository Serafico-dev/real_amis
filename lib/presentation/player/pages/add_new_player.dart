import 'dart:io';

import 'package:dotted_border/dotted_border.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
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
      MaterialPageRoute(builder: (context) => AddNewPlayerPage());
  const AddNewPlayerPage({super.key});

  @override
  State<AddNewPlayerPage> createState() => _AddNewPlayerPageState();
}

class _AddNewPlayerPageState extends State<AddNewPlayerPage> {
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

  void uploadPlayer() {
    if (formKey.currentState!.validate() &&
        _selectedRole != null &&
        image != null) {
      context.read<PlayerBloc>().add(
        PlayerUpload(
          userName: userNameController.text.trim(),
          fullName: fullNameController.text.trim(),
          image: image!,
          role: _selectedRole!,
          attendances: attendancesController.text.trim().isNotEmpty
              ? int.parse(attendancesController.text.trim())
              : 0,
          goals: goalsController.text.trim().isNotEmpty
              ? int.parse(goalsController.text.trim())
              : 0,
          yellowCards: yellowCardsController.text.trim().isNotEmpty
              ? int.parse(yellowCardsController.text.trim())
              : 0,
          redCards: redCardsController.text.trim().isNotEmpty
              ? int.parse(redCardsController.text.trim())
              : 0,
          active: isActive,
        ),
      );
    }
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
        title: Text('Aggiungi un giocatore'),
        actions: [
          IconButton(
            onPressed: () {
              uploadPlayer();
            },
            icon: Icon(Icons.done_rounded, size: 25),
          ),
        ],
      ),
      body: BlocConsumer<PlayerBloc, PlayerState>(
        listener: (context, state) {
          if (state is PlayerFailure) {
            showSnackBar(context, state.error);
          } else if (state is PlayerUploadSuccess) {
            Navigator.pop(context);
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
                    image != null
                        ? GestureDetector(
                            onTap: () {
                              selectImage();
                            },
                            child: SizedBox(
                              width: double.infinity,
                              height: 150,
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(10),
                                child: Image.file(image!, fit: BoxFit.cover),
                              ),
                            ),
                          )
                        : GestureDetector(
                            onTap: () => selectImage(),
                            child: DottedBorder(
                              options: RoundedRectDottedBorderOptions(
                                radius: Radius.circular(10),
                                color: AppColors.tertiary,
                                dashPattern: [20, 4],
                                strokeCap: StrokeCap.round,
                              ),
                              child: SizedBox(
                                height: 150,
                                width: double.infinity,
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Icon(Icons.folder_open, size: 50),
                                    SizedBox(height: 15),
                                    Text(
                                      'Seleziona una foto',
                                      style: TextStyle(fontSize: 15),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                    SizedBox(height: 30),
                    TextFieldRequired(
                      controller: fullNameController,
                      hintText: 'Nome e cognome',
                    ),
                    SizedBox(height: 15),
                    DropdownButtonFormField<PlayerRole>(
                      initialValue: _selectedRole,
                      items: PlayerRole.values
                          .map(
                            (r) => DropdownMenuItem(
                              value: r,
                              child: Text(r.value),
                            ),
                          )
                          .toList(),
                      onChanged: (v) => setState(() => _selectedRole = v),
                      decoration: InputDecoration(hintText: 'Ruolo'),
                      validator: (v) => v == null ? 'Seleziona un ruolo' : null,
                    ),
                    SizedBox(height: 15),
                    TextFieldRequired(
                      controller: userNameController,
                      hintText: 'Soprannome',
                    ),
                    SizedBox(height: 15),
                    NumberFieldNullable(
                      controller: attendancesController,
                      hintText: 'Presenze',
                    ),
                    SizedBox(height: 15),
                    NumberFieldNullable(
                      controller: goalsController,
                      hintText: 'Goal',
                    ),
                    SizedBox(height: 15),
                    NumberFieldNullable(
                      controller: yellowCardsController,
                      hintText: 'Cartellini gialli',
                    ),
                    SizedBox(height: 15),
                    NumberFieldNullable(
                      controller: redCardsController,
                      hintText: 'Cartellini rossi',
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
