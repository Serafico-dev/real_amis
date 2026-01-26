import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_datetime_picker_plus/flutter_datetime_picker_plus.dart';
import 'package:real_amis/common/helpers/is_dark_mode.dart';
import 'package:real_amis/common/widgets/button/basic_app_button.dart';
import 'package:real_amis/common/widgets/loader/loader.dart';
import 'package:real_amis/common/widgets/textFields/number_field_nullable.dart';
import 'package:real_amis/common/widgets/textFields/text_field_required.dart';
import 'package:real_amis/core/configs/theme/app_colors.dart';
import 'package:real_amis/core/utils/format_data.dart';
import 'package:real_amis/core/utils/show_snackbar.dart';
import 'package:real_amis/domain/entities/league/league_entity.dart';
import 'package:real_amis/domain/entities/match/match_entity.dart';
import 'package:real_amis/presentation/league/bloc/league_bloc.dart';
import 'package:real_amis/presentation/match/bloc/match_bloc.dart';

class MatchFormSection extends StatelessWidget {
  final GlobalKey<FormState> formKey;
  final DateTime? selectedDate;
  final ValueChanged<DateTime?> onDatePicked;
  final TextEditingController matchDayController;
  final TextEditingController homeTeamScoreController;
  final TextEditingController awayTeamScoreController;
  final LeagueEntity? selectedLeague;
  final ValueChanged<LeagueEntity?>? onLeagueSelected;
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
    this.selectedLeague,
    this.onLeagueSelected,
    this.match,
    this.showDeleteButton = false,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = context.isDarkMode;

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
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            child: ConstrainedBox(
              constraints: BoxConstraints(
                minWidth: MediaQuery.of(context).size.width,
              ),
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

                  BlocBuilder<LeagueBloc, LeagueState>(
                    builder: (context, state) {
                      if (state is LeagueDisplaySuccess) {
                        final leaguesList =
                            state.leagues
                                .map(
                                  (e) => LeagueEntity(
                                    id: e.id,
                                    name: e.name,
                                    year: e.year,
                                    teamIds: e.teamIds,
                                  ),
                                )
                                .toList()
                              ..sort((a, b) => b.year.compareTo(a.year));

                        final initialLeague = leaguesList.firstWhere(
                          (l) =>
                              l.id == (selectedLeague?.id ?? match?.league?.id),
                          orElse: () => leaguesList.first,
                        );

                        return SizedBox(
                          width: double.infinity,
                          child: DropdownButtonFormField<LeagueEntity>(
                            decoration: const InputDecoration(
                              labelText: 'Campionato',
                              border: OutlineInputBorder(),
                            ),
                            initialValue: initialLeague,
                            isExpanded: true,
                            items: leaguesList.map((league) {
                              return DropdownMenuItem(
                                value: league,
                                child: Text(
                                  '${league.name} - ${league.year}',
                                  overflow: TextOverflow.ellipsis,
                                ),
                              );
                            }).toList(),
                            onChanged: onLeagueSelected,
                            validator: (value) => value == null
                                ? 'Seleziona un campionato'
                                : null,
                          ),
                        );
                      } else if (state is LeagueFailure) {
                        return Text(
                          'Errore nel caricamento dei campionati',
                          style: TextStyle(color: AppColors.logoRed),
                        );
                      } else {
                        return const Center(child: CircularProgressIndicator());
                      }
                    },
                  ),
                  const SizedBox(height: 16),

                  TextFieldRequired(
                    controller: matchDayController,
                    hintText:
                        'Specifica la giornata (${match?.matchDay ?? 'G0'})',
                  ),
                  const SizedBox(height: 16),

                  NumberFieldNullable(
                    controller: homeTeamScoreController,
                    hintText:
                        'Goal squadra in casa (${match?.homeTeamScore ?? '0'})',
                  ),
                  const SizedBox(height: 16),
                  NumberFieldNullable(
                    controller: awayTeamScoreController,
                    hintText:
                        'Goal squadra ospite (${match?.awayTeamScore ?? '0'})',
                  ),
                  const SizedBox(height: 16),

                  if (showDeleteButton)
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
                                      title: const Text(
                                        'Conferma eliminazione',
                                      ),
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
              ),
            ),
          ),
        );
      },
    );
  }
}
