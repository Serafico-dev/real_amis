import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:real_amis/common/helpers/is_dark_mode.dart';
import 'package:real_amis/core/configs/theme/app_colors.dart';
import 'package:real_amis/core/utils/show_snackbar.dart';
import 'package:real_amis/domain/entities/event/event_entity.dart';
import 'package:real_amis/domain/entities/event/event_type.dart';
import 'package:real_amis/presentation/event/bloc/event_bloc.dart';

class EditEventForm extends StatefulWidget {
  final EventEntity event;
  final VoidCallback onClose;

  const EditEventForm({super.key, required this.event, required this.onClose});

  @override
  State<EditEventForm> createState() => _EditEventFormState();
}

class _EditEventFormState extends State<EditEventForm> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _minutesController;
  late TextEditingController _playerController;
  late EventType _selectedType;
  bool _submitting = false;

  @override
  void initState() {
    super.initState();
    _minutesController = TextEditingController(
      text: widget.event.minutes.toString(),
    );
    _playerController = TextEditingController(text: widget.event.player);
    _selectedType = widget.event.eventType is String
        ? EventTypeX.fromString(widget.event.eventType as String)
        : widget.event.eventType;
  }

  @override
  void dispose() {
    _minutesController.dispose();
    _playerController.dispose();
    super.dispose();
  }

  void _updateEvent() {
    if (!_formKey.currentState!.validate()) return;
    final minutes =
        int.tryParse(_minutesController.text.trim()) ?? widget.event.minutes;
    final player = _playerController.text.trim();

    context.read<EventBloc>().add(
      EventUpdate(
        event: widget.event,
        minutes: minutes,
        player: player,
        eventType: _selectedType,
        teamId: widget.event.teamId,
      ),
    );
    setState(() => _submitting = true);
  }

  void _deleteEvent() async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (_) {
        final isDarkMode = context.isDarkMode;
        return AlertDialog(
          backgroundColor: isDarkMode
              ? AppColors.cardDark
              : AppColors.cardLight,
          title: Text(
            'Conferma eliminazione',
            style: TextStyle(
              color: isDarkMode
                  ? AppColors.textDarkPrimary
                  : AppColors.textLightPrimary,
            ),
          ),
          content: Text(
            'Eliminare l\'evento di ${widget.event.player} al ${widget.event.minutes}\'?',
            style: TextStyle(
              color: isDarkMode
                  ? AppColors.textDarkSecondary
                  : AppColors.textLightSecondary,
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text('Annulla'),
            ),
            TextButton(
              onPressed: () => Navigator.pop(context, true),
              child: const Text('Elimina', style: TextStyle(color: Colors.red)),
            ),
          ],
        );
      },
    );

    if (confirm != true || !mounted) return;

    setState(() => _submitting = true);

    context.read<EventBloc>().add(EventDelete(eventId: widget.event.id));
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

        if (state is EventUpdateSuccess) {
          if (!mounted) return;
          showSnackBar(context, 'Evento aggiornato');
          Navigator.of(context).pop('updated');
        } else if (state is EventDeleteSuccess) {
          context.read<EventBloc>().add(
            EventFetchMatchEvents(matchId: widget.event.matchId),
          );
        } else if (state is EventDisplaySuccess) {
          if (!mounted) return;
          widget.onClose();
          showSnackBar(context, 'Evento eliminato');
        } else if (state is EventFailure) {
          if (!mounted) return;
          showSnackBar(context, 'Errore: ${state.error}');
          setState(() => _submitting = false);
        }
      },
      child: Form(
        key: _formKey,
        child: Column(
          children: [
            TextFormField(
              controller: _minutesController,
              keyboardType: TextInputType.number,
              style: TextStyle(color: textColor),
              decoration: InputDecoration(
                labelText: 'Minuto',
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
              validator: (v) {
                final val = int.tryParse(v?.trim() ?? '');
                if (val == null || val < 0) return 'Inserisci un minuto valido';
                return null;
              },
            ),
            const SizedBox(height: 12),

            TextFormField(
              controller: _playerController,
              style: TextStyle(color: textColor),
              decoration: InputDecoration(
                labelText: 'Giocatore',
                filled: true,
                fillColor: inputFillColor,
                labelStyle: TextStyle(color: secondaryTextColor),
                enabledBorder: OutlineInputBorder(
                  borderSide: BorderSide(color: inputBorderColor),
                  borderRadius: BorderRadius.circular(8),
                ),
                focusedBorder: OutlineInputBorder(
                  borderSide: BorderSide(color: AppColors.primary),
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              validator: (v) => (v ?? '').trim().isEmpty
                  ? 'Inserisci il nome del giocatore'
                  : null,
            ),
            const SizedBox(height: 12),

            DropdownButtonFormField<EventType>(
              initialValue: _selectedType,
              items: EventType.values
                  .map(
                    (et) => DropdownMenuItem(
                      value: et,
                      child: Text(et.value, style: TextStyle(color: textColor)),
                    ),
                  )
                  .toList(),
              onChanged: (v) {
                if (v != null) setState(() => _selectedType = v);
              },
              decoration: InputDecoration(
                labelText: 'Tipo evento',
                filled: true,
                fillColor: inputFillColor,
                labelStyle: TextStyle(color: secondaryTextColor),
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
            const SizedBox(height: 20),

            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: _submitting
                        ? null
                        : () => Navigator.of(context).pop(),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: textColor,
                      side: BorderSide(color: AppColors.secondary),
                    ),
                    child: const Text('Annulla'),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton(
                    onPressed: _submitting ? null : _updateEvent,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      foregroundColor: Colors.white,
                    ),
                    child: const Text('Salva'),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),

            Center(
              child: TextButton.icon(
                onPressed: _submitting ? null : _deleteEvent,
                icon: const Icon(Icons.delete, color: Colors.red),
                label: const Text(
                  'Elimina evento',
                  style: TextStyle(color: Colors.red),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
