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

  /// Id del giocatore selezionato, oppure [_ownGoalValue] se il gol è un
  /// autogoal della squadra avversaria.
  String? selectedPlayerId;
  static const _ownGoalValue = '__own_goal__';
  final minuteController = TextEditingController();
  EventType selectedType = EventType.goal;
  bool _submitting = false;

  bool get _isRealAmisTeam {
    final teamId = teamSide == 'home'
        ? widget.match.homeTeamId
        : widget.match.awayTeamId;
    return teamId == AppSecrets.realAmisTeamId;
  }

  bool get _isOwnGoalSelected =>
      _isRealAmisTeam && selectedPlayerId == _ownGoalValue;

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

    final isOwnGoalSelected = _isOwnGoalSelected;
    final calledUpPlayers = _getCalledUpPlayers(
      ref.read(playerNotifierProvider).value ?? [],
    );
    final PlayerEntity? player = _isRealAmisTeam && !isOwnGoalSelected
        ? calledUpPlayers.where((p) => p.id == selectedPlayerId).firstOrNull
        : null;

    if (_isRealAmisTeam && !isOwnGoalSelected && player == null) {
      showSnackBar(context, 'Seleziona un giocatore');
      return;
    }
    if (!_isRealAmisTeam && playerController.text.trim().isEmpty) {
      showSnackBar(context, 'Inserisci il nome del giocatore');
      return;
    }

    // Per un autogoal non c'è nessun giocatore da associare: nome fisso e
    // nessun playerId, così le statistiche individuali restano invariate.
    final playerName = _isRealAmisTeam
        ? (isOwnGoalSelected ? ownGoalLabel : player!.fullName)
        : playerController.text.trim();

    setState(() => _submitting = true);

    try {
      final result = await ref
          .read(eventNotifierProvider(widget.match.id).notifier)
          .uploadEvent(
            UploadEventParams(
              matchId: widget.match.id,
              teamId: teamId,
              player: playerName,
              minutes: int.parse(minuteController.text.trim()),
              eventType: selectedType,
              playerId: player?.id,
            ),
          );

      if (!mounted) return;
      if (!result.ok) {
        showSnackBar(context, 'Errore: ${result.error}');
        return;
      }
      final isOwnGoal =
          selectedType == EventType.goal && isOwnGoalName(playerName);
      showSnackBar(
        context,
        result.warning ??
            (isOwnGoal
                ? 'Autogoal aggiunto (${minuteController.text.trim()}\')'
                : 'Evento aggiunto: ${selectedType.value} di $playerName (${minuteController.text.trim()}\')'),
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
                selectedPlayerId = null;
                playerController.clear();
              }),
            ),
            const SizedBox(height: 12),
            Form(
              key: _formKey,
              child: Column(
                children: [
                  if (_isRealAmisTeam)
                    DropdownButtonFormField<String>(
                      // La chiave cambia quando la voce "Autogoal" compare o
                      // scompare, così il campo si ricostruisce senza tenere
                      // un valore non più presente nell'elenco.
                      key: ValueKey(
                        'player-dd-${selectedType == EventType.goal}',
                      ),
                      initialValue: selectedPlayerId,
                      items: <DropdownMenuItem<String>>[
                        if (selectedType == EventType.goal)
                          DropdownMenuItem<String>(
                            value: _ownGoalValue,
                            child: Text(
                              '$ownGoalLabel (avversario)',
                              style: TextStyle(
                                color: textColor,
                                fontStyle: FontStyle.italic,
                              ),
                            ),
                          ),
                        ...calledUpPlayers.map(
                          (p) => DropdownMenuItem<String>(
                            value: p.id,
                            child: Text(
                              p.fullName,
                              style: TextStyle(color: textColor),
                            ),
                          ),
                        ),
                      ],
                      onChanged: (id) => setState(() => selectedPlayerId = id),
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
                      validator: (_) => selectedPlayerId == null
                          ? 'Seleziona un giocatore'
                          : null,
                    )
                  else ...[
                    TextFieldRequired(
                      controller: playerController,
                      labelText: 'Giocatore',
                      hintText: 'Nome giocatore',
                    ),
                    // Autogoal di un giocatore del Real Amis: il gol va alla
                    // squadra avversaria selezionata qui sopra.
                    if (selectedType == EventType.goal)
                      Align(
                        alignment: Alignment.centerLeft,
                        child: Padding(
                          padding: const EdgeInsets.only(top: 8),
                          child: ActionChip(
                            avatar: const Icon(Icons.sports_soccer, size: 16),
                            label: const Text(ownGoalLabel),
                            onPressed: () => setState(
                              () => playerController.text = ownGoalLabel,
                            ),
                          ),
                        ),
                      ),
                  ],
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
                      setState(() {
                        selectedType = v;
                        if (v != EventType.goal &&
                            selectedPlayerId == _ownGoalValue) {
                          selectedPlayerId = null;
                        }
                      });
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
