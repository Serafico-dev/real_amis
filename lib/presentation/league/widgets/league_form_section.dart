import 'package:flutter/material.dart';
import 'package:real_amis/common/widgets/textFields/text_field_required.dart';

class LeagueFormSection extends StatelessWidget {
  final GlobalKey<FormState> formKey;
  final TextEditingController nameController;
  final TextEditingController yearController;

  const LeagueFormSection({
    super.key,
    required this.formKey,
    required this.nameController,
    required this.yearController,
  });

  @override
  Widget build(BuildContext context) {
    return Form(
      key: formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          TextFieldRequired(
            controller: nameController,
            hintText: 'Nome del campionato',
          ),
          const SizedBox(height: 16),
          TextFieldRequired(
            controller: yearController,
            hintText: 'Anno (es. 2025/2026)',
          ),
        ],
      ),
    );
  }
}
