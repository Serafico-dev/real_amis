import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:real_amis/common/widgets/appBar/app_bar_yes_nav.dart';
import 'package:real_amis/common/widgets/button/basic_app_button.dart';
import 'package:real_amis/common/widgets/loader/loader.dart';
import 'package:real_amis/common/widgets/textFields/number_field_nullable.dart';
import 'package:real_amis/common/widgets/textFields/text_field_nullable.dart';
import 'package:real_amis/core/utils/format_data.dart';
import 'package:real_amis/core/utils/show_snackbar.dart';
import 'package:real_amis/domain/entities/match/match_entity.dart';
import 'package:real_amis/domain/entities/team/team_entity.dart';
import 'package:real_amis/presentation/match/bloc/match_bloc.dart';
import 'package:real_amis/presentation/team/bloc/team_bloc.dart';
import 'package:flutter_datetime_picker_plus/flutter_datetime_picker_plus.dart';

class EditMatchPage extends StatefulWidget {
  static MaterialPageRoute route(MatchEntity match) =>
      MaterialPageRoute(builder: (context) => EditMatchPage(match: match));
  final MatchEntity match;
  const EditMatchPage({super.key, required this.match});

  @override
  State<EditMatchPage> createState() => _EditMatchState();
}

class _EditMatchState extends State<EditMatchPage> {
  DateTime? selectedDate;
  TeamEntity? homeTeam;
  TeamEntity? awayTeam;
  final matchDayController = TextEditingController();
  final homeTeamScoreController = TextEditingController();
  final awayTeamScoreController = TextEditingController();
  final formKey = GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();
    context.read<TeamBloc>().add(TeamFetchAllTeams());
  }

  void updateMatch() async {
    context.read<MatchBloc>().add(
      MatchUpdate(
        match: widget.match,
        matchDate: selectedDate != widget.match.matchDate
            ? selectedDate
            : widget.match.matchDate,
        homeTeamId: homeTeam != null ? homeTeam!.id : widget.match.homeTeamId,
        awayTeamId: awayTeam != null ? awayTeam!.id : widget.match.awayTeamId,
        homeTeamScore: homeTeamScoreController.text.trim().isNotEmpty
            ? int.parse(homeTeamScoreController.text.trim())
            : widget.match.homeTeamScore,
        awayTeamScore: awayTeamScoreController.text.trim().isNotEmpty
            ? int.parse(awayTeamScoreController.text.trim())
            : widget.match.awayTeamScore,
        matchDay: matchDayController.text.trim().isNotEmpty
            ? matchDayController.text.toUpperCase().trim()
            : widget.match.matchDay,
      ),
    );
  }

  @override
  void dispose() {
    super.dispose();
    matchDayController.dispose();
    homeTeamScoreController.dispose();
    awayTeamScoreController.dispose();
  }

  Widget _buildTeamDropdowns(List<TeamEntity> teams) {
    return Column(
      children: [
        DropdownButton<TeamEntity>(
          value: homeTeam,
          hint: Text('Seleziona Squadra in Casa'),
          onChanged: (TeamEntity? newValue) {
            setState(() {
              homeTeam = newValue;
            });
          },
          items: teams.map<DropdownMenuItem<TeamEntity>>((TeamEntity team) {
            return DropdownMenuItem<TeamEntity>(
              value: team,
              child: Text(team.name),
            );
          }).toList(),
        ),
        SizedBox(height: 15),
        DropdownButton<TeamEntity>(
          value: awayTeam,
          hint: Text('Seleziona Squadra Ospite'),
          onChanged: (TeamEntity? newValue) {
            setState(() {
              awayTeam = newValue;
            });
          },
          items: teams.map<DropdownMenuItem<TeamEntity>>((TeamEntity team) {
            return DropdownMenuItem<TeamEntity>(
              value: team,
              child: Text(team.name),
            );
          }).toList(),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    var date = selectedDate;

    return Scaffold(
      appBar: AppBarYesNav(
        title: Text('Modifica partita'),
        actions: [
          IconButton(
            onPressed: () {
              updateMatch();
            },
            icon: Icon(Icons.done_rounded, size: 25),
          ),
        ],
      ),
      body: Column(
        children: [
          BlocConsumer<TeamBloc, TeamState>(
            listener: (context, state) {
              if (state is TeamFailure) {
                showSnackBar(context, state.error);
              }
            },
            builder: (context, state) {
              if (state is TeamLoading) {
                return Loader();
              }
              if (state is TeamDisplaySuccess) {
                return _buildTeamDropdowns(state.teams);
              }
              return SizedBox();
            },
          ),
          BlocConsumer<MatchBloc, MatchState>(
            listener: (context, state) {
              if (state is MatchFailure) {
                showSnackBar(context, state.error);
              } else if (state is MatchUpdateSuccess) {
                Navigator.pop(context, state.updatedMatch);
              } else if (state is MatchDeleteSuccess) {
                Navigator.pop(context, true);
              }
            },
            builder: (context, state) {
              if (state is MatchLoading) {
                return Loader();
              }

              return SingleChildScrollView(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Form(
                    key: formKey,
                    child: Column(
                      children: [
                        Text(
                          date == null
                              ? 'Non hai ancora scelto una data'
                              : formatDateByddMMYYYYHHmm(date),
                        ),
                        ElevatedButton.icon(
                          icon: const Icon(Icons.calendar_today),
                          onPressed: () async {
                            var pickedDate =
                                await DatePicker.showDateTimePicker(
                                  context,
                                  showTitleActions: true,
                                  minTime: DateTime(2020, 1, 1),
                                  maxTime: DateTime(2040, 12, 31),
                                  currentTime: selectedDate ?? DateTime.now(),
                                  locale: LocaleType.it,
                                );
                            setState(() {
                              selectedDate = pickedDate;
                            });
                          },
                          label: Text('Scegli una nuova data'),
                        ),
                        SizedBox(height: 15),
                        TextFieldNullable(
                          controller: matchDayController,
                          hintText:
                              'Specifica la giornata (${widget.match.matchDay})',
                        ),
                        SizedBox(height: 15),
                        NumberFieldNullable(
                          controller: homeTeamScoreController,
                          hintText:
                              'Goal squadra in casa (${widget.match.homeTeamScore})',
                        ),
                        SizedBox(height: 15),
                        NumberFieldNullable(
                          controller: awayTeamScoreController,
                          hintText:
                              'Goal squadra ospite (${widget.match.awayTeamScore})',
                        ),
                        SizedBox(height: 15),
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
                                          title: Text('Conferma eliminazione'),
                                          content: Text(
                                            'Sei sicuro di voler eliminare questa partita?',
                                          ),
                                          actions: [
                                            TextButton(
                                              onPressed: () => Navigator.of(
                                                context,
                                              ).pop(false),
                                              child: Text('Annulla'),
                                            ),
                                            TextButton(
                                              onPressed: () => Navigator.of(
                                                context,
                                              ).pop(true),
                                              child: Text(
                                                'Elimina',
                                                style: TextStyle(
                                                  color: Colors.red,
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),
                                      );
                                      if (confirmed == true) {
                                        context.read<MatchBloc>().add(
                                          MatchDelete(matchId: widget.match.id),
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
          ),
        ],
      ),
    );
  }
}
