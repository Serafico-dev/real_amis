import 'package:real_amis/data/models/league/league_model.dart';
import 'package:real_amis/data/models/team/team_model.dart';
import 'package:real_amis/domain/entities/match/match_entity.dart';
import 'package:real_amis/domain/entities/league/league_entity.dart';

/// Nel DB l'orario di una partita è salvato come "ora scritta a mano" senza
/// fuso (es. partita alle 15:00 → `15:00:00+00`), e l'app lo mostra così com'è.
/// Letto da Supabase, però, arriva come istante UTC: se lo si usasse tale e
/// quale (per esempio per programmare le notifiche) risulterebbe spostato
/// dell'offset del fuso (+1/+2 ore in Italia). Qui lo riporto a un normale
/// DateTime locale con la stessa ora scritta, coerente con ciò che si vede.
DateTime _asLocalWallClock(DateTime date) => date.isUtc
    ? DateTime(
        date.year,
        date.month,
        date.day,
        date.hour,
        date.minute,
        date.second,
      )
    : date;

class MatchModel extends MatchEntity {
  MatchModel({
    required super.id,
    required super.updatedAt,
    required super.matchDate,
    required super.homeTeamId,
    required super.awayTeamId,
    super.matchDay,
    super.homeTeam,
    super.awayTeam,
    required super.leagueId,
    super.league,
    super.calledUpIds = const [],
    super.played,
  });

  Map<String, dynamic> toJson() {
    return <String, dynamic>{
      'id': id,
      'updated_at': updatedAt.toIso8601String(),
      'match_date': matchDate.toIso8601String(),
      'home_team_id': homeTeamId,
      'away_team_id': awayTeamId,
      'match_day': matchDay ?? '',
      'league_id': leagueId,
      'called_up_ids': calledUpIds,
      'played': played,
    };
  }

  factory MatchModel.fromJson(Map<String, dynamic> map) {
    return MatchModel(
      id: map['id'] as String? ?? '',
      updatedAt: map['updated_at'] != null
          ? DateTime.tryParse(map['updated_at'].toString()) ?? DateTime.now()
          : DateTime.now(),
      matchDate: map['match_date'] != null
          ? _asLocalWallClock(
              DateTime.tryParse(map['match_date'].toString()) ?? DateTime.now(),
            )
          : DateTime.now(),
      homeTeamId: map['home_team_id'] as String? ?? '',
      awayTeamId: map['away_team_id'] as String? ?? '',
      matchDay: map['match_day']?.toString() ?? '',
      homeTeam: map['home_team'] != null
          ? TeamModel.fromJson(map['home_team'] as Map<String, dynamic>)
          : null,
      awayTeam: map['away_team'] != null
          ? TeamModel.fromJson(map['away_team'] as Map<String, dynamic>)
          : null,

      leagueId: map['league_id'] as String? ?? '',
      league: map['League'] != null
          ? LeagueModel.fromJson(map['League'] as Map<String, dynamic>)
          : null,
      calledUpIds:
          (map['called_up_ids'] as List<dynamic>?)
              ?.map((e) => e.toString())
              .toList() ??
          [],
      played: map['played'] as bool? ?? false,
    );
  }

  MatchModel copyWith({
    String? id,
    DateTime? updatedAt,
    DateTime? matchDate,
    String? homeTeamId,
    String? awayTeamId,
    String? matchDay,
    TeamModel? homeTeam,
    TeamModel? awayTeam,
    String? leagueId,
    LeagueEntity? league,
    List<String>? calledUpIds,
    bool? played,
  }) {
    return MatchModel(
      id: id ?? this.id,
      updatedAt: updatedAt ?? this.updatedAt,
      matchDate: matchDate ?? this.matchDate,
      homeTeamId: homeTeamId ?? this.homeTeamId,
      awayTeamId: awayTeamId ?? this.awayTeamId,
      matchDay: matchDay ?? this.matchDay,
      homeTeam: homeTeam ?? this.homeTeam,
      awayTeam: awayTeam ?? this.awayTeam,
      leagueId: leagueId ?? this.leagueId,
      league: league ?? this.league,
      calledUpIds: calledUpIds ?? this.calledUpIds,
      played: played ?? this.played,
    );
  }
}
