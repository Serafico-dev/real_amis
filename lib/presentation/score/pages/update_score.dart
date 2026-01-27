import 'package:flutter/material.dart';
import 'package:real_amis/common/widgets/appBar/app_bar_yes_nav.dart';
import 'package:real_amis/common/widgets/textFields/number_field_nullable.dart';
import 'package:real_amis/core/utils/show_snackbar.dart';
import 'package:real_amis/domain/entities/score/score_entity.dart';

class UpdateScorePage extends StatefulWidget {
  final ScoreEntity scoreEntity;
  final String teamId;
  final String leagueId;

  const UpdateScorePage({
    super.key,
    required this.scoreEntity,
    required this.teamId,
    required this.leagueId,
  });

  static MaterialPageRoute<ScoreEntity?> route({
    required ScoreEntity scoreEntity,
    required String teamId,
    required String leagueId,
  }) => MaterialPageRoute<ScoreEntity?>(
    builder: (_) => UpdateScorePage(
      scoreEntity: scoreEntity,
      teamId: teamId,
      leagueId: leagueId,
    ),
  );

  @override
  State<UpdateScorePage> createState() => _UpdateScorePageState();
}

class _UpdateScorePageState extends State<UpdateScorePage> {
  late TextEditingController _controller;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(
      text: widget.scoreEntity.score.toString(),
    );
  }

  void _saveScore() {
    final value = int.tryParse(_controller.text.trim());
    if (value == null) {
      showSnackBar(context, "Inserisci un numero valido");
      return;
    }

    final updatedEntity = ScoreEntity(
      id: widget.scoreEntity.id,
      leagueId: widget.leagueId,
      teamId: widget.teamId,
      score: value,
    );

    Navigator.pop(context, updatedEntity);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBarYesNav(
        title: const Text("Aggiorna punteggio"),
        actions: [
          IconButton(onPressed: _saveScore, icon: const Icon(Icons.done)),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: NumberFieldNullable(
          controller: _controller,
          labelText: 'Punteggio',
          hintText: '0',
        ),
      ),
    );
  }
}
