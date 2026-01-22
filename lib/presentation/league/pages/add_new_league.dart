import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:real_amis/common/helpers/is_dark_mode.dart';
import 'package:real_amis/common/widgets/appBar/app_bar_yes_nav.dart';
import 'package:real_amis/core/configs/theme/app_colors.dart';
import 'package:real_amis/core/utils/show_snackbar.dart';
import 'package:real_amis/presentation/league/bloc/league_bloc.dart';
import 'package:real_amis/presentation/league/widgets/league_form_section.dart';

class AddNewLeaguePage extends StatefulWidget {
  static MaterialPageRoute route() =>
      MaterialPageRoute(builder: (_) => const AddNewLeaguePage());

  const AddNewLeaguePage({super.key});

  @override
  State<AddNewLeaguePage> createState() => _AddNewLeaguePageState();
}

class _AddNewLeaguePageState extends State<AddNewLeaguePage> {
  final formKey = GlobalKey<FormState>();
  final nameController = TextEditingController();
  final yearController = TextEditingController();

  @override
  void dispose() {
    nameController.dispose();
    yearController.dispose();
    super.dispose();
  }

  void _uploadLeague() {
    if (formKey.currentState!.validate()) {
      context.read<LeagueBloc>().add(
        LeagueUpload(
          name: nameController.text.trim(),
          year: yearController.text.trim(),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = context.isDarkMode;

    return Scaffold(
      appBar: AppBarYesNav(
        title: const Text('Aggiungi un campionato'),
        actions: [
          IconButton(
            icon: Icon(
              Icons.done_rounded,
              color: isDark ? AppColors.iconDark : AppColors.iconLight,
              size: 25,
            ),
            tooltip: 'Salva',
            onPressed: _uploadLeague,
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: BlocConsumer<LeagueBloc, LeagueState>(
          listener: (context, state) {
            if (state is LeagueFailure) {
              showSnackBar(context, state.error);
            }
            if (state is LeagueUploadSuccess) {
              Navigator.pop(context);
            }
          },
          builder: (context, state) {
            return LeagueFormSection(
              formKey: formKey,
              nameController: nameController,
              yearController: yearController,
            );
          },
        ),
      ),
    );
  }
}
