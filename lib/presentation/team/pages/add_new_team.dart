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
import 'package:real_amis/presentation/team/bloc/team_bloc.dart';

class AddNewTeamPage extends StatefulWidget {
  static MaterialPageRoute route() =>
      MaterialPageRoute(builder: (context) => AddNewTeamPage());
  const AddNewTeamPage({super.key});

  @override
  State<AddNewTeamPage> createState() => _AddNewTeamPageState();
}

class _AddNewTeamPageState extends State<AddNewTeamPage> {
  final nameController = TextEditingController();
  final scoreController = TextEditingController();
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

  void uploadTeam() {
    if (formKey.currentState!.validate() && image != null) {
      context.read<TeamBloc>().add(
        TeamUpload(
          name: nameController.text.trim(),
          image: image!,
          score: scoreController.text.trim().isNotEmpty
              ? int.parse(scoreController.text.trim())
              : 0,
        ),
      );
    }
  }

  @override
  void dispose() {
    super.dispose();
    nameController.dispose();
    scoreController.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBarYesNav(
        title: Text('Aggiungi una squadra'),
        actions: [
          IconButton(
            onPressed: () {
              uploadTeam();
            },
            icon: Icon(Icons.done_rounded, size: 25),
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
                      controller: nameController,
                      hintText: 'Nome',
                    ),
                    SizedBox(height: 15),
                    NumberFieldNullable(
                      controller: scoreController,
                      hintText: 'Punteggio',
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
