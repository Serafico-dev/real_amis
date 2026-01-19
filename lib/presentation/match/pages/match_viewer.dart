import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:real_amis/common/cubits/app_user/app_user_cubit.dart';
import 'package:real_amis/common/widgets/appBar/app_bar_yes_nav.dart';
import 'package:real_amis/common/widgets/loader/loader.dart';
import 'package:real_amis/core/configs/theme/app_colors.dart';
import 'package:real_amis/core/utils/format_data.dart';
import 'package:real_amis/core/utils/show_snackbar.dart';
import 'package:real_amis/domain/entities/event/event_entity.dart';
import 'package:real_amis/domain/entities/event/event_type.dart';
import 'package:real_amis/domain/entities/match/match_entity.dart';
import 'package:real_amis/presentation/event/bloc/event_bloc.dart';
import 'package:real_amis/presentation/event/pages/add_event_modal.dart';
import 'package:real_amis/presentation/event/pages/edit_event_modal.dart';
import 'package:real_amis/presentation/match/bloc/match_bloc.dart';
import 'package:real_amis/presentation/match/pages/edit_match.dart';

class MatchViewerPage extends StatefulWidget {
  static MaterialPageRoute route(String matchId) => MaterialPageRoute(
    builder: (context) => MatchViewerPage(matchId: matchId),
  );
  final String matchId;
  const MatchViewerPage({super.key, required this.matchId});

  @override
  State<MatchViewerPage> createState() => _MatchViewerPageState();
}

class _MatchViewerPageState extends State<MatchViewerPage> {
  @override
  void initState() {
    super.initState();
    context.read<MatchBloc>().add(MatchFetchAllMatches());
    context.read<EventBloc>().add(
      EventFetchMatchEvents(matchId: widget.matchId),
    );
  }

  Future<void> _refresh() async {
    context.read<MatchBloc>().add(MatchFetchAllMatches());
    context.read<EventBloc>().add(
      EventFetchMatchEvents(matchId: widget.matchId),
    );
  }

  Future<void> _openAddModal(MatchEntity match) async {
    final result = await showModalBottomSheet<String?>(
      context: context,
      isScrollControlled: true,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (_) => AddEventModal(match: match),
    );
    if (result == 'created' || result == 'updated' || result == 'deleted') {
      if (!mounted) return;
      context.read<EventBloc>().add(
        EventFetchMatchEvents(matchId: widget.matchId),
      );
      context.read<MatchBloc>().add(MatchFetchAllMatches());
    }
  }

