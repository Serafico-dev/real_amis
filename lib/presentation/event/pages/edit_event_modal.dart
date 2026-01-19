import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:real_amis/core/utils/show_snackbar.dart';
import 'package:real_amis/domain/entities/event/event_entity.dart';
import 'package:real_amis/domain/entities/event/event_type.dart';
import 'package:real_amis/presentation/event/bloc/event_bloc.dart';

class EditEventModal extends StatefulWidget {
  final EventEntity event;
  const EditEventModal({super.key, required this.event});

  @override
  State<EditEventModal> createState() => _EditEventModalState();
}

class _EditEventModalState extends State<EditEventModal> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _minutesController;
  late TextEditingController _playerController;
  late EventType _selectedType;
  late String _teamId;
  late final StreamSubscription<EventState> _sub;

  @override
  void initState() {
    super.initState();
    context.read<EventBloc>().add(
      EventFetchMatchEvents(matchId: widget.event.matchId),
    );
    _minutesController = TextEditingController(
      text: widget.event.minutes.toString(),
    );
    _playerController = TextEditingController(text: widget.event.player);
    _selectedType = widget.event.eventType is String
        ? EventTypeX.fromString(widget.event.eventType as String)
        : (widget.event.eventType);
    _teamId = widget.event.teamId;
    _sub = context.read<EventBloc>().stream.listen((state) {
      if (state is EventLoading) return;
      if (state is EventUpdateSuccess) {
        if (!mounted) return;
        showSnackBar(context, 'Evento aggiornato');
        _sub.cancel();
        Navigator.of(context).pop('updated');
      } else if (state is EventDeleteSuccess) {
        if (!mounted) return;
        showSnackBar(context, 'Evento eliminato');
        _sub.cancel();
        Navigator.of(context).pop('deleted');
      } else if (state is EventFailure) {
        if (!mounted) return;
        showSnackBar(context, 'Errore: ${state.error}');
        _sub.cancel();
      }
    });
  }

  @override
  void dispose() {
    _sub.cancel();
    _minutesController.dispose();
    _playerController.dispose();
    super.dispose();
  }

  void _updateEvent() async {
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
        teamId: _teamId,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
      ),
      child: FractionallySizedBox(
        heightFactor: 0.65,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            SizedBox(height: 12),
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.grey[400],
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            SizedBox(height: 12),
            Expanded(
              child: SingleChildScrollView(
                padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Modifica evento',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      SizedBox(height: 12),
                      TextFormField(
                        controller: _minutesController,
                        keyboardType: TextInputType.number,
                        decoration: InputDecoration(
                          labelText: 'Minuto',
                          hintText: 'Es. 45',
                        ),
                        validator: (v) {
                          final val = int.tryParse(v?.trim() ?? '');
                          if (val == null || val < 0) {
                            return 'Inserisci un minuto valido';
                          }
                          return null;
                        },
                      ),
                      SizedBox(height: 12),
                      TextFormField(
                        controller: _playerController,
                        decoration: InputDecoration(
                          labelText: 'Giocatore',
                          hintText: 'Nome giocatore',
                        ),
                        validator: (v) {
                          if ((v ?? '').trim().isEmpty) {
                            return 'Inserisci il nome del giocatore';
                          }
                          return null;
                        },
                      ),
                      SizedBox(height: 12),
                      DropdownButtonFormField<EventType>(
                        initialValue: _selectedType,
                        decoration: InputDecoration(labelText: 'Tipo evento'),
                        items: EventType.values.map((et) {
                          return DropdownMenuItem<EventType>(
                            value: et,
                            child: Text(et.value.toString()),
                          );
                        }).toList(),
                        onChanged: (v) {
                          if (v != null) setState(() => _selectedType = v);
                        },
                      ),
                      SizedBox(height: 20),
                      Row(
                        children: [
                          Expanded(
                            child: OutlinedButton(
                              onPressed: () => Navigator.of(context).pop(),
                              child: Text('Annulla'),
                            ),
                          ),
                          SizedBox(width: 12),
                          Expanded(
                            child: ElevatedButton(
                              onPressed: () {
                                _updateEvent();
                                Navigator.of(context).pop();
                              },
                              child: Text(
                                'Salva',
                                style: TextStyle(color: Colors.white),
                              ),
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: 12),
                      Center(
                        child: TextButton.icon(
                          onPressed: () async {
                            final confirm = await showDialog<bool>(
                              context: context,
                              builder: (_) => AlertDialog(
                                title: Text('Conferma eliminazione'),
                                content: Text(
                                  'Eliminare l\'evento di ${widget.event.player} al ${widget.event.minutes}\'?',
                                ),
                                actions: [
                                  TextButton(
                                    onPressed: () =>
                                        Navigator.pop(context, false),
                                    child: Text('Annulla'),
                                  ),
                                  TextButton(
                                    onPressed: () {
                                      context.read<EventBloc>().add(
                                        EventDelete(eventId: widget.event.id),
                                      );
                                      Navigator.pop(context, true);
                                    },

                                    child: Text(
                                      'Elimina',
                                      style: TextStyle(color: Colors.red),
                                    ),
                                  ),
                                ],
                              ),
                            );
                            if (confirm == true && context.mounted) {
                              Navigator.of(context).pop(null);
                            }
                          },
                          icon: Icon(Icons.delete, color: Colors.red),
                          label: Text(
                            'Elimina evento',
                            style: TextStyle(color: Colors.red),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
