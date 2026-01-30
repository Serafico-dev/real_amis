import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_datetime_picker_plus/flutter_datetime_picker_plus.dart';
import 'package:real_amis/common/helpers/is_dark_mode.dart';
import 'package:real_amis/common/widgets/button/basic_app_button.dart';
import 'package:real_amis/common/widgets/loader/loader.dart';
import 'package:real_amis/common/widgets/textFields/text_field_required.dart';
import 'package:real_amis/core/configs/theme/app_colors.dart';
import 'package:real_amis/core/utils/format_data.dart';
import 'package:real_amis/domain/entities/match/match_entity.dart';
import 'package:real_amis/presentation/match/providers/match_notifier.dart';

class MatchFormSection extends ConsumerWidget {
  final GlobalKey<FormState> formKey;
  final DateTime? selectedDate;
  final ValueChanged<DateTime?> onDatePicked;
  final TextEditingController matchDayController;
  final MatchEntity? match;
  final bool showDeleteButton;

  const MatchFormSection({
    super.key,
    required this.formKey,
    required this.selectedDate,
    required this.onDatePicked,
    required this.matchDayController,
    this.match,
    this.showDeleteButton = false,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isDark = context.isDarkMode;
    final matchState = ref.watch(matchNotifierProvider);

    return matchState.isLoading
        ? const Loader()
        : Form(
            key: formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                TextFieldRequired(
                  controller: matchDayController,
                  labelText: 'Giornata',
                  hintText: 'G0',
                ),
                const SizedBox(height: 16),
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
                      currentTime:
                          selectedDate ?? match?.matchDate ?? DateTime.now(),
                      locale: LocaleType.it,
                    );
                    onDatePicked(pickedDate);
                  },
                  icon: const Icon(Icons.calendar_today, color: Colors.white),
                  label: const Text('Scegli una data'),
                ),
                const SizedBox(height: 16),
                if (showDeleteButton)
                  BasicAppButton(
                    onPressed: matchState.isLoading
                        ? null
                        : () async {
                            final confirmed = await showDialog<bool>(
                              context: context,
                              builder: (context) => AlertDialog(
                                title: const Text('Conferma eliminazione'),
                                content: const Text(
                                  'Sei sicuro di voler eliminare questa partita?',
                                ),
                                actions: [
                                  TextButton(
                                    onPressed: () =>
                                        Navigator.of(context).pop(false),
                                    child: const Text('Annulla'),
                                  ),
                                  TextButton(
                                    onPressed: () =>
                                        Navigator.of(context).pop(true),
                                    child: const Text(
                                      'Elimina',
                                      style: TextStyle(
                                        color: AppColors.logoRed,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            );
                            if (confirmed == true &&
                                context.mounted &&
                                match != null) {
                              await ref
                                  .read(matchNotifierProvider.notifier)
                                  .deleteMatch(match!.id);
                            }
                          },
                    title: matchState.isLoading
                        ? 'Eliminazione in corso...'
                        : 'Elimina partita',
                  ),
              ],
            ),
          );
  }
}
