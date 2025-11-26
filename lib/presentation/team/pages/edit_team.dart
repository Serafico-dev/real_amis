import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:real_amis/common/widgets/appBar/app_bar_yes_nav.dart';
import 'package:real_amis/common/widgets/button/basic_app_button.dart';
import 'package:real_amis/common/widgets/loader/loader.dart';
import 'package:real_amis/common/widgets/textFields/text_field_nullable.dart';
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
  State<EditTeamPage> createState() => _EditTeamState();
}

class _EditTeamState extends State<EditTeamPage> {
  final nameController = TextEditingController();
  final formKey = GlobalKey<FormState>();
  File? image;

  void selectImage() async {
    final pickedImage = await pickImage();
    if (pickedImage != null) {
      setState(() {
        image = pickedImage;
      });
    }
  }

  void updateTeam() async {
    context.read<TeamBloc>().add(
      TeamUpdate(
        team: widget.team,
        name: nameController.text.trim().isNotEmpty
            ? nameController.text.trim()
            : widget.team.name,
        image: image,
      ),
    );
  }

  @override
  void dispose() {
    super.dispose();
    nameController.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBarYesNav(
        title: Text('Modifica squadra'),
        actions: [
          IconButton(
            onPressed: () {
              updateTeam();
            },
            icon: Icon(Icons.done_rounded, size: 25),
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
          if (state is TeamLoading) {
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
                        widget.team.imageUrl,
                        fit: BoxFit.cover,
                      ),
                    ),
                    SizedBox(height: 15),
                    IconButton(
                      onPressed: () => selectImage(),
                      tooltip: 'Modifica logo',
                      icon: Icon(
                        Icons.add_a_photo_outlined,
                        color: AppColors.primary,
                        size: 50,
                      ),
                    ),
                    SizedBox(height: 15),
                    TextFieldNullable(
                      controller: nameController,
                      hintText: '${widget.team.name} (Nome)',
                    ),
                    SizedBox(height: 15),
                    BlocBuilder<TeamBloc, TeamState>(
                      builder: (context, state) {
                        final isLoading = state is TeamLoading;
                        return BasicAppButton(
                          onPressed: isLoading
                              ? null
                              : () async {
                                  final confirmed = await showDialog<bool>(
                                    context: context,
                                    builder: (context) => AlertDialog(
                                      title: Text('Conferma eliminazione'),
                                      content: Text(
                                        'Sei sicuro di voler eliminare questa squadra?',
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
                                  if (confirmed == true) {
                                    context.read<TeamBloc>().add(
                                      TeamDelete(teamId: widget.team.id),
                                    );
                                  }
                                },
                          title: isLoading
                              ? 'Eliminazione in corso...'
                              : 'Elimina squadra',
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