  Future<void> _openEditModal(EventEntity ev) async {
    final result = await showModalBottomSheet<String?>(
      context: context,
      isScrollControlled: true,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (_) => EditEventModal(event: ev),
    );
    if (result == 'updated' || result == 'deleted' || result == 'created') {
      if (!mounted) return;
      context.read<EventBloc>().add(
        EventFetchMatchEvents(matchId: widget.matchId),
      );
      context.read<MatchBloc>().add(MatchFetchAllMatches());
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBarYesNav(
        title: Text('Dettaglio partita'),
        actions: [
          BlocSelector<AppUserCubit, AppUserState, bool?>(
            selector: (state) =>
                state is AppUserLoggedIn ? state.user.isAdmin : false,
            builder: (context, isAdmin) {
              if (isAdmin != true) return SizedBox.shrink();
              return IconButton(
                onPressed: () async {
                  final bloc = context.read<MatchBloc>();
                  final currentState = bloc.state;
                  MatchEntity? currentMatch;
                  if (currentState is MatchDisplaySuccess) {
                    final matches = currentState.matches.where(
                      (p) => p.id == widget.matchId,
                    );
                    if (matches.isEmpty) {
                      currentMatch = null;
                    } else {
                      currentMatch = matches.first;
                    }
                  }
                  if (currentState is MatchUpdateSuccess) {
                    currentMatch = currentState.updatedMatch;
                  }
                  final matchToEdit = currentMatch;
                  if (matchToEdit == null) {
                    showSnackBar(context, 'Partita non trovata');
                    return;
                  }
                  await Navigator.push(
                    context,
                    EditMatchPage.route(matchToEdit),
                  );
                  if (context.mounted) {
                    context.read<MatchBloc>().add(MatchFetchAllMatches());
                  }
                },
                icon: Icon(Icons.edit, size: 25),
              );
            },
          ),
        ],
      ),
      body: BlocBuilder<MatchBloc, MatchState>(
        builder: (context, state) {
          if (state is MatchLoading) {
            return Loader();
          }
          MatchEntity? match;
          if (state is MatchDisplaySuccess) {
            final matches = state.matches.where((p) => p.id == widget.matchId);
            if (matches.isEmpty) {
              match = null;
            } else {
              match = matches.first;
            }
          }
          if (state is MatchUpdateSuccess) {
            match = state.updatedMatch;
          }
          if (match == null || state is MatchDeleteSuccess) {
            return Center(child: Text('Partita non trovata.'));
          }

          return RefreshIndicator(
            onRefresh: _refresh,
            child: Scrollbar(
              child: SingleChildScrollView(
                physics: AlwaysScrollableScrollPhysics(),
                child: Column(
                  children: [
                    Container(
                      margin: EdgeInsets.all(16.0),
                      padding: const EdgeInsets.all(16.0),
                      decoration: BoxDecoration(
                        color: AppColors.tertiary,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.end,
                            children: [
                              Text(
                                match.matchDay ?? '',
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 20,
                                ),
                              ),
                            ],
                          ),
                          Text(
                            formatDateByddMMYYYYnHHmm(match.matchDate),
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                            ),
                          ),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceAround,
                            children: [
                              Column(
                                children: [
                                  CachedNetworkImage(
                                    imageUrl: match.homeTeam!.imageUrl,
                                    width: 100,
                                    fit: BoxFit.cover,
                                  ),
                                  SizedBox(height: 10),
                                  Text(
                                    match.homeTeamScore.toString(),
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 24,
                                    ),
                                  ),
                                ],
                              ),
                              Text(
                                'VS',
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 24,
                                ),
                              ),
                              Column(
                                children: [
                                  CachedNetworkImage(
                                    imageUrl: match.awayTeam!.imageUrl,
                                    width: 100,
                                    fit: BoxFit.cover,
                                  ),
                                  SizedBox(height: 10),
                                  Text(
                                    match.awayTeamScore.toString(),
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 24,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                          if (match.matchDate.isBefore(DateTime.now()))
                            Text(
                              'FULL TIME',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 20,
                              ),
                              textAlign: TextAlign.center,
                            ),
                        ],
                      ),
                    ),
                    BlocListener<EventBloc, EventState>(
                      listener: (context, state) {
                        if (state is EventUploadSuccess ||
                            state is EventUpdateSuccess ||
                            state is EventDeleteSuccess) {
                          context.read<EventBloc>().add(
                            EventFetchMatchEvents(matchId: widget.matchId),
                          );
                          context.read<MatchBloc>().add(MatchFetchAllMatches());
                        }
                      },
                      child: BlocBuilder<EventBloc, EventState>(
                        builder: (context, eventState) {
                          final m = match!;

                          if (eventState is EventLoading) {
                            return SizedBox(
                              height: 80,
                              child: Center(child: CircularProgressIndicator()),
                            );
                          }

                          final List<EventEntity> events =
                              eventState is EventDisplaySuccess
                              ? List<EventEntity>.from(eventState.events)
                              : <EventEntity>[];

                          final homeEvents =
                              events
                                  .where((e) => e.teamId == m.homeTeamId)
                                  .toList()
                                ..sort(
                                  (a, b) => a.minutes.compareTo(b.minutes),
                                );

                          final awayEvents =
                              events
                                  .where((e) => e.teamId == m.awayTeamId)
                                  .toList()
                                ..sort(
                                  (a, b) => a.minutes.compareTo(b.minutes),
                                );

                          if (homeEvents.isEmpty && awayEvents.isEmpty) {
                            return SizedBox.shrink();
                          }

                          return Container(
                            margin: EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 8,
                            ),
                            padding: EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: AppColors.tertiary,
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        m.homeTeam?.name ?? 'Casa',
                                        style: TextStyle(
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                      SizedBox(height: 8),
                                      ...homeEvents.map<Widget>((ev) {
                                        final minutes = ev.minutes;
                                        final player = ev.player;
                                        final EventType type =
                                            ev.eventType is String
                                            ? EventTypeX.fromString(
                                                ev.eventType as String,
                                              )
                                            : ev.eventType;
                                        return Padding(
                                          padding: const EdgeInsets.symmetric(
                                            vertical: 4.0,
                                          ),
                                          child: Row(
                                            children: [
                                              Text(
                                                '$minutes\'',
                                                style: TextStyle(
                                                  fontWeight: FontWeight.bold,
                                                ),
                                              ),
                                              SizedBox(width: 8),
                                              Icon(
                                                type == EventType.goal
                                                    ? Icons.sports_soccer
                                                    : Icons.circle,
                                                color: type == EventType.rosso
                                                    ? Colors.red
                                                    : (type == EventType.giallo
                                                          ? Colors.yellow
                                                          : Colors.black),
                                                size: 18,
                                              ),
                                              SizedBox(width: 8),
                                              Expanded(child: Text(player)),
                                              SizedBox(width: 8),
                                              BlocSelector<
                                                AppUserCubit,
                                                AppUserState,
                                                bool?
                                              >(
                                                selector: (s) =>
                                                    s is AppUserLoggedIn
                                                    ? s.user.isAdmin
                                                    : false,
                                                builder: (context, isAdmin) {
                                                  if (isAdmin != true) {
                                                    return SizedBox.shrink();
                                                  }
                                                  return IconButton(
                                                    icon: Icon(
                                                      Icons.edit,
                                                      size: 18,
                                                    ),
                                                    onPressed: () =>
                                                        _openEditModal(ev),
                                                  );
                                                },
                                              ),
                                            ],
                                          ),
                                        );
                                      }),
                                    ],
                                  ),
                                ),
                                //SizedBox(width: 16),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.end,
                                    children: [
                                      Text(
                                        m.awayTeam?.name ?? 'Ospite',
                                        style: TextStyle(
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                      SizedBox(height: 8),
                                      ...awayEvents.map<Widget>((ev) {
                                        final minutes = ev.minutes;
                                        final player = ev.player;
                                        final EventType type =
                                            ev.eventType is String
                                            ? EventTypeX.fromString(
                                                ev.eventType as String,
                                              )
                                            : ev.eventType;
                                        return Padding(
                                          padding: const EdgeInsets.symmetric(
                                            vertical: 4.0,
                                          ),
                                          child: Row(
                                            mainAxisAlignment:
                                                MainAxisAlignment.end,
                                            children: [
                                              BlocSelector<
                                                AppUserCubit,
                                                AppUserState,
                                                bool?
                                              >(
                                                selector: (s) =>
                                                    s is AppUserLoggedIn
                                                    ? s.user.isAdmin
                                                    : false,
                                                builder: (context, isAdmin) {
                                                  if (isAdmin != true) {
                                                    return SizedBox.shrink();
                                                  }
                                                  return IconButton(
                                                    icon: Icon(
                                                      Icons.edit,
                                                      size: 18,
                                                    ),
                                                    onPressed: () =>
                                                        _openEditModal(ev),
                                                  );
                                                },
                                              ),
                                              SizedBox(width: 8),
                                              Expanded(
                                                child: Text(
                                                  player,
                                                  textAlign: TextAlign.right,
                                                ),
                                              ),
                                              SizedBox(width: 8),
                                              Icon(
                                                type == EventType.goal
                                                    ? Icons.sports_soccer
                                                    : Icons.circle,
                                                color: type == EventType.rosso
                                                    ? Colors.red
                                                    : (type == EventType.giallo
                                                          ? Colors.yellow
                                                          : Colors.black),
                                                size: 18,
                                              ),
                                              SizedBox(width: 8),
                                              Text(
                                                '$minutes\'',
                                                style: TextStyle(
                                                  fontWeight: FontWeight.bold,
                                                ),
                                              ),
                                            ],
                                          ),
                                        );
                                      }),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          );
                        },
                      ),
                    ),

                    BlocSelector<AppUserCubit, AppUserState, bool?>(
                      selector: (s) =>
                          s is AppUserLoggedIn ? s.user.isAdmin : false,
                      builder: (context, isAdmin) {
                        if (isAdmin != true) return SizedBox.shrink();
                        return ElevatedButton.icon(
                          onPressed: () => _openAddModal(match!),
                          icon: Icon(Icons.add, color: Colors.white),
                          label: Text(
                            'Aggiungi evento',
                            style: TextStyle(color: Colors.white),
                          ),
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
    );
  }
}
