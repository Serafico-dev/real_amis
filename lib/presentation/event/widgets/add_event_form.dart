import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:real_amis/common/helpers/is_dark_mode.dart';
import 'package:real_amis/common/widgets/button/basic_app_button.dart';
import 'package:real_amis/common/widgets/textFields/number_field_required.dart';
import 'package:real_amis/common/widgets/textFields/text_field_required.dart';
import 'package:real_amis/core/configs/theme/app_colors.dart';
import 'package:real_amis/core/secrets/app_secrets.dart';
import 'package:real_amis/core/utils/show_snackbar.dart';
import 'package:real_amis/domain/entities/event/event_type.dart';
import 'package:real_amis/domain/entities/match/match_entity.dart';
import 'package:real_amis/domain/entities/player/player_entity.dart';
import 'package:real_amis/domain/usecases/event/upload_event.dart';
import 'package:real_amis/presentation/event/providers/event_notifier.dart';
import 'package:real_amis/presentation/event/widgets/team_selector.dart';
import 'package:real_amis/presentation/player/providers/player_notifier.dart';

class AddEventForm extends ConsumerStatefulWidget {
  final MatchEntity match;
  const AddEventForm({super.key, required this.match});

  @override
  ConsumerState<AddEventForm> createState() => _AddEventFormState();
}

class _AddEventFormState extends ConsumerState<AddEventForm> {
  final _formKey = GlobalKey<FormState>();
  String teamSide = 'home';
  final playerController = TextEditingController();
  PlayerEntity? selectedPlayer;
  final minuteController = TextEditingController();
  EventType selectedType = EventType.goal;
  bool _submitting = false;

  bool get _isRealAmisTeam {
    final teamId = teamSide == 'home'
        ? widget.match.homeTeamId
        : widget.match.awayTeamId;
    return teamId == AppSecrets.realAmisTeamId;
  }

  List<PlayerEntity> _getCalledUpPlayers(List<PlayerEntity> allPlayers) {
    return allPlayers
        .where((p) => widget.match.calledUpIds.contains(p.id))
        .toList()
      ..sort((a, b) => a.fullName.compareTo(b.fullName));
  }

  @override
  void dispose() {
    playerController.dispose();
    minuteController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    final isHome = teamSide == 'home';
    final teamId = isHome ? widget.match.homeTeamId : widget.match.awayTeamId;

    if (_isRealAmisTeam && selectedPlayer == null) {
      showSnackBar(context, 'Seleziona un giocatore');
      return;
    }
    if (!_isRealAmisTeam && playerController.text.trim().isEmpty) {
      showSnackBar(context, 'Inserisci il nome del giocatore');
      return;
    }

    final playerName = _isRealAmisTeam
        ? selectedPlayer!.fullName
        : playerController.text.trim();

    setState(() => _submitting = true);

    try {
      await ref
          .read(eventNotifierProvider(widget.match.id).notifier)
          .uploadEvent(
            UploadEventParams(
              matchId: widget.match.id,
              teamId: teamId,
              player: playerName,
              minutes: int.parse(minuteController.text.trim()),
              eventType: selectedType,
              playerId: _isRealAmisTeam ? selectedPlayer!.id : null,
            ),
          );

      if (!mounted) return;
      showSnackBar(
        context,
        'Evento aggiunto: ${selectedType.value} di $playerName (${minuteController.text.trim()}\')',
      );
      Navigator.of(context).pop('created');
    } catch (e) {
      if (!mounted) return;
      showSnackBar(context, 'Errore: $e');
    } finally {
      if (mounted) setState(() => _submitting = false);
    }
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
    final allPlayers = ref.watch(playerNotifierProvider).value ?? [];
    final calledUpPlayers = _getCalledUpPlayers(allPlayers);

    return SingleChildScrollView(
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
              onChanged: (v) => setState(() {
                teamSide = v;
                selectedPlayer = null;
                playerController.clear();
              }),
            ),
            const SizedBox(height: 12),
            Form(
              key: _formKey,
              child: Column(
                children: [
                  if (_isRealAmisTeam)
                    DropdownButtonFormField<PlayerEntity>(
                      initialValue: selectedPlayer,
                      items: calledUpPlayers
                          .map(
                            (p) => DropdownMenuItem(
                              value: p,
                              child: Text(
                                p.fullName,
                                style: TextStyle(color: textColor),
                              ),
                            ),
                          )
                          .toList(),
                      onChanged: (p) => setState(() => selectedPlayer = p),
                      decoration: InputDecoration(
                        labelText: 'Giocatore',
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
                      validator: (_) => selectedPlayer == null
                          ? 'Seleziona un giocatore'
                          : null,
                    )
                  else
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
                      if (v != null) setState(() => selectedType = v);
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
    );
  }
}
