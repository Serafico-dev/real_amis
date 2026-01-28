import 'package:flutter/material.dart';
import 'package:flutter_datetime_picker_plus/flutter_datetime_picker_plus.dart';
import 'package:real_amis/common/helpers/is_dark_mode.dart';
import 'package:real_amis/common/widgets/textFields/text_field_required.dart';
import 'package:real_amis/core/configs/theme/app_colors.dart';
import 'package:real_amis/core/utils/format_data.dart';

class MatchFormSection extends StatelessWidget {
  final GlobalKey<FormState> formKey;
  final DateTime? selectedDate;
  final ValueChanged<DateTime?> onDatePicked;
  final TextEditingController matchDayController;
  final bool showDeleteButton;

  const MatchFormSection({
    super.key,
    required this.formKey,
    required this.selectedDate,
    required this.onDatePicked,
    required this.matchDayController,
    this.showDeleteButton = false,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = context.isDarkMode;

    return Form(
      key: formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            selectedDate == null
                ? 'Non hai ancora scelto una data'
                : formatDateByddMMYYYYHHmm(selectedDate!),
            style: TextStyle(
              color: isDark
                  ? AppColors.textDarkPrimary
                  : AppColors.textLightPrimary,
              fontWeight: FontWeight.w600,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 8),
          ElevatedButton.icon(
            onPressed: () async {
              final pickedDate = await DatePicker.showDateTimePicker(
                context,
                showTitleActions: true,
                minTime: DateTime(2020),
                maxTime: DateTime(2040, 12, 31),
                currentTime: selectedDate ?? DateTime.now(),
                locale: LocaleType.it,
              );
              onDatePicked(pickedDate);
            },
            icon: const Icon(Icons.calendar_today, color: Colors.white),
            label: const Text('Scegli una data'),
          ),
          const SizedBox(height: 16),
          TextFieldRequired(
            controller: matchDayController,
            labelText: 'Giornata',
            hintText: 'G0',
          ),
        ],
      ),
    );
  }
}
