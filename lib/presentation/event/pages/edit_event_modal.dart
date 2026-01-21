import 'package:flutter/material.dart';
import 'package:real_amis/common/helpers/is_dark_mode.dart';
import 'package:real_amis/core/configs/theme/app_colors.dart';
import 'package:real_amis/domain/entities/event/event_entity.dart';
import 'package:real_amis/presentation/event/widgets/edit_event_form.dart';

class EditEventModal extends StatelessWidget {
  final EventEntity event;
  const EditEventModal({super.key, required this.event});

  @override
  Widget build(BuildContext context) {
    final bottom = MediaQuery.of(context).viewInsets.bottom;
    final isDarkMode = context.isDarkMode;

    return Padding(
      padding: EdgeInsets.fromLTRB(20, 20, 20, 20 + bottom),
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 40,
              height: 4,
              margin: const EdgeInsets.only(bottom: 8),
              decoration: BoxDecoration(
                color: isDarkMode
                    ? AppColors.dividerDark
                    : AppColors.dividerLight,
                borderRadius: BorderRadius.circular(2),
              ),
            ),

            Text(
              'Modifica evento',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 16,
                color: isDarkMode
                    ? AppColors.textDarkPrimary
                    : AppColors.textLightPrimary,
              ),
            ),

            const SizedBox(height: 12),

            EditEventForm(event: event),
          ],
        ),
      ),
    );
  }
}
