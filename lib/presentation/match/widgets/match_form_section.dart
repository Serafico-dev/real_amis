import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_datetime_picker_plus/flutter_datetime_picker_plus.dart';
import 'package:real_amis/common/helpers/is_dark_mode.dart';
import 'package:real_amis/common/widgets/button/basic_app_button.dart';
import 'package:real_amis/common/widgets/loader/loader.dart';
import 'package:real_amis/common/widgets/textFields/number_field_nullable.dart';
import 'package:real_amis/common/widgets/textFields/text_field_nullable.dart';
import 'package:real_amis/core/configs/theme/app_colors.dart';
import 'package:real_amis/core/utils/format_data.dart';
import 'package:real_amis/core/utils/show_snackbar.dart';
import 'package:real_amis/domain/entities/match/match_entity.dart';
import 'package:real_amis/presentation/match/bloc/match_bloc.dart';

class MatchFormSection extends StatelessWidget {
  final GlobalKey<FormState> formKey;
  final DateTime? selectedDate;
  final ValueChanged<DateTime?> onDatePicked;
  final TextEditingController matchDayController;
  final TextEditingController homeTeamScoreController;
  final TextEditingController awayTeamScoreController;
  final MatchEntity? match;
  final bool showDeleteButton;

  const MatchFormSection({
    super.key,
    required this.formKey,
    required this.selectedDate,
    required this.onDatePicked,
    required this.matchDayController,
    required this.homeTeamScoreController,
    required this.awayTeamScoreController,
    this.match,
    this.showDeleteButton = false,
  });

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<MatchBloc, MatchState>(
      listener: (context, state) {
        if (state is MatchFailure) showSnackBar(context, state.error);
        if (state is MatchUpdateSuccess) {
          Navigator.pop(context, state.updatedMatch);
        }
        if (state is MatchDeleteSuccess) Navigator.pop(context, true);
      },
      builder: (context, state) {
        if (state is MatchLoading) return const Loader();

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
                  color: context.isDarkMode
                      ? AppColors.textDarkPrimary
                      : AppColors.textLightPrimary,
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
              const SizedBox(height: 15),
              TextFieldNullable(
                controller: matchDayController,
                hintText: 'Specifica la giornata (${match?.matchDay ?? 'G0'})',
              ),
              const SizedBox(height: 15),
              NumberFieldNullable(
                controller: homeTeamScoreController,
                hintText:
                    'Goal squadra in casa (${match?.homeTeamScore ?? '0'})',
              ),
              const SizedBox(height: 15),
              NumberFieldNullable(
                controller: awayTeamScoreController,
                hintText:
                    'Goal squadra ospite (${match?.awayTeamScore ?? '0'})',
              ),
              if (showDeleteButton) ...[
                const SizedBox(height: 15),
                BlocBuilder<MatchBloc, MatchState>(
                  builder: (context, state) {
                    final isLoading = state is MatchLoading;
                    return BasicAppButton(
                      onPressed: isLoading
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
                                          color: AppColors.tagRed,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              );
                              if (confirmed == true && context.mounted) {
                                context.read<MatchBloc>().add(
                                  MatchDelete(matchId: match!.id),
                                );
                              }
                            },
                      title: isLoading
                          ? 'Eliminazione in corso...'
                          : 'Elimina partita',
                    );
                  },
                ),
              ],
            ],
          ),
        );
      },
    );
  }
}
