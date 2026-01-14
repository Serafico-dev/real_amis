import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:real_amis/domain/entities/event/event_type.dart';
import 'package:real_amis/domain/entities/match/match_entity.dart';
import 'package:real_amis/presentation/match/bloc/match_bloc.dart';
import 'package:real_amis/core/utils/show_snackbar.dart';
import 'package:real_amis/presentation/event/bloc/event_bloc.dart';

class AddEventModal extends StatefulWidget {
  final MatchEntity match;
  const AddEventModal({super.key, required this.match});

  @override
  State<AddEventModal> createState() => _AddEventModalState();
}

class _AddEventModalState extends State<AddEventModal> {
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
    final teamId = isHome
        ? widget.match.homeTeam!.id
        : widget.match.awayTeam!.id;
    final eventType = selectedType;

    context.read<EventBloc>().add(
      EventUpload(
        teamId: teamId,
        player: playerController.text.trim(),
        minutes: int.parse(minuteController.text.trim()),
        eventType: eventType,
      ),
    );

    setState(() => _submitting = true);

    late final StreamSubscription<EventState> sub;
    sub = context.read<EventBloc>().stream.listen((state) {
      if (state is EventLoading) return;
      if (state is EventUploadSuccess) {
        showSnackBar(
          context,
          'Evento aggiunto: ${eventType.value} ${isHome ? widget.match.homeTeam?.name : widget.match.awayTeam?.name} (${int.parse(minuteController.text.trim())}\')',
        );
        Navigator.of(context).pop();
      } else if (state is EventFailure) {
        showSnackBar(context, 'Errore: ${state.error}');
      }
      setState(() => _submitting = false);
      sub.cancel();
      context.read<MatchBloc>().add(MatchFetchAllMatches());
    });
  }

  @override
  Widget build(BuildContext context) {
    final bottom = MediaQuery.of(context).viewInsets.bottom;
    return Padding(
      padding: EdgeInsets.fromLTRB(20, 20, 20, 20 + bottom),
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 40,
              height: 4,
              margin: EdgeInsets.only(bottom: 8),
              decoration: BoxDecoration(
                color: Colors.grey[300],
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            Text(
              'Aggiungi evento',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
            ),
            SizedBox(height: 12),
            Column(
              children: [
                ListTile(
                  leading: Radio<String>(
                    value: 'home',
                    groupValue: teamSide,
                    onChanged: (v) {
                      if (v == null) return;
                      setState(() => teamSide = v);
                    },
                  ),
                  title: Text(widget.match.homeTeam?.name ?? 'Home'),
                  onTap: () => setState(() => teamSide = 'home'),
                ),
                ListTile(
                  leading: Radio<String>(
                    value: 'away',
                    groupValue: teamSide,
                    onChanged: (v) {
                      if (v == null) return;
                      setState(() => teamSide = v);
                    },
                  ),
                  title: Text(widget.match.awayTeam?.name ?? 'Away'),
                  onTap: () => setState(() => teamSide = 'away'),
                ),
              ],
            ),

            SizedBox(height: 12),
            Form(
              key: _formKey,
              child: Column(
                children: [
                  TextFormField(
                    controller: playerController,
                    decoration: InputDecoration(labelText: 'Giocatore'),
                    validator: (v) {
                      if (v == null || v.trim().isEmpty) {
                        return 'Inserisci un giocatore';
                      }
                      return null;
                    },
                  ),
                  SizedBox(height: 12),
                  TextFormField(
                    controller: minuteController,
                    keyboardType: TextInputType.number,
                    decoration: InputDecoration(labelText: 'Minuto'),
                    validator: (v) {
                      if (v == null || v.trim().isEmpty) {
                        return 'Inserisci il minuto';
                      } else {
                        final n = int.tryParse(v.trim());
                        if (n == null || n < 0) {
                          return 'Minuto non valido';
                        }
                        return null;
                      }
                    },
                  ),
                  SizedBox(height: 12),
                  DropdownButtonFormField<EventType>(
                    initialValue: selectedType,
                    items: EventType.values
                        .map(
                          (e) =>
                              DropdownMenuItem(value: e, child: Text(e.value)),
                        )
                        .toList(),
                    onChanged: (v) {
                      if (v == null) return;
                      setState(() => selectedType = v);
                    },
                  ),
                  SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton(
                          onPressed: _submitting
                              ? null
                              : () => Navigator.of(context).pop(),
                          child: Text('Annulla'),
                        ),
                      ),
                      SizedBox(width: 12),
                      Expanded(
                        child: ElevatedButton(
                          onPressed: _submitting ? null : _submit,
                          child: _submitting
                              ? SizedBox(
                                  height: 16,
                                  width: 16,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                  ),
                                )
                              : Text('Aggiungi'),
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 16),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
