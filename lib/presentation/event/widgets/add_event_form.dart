import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:real_amis/common/helpers/is_dark_mode.dart';
import 'package:real_amis/common/widgets/button/basic_app_button.dart';
import 'package:real_amis/common/widgets/textFields/number_field_required.dart';
import 'package:real_amis/common/widgets/textFields/text_field_required.dart';
import 'package:real_amis/core/configs/theme/app_colors.dart';
import 'package:real_amis/core/utils/show_snackbar.dart';
import 'package:real_amis/domain/entities/event/event_type.dart';
import 'package:real_amis/domain/entities/match/match_entity.dart';
import 'package:real_amis/presentation/event/bloc/event_bloc.dart';
import 'package:real_amis/presentation/event/widgets/team_selector.dart';

class AddEventForm extends StatefulWidget {
  final MatchEntity match;
  const AddEventForm({super.key, required this.match});

  @override
  State<AddEventForm> createState() => _AddEventFormState();
}

class _AddEventFormState extends State<AddEventForm> {
  final _formKey = GlobalKey<FormState>();
  String teamSide = 'home';
  final playerController = TextEditingController();
  final minuteController = TextEditingController();
  EventType selectedType = EventType.goal;
  bool _submitting = false;

  @override
  void dispose() {
    playerController.dispose();
    minuteController.dispose();
    super.dispose();
  }

  void _submit() {
    if (!_formKey.currentState!.validate()) return;

    final isHome = teamSide == 'home';
    final teamId = isHome ? widget.match.homeTeamId : widget.match.awayTeamId;

    context.read<EventBloc>().add(
      EventUpload(
        matchId: widget.match.id,
        teamId: teamId,
        player: playerController.text.trim(),
        minutes: int.parse(minuteController.text.trim()),
        eventType: selectedType,
      ),
    );

    setState(() => _submitting = true);
  }

  @override
  Widget build(BuildContext context) {
    final isDarkMode = context.isDarkMode;
    final textColor = isDarkMode
        ? AppColors.textDarkPrimary
        : AppColors.textLightPrimary;
    final secondaryTextColor = isDarkMode
        ? AppColors.textDarkSecondary
        : AppColors.textLightSecondary;
    final inputFillColor = isDarkMode
        ? AppColors.inputFillDark
        : AppColors.inputFillLight;
    final inputBorderColor = isDarkMode
        ? AppColors.inputBorderDark
        : AppColors.inputBorderLight;

    return BlocListener<EventBloc, EventState>(
      listener: (context, state) {
        if (!_submitting) return;
        if (state is EventUploadSuccess) {
          if (!mounted) return;
          showSnackBar(
            context,
            'Evento aggiunto: ${selectedType.value} di ${playerController.text.trim()} - ${teamSide == 'home' ? widget.match.homeTeam?.name : widget.match.awayTeam?.name} (${minuteController.text.trim()}\')',
          );
          setState(() => _submitting = false);
          Navigator.of(context).pop('created');
        } else if (state is EventFailure) {
          if (!mounted) return;
          showSnackBar(context, 'Errore: ${state.error}');
          setState(() => _submitting = false);
        }
      },
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        child: ConstrainedBox(
          constraints: BoxConstraints(
            minWidth: MediaQuery.of(context).size.width,
          ),
          child: Column(
            children: [
              TeamSelector(
                match: widget.match,
                teamSide: teamSide,
                onChanged: (v) => setState(() => teamSide = v),
              ),
              const SizedBox(height: 12),
              Form(
                key: _formKey,
                child: Column(
                  children: [
                    TextFieldRequired(
                      controller: playerController,
                      labelText: 'Giocatore',
                      hintText: 'Nome giocatore',
                    ),
                    const SizedBox(height: 12),

                    NumberFieldRequired(
                      controller: minuteController,
                      labelText: 'Minuto',
                      hintText: '0',
                    ),
                    const SizedBox(height: 12),

                    DropdownButtonFormField<EventType>(
                      initialValue: selectedType,
                      items: EventType.values
                          .map(
                            (e) => DropdownMenuItem(
                              value: e,
                              child: Text(
                                e.value,
                                style: TextStyle(color: textColor),
                              ),
                            ),
                          )
                          .toList(),
                      onChanged: (v) {
                        if (v == null) return;
                        setState(() => selectedType = v);
                      },
                      decoration: InputDecoration(
                        labelText: 'Tipo evento',
                        labelStyle: TextStyle(color: secondaryTextColor),
                        filled: true,
                        fillColor: inputFillColor,
                        enabledBorder: OutlineInputBorder(
                          borderSide: BorderSide(color: inputBorderColor),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderSide: BorderSide(color: AppColors.primary),
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),

                    Row(
                      children: [
                        Expanded(
                          child: BasicAppButton(
                            onPressed: _submitting
                                ? null
                                : () => Navigator.of(context).pop(),
                            title: 'Annulla',
                            isOutline: true,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: BasicAppButton(
                            onPressed: _submitting ? null : _submit,
                            title: _submitting
                                ? 'Aggiunta in corso...'
                                : 'Aggiungi',
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 16),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
