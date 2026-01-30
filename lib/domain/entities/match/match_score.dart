import 'package:real_amis/domain/entities/event/event_entity.dart';
import 'package:real_amis/domain/entities/match/match_entity.dart';
import 'package:real_amis/domain/entities/event/event_type.dart';

class MatchScore {
  final int home;
  final int away;

  const MatchScore({required this.home, required this.away});

  factory MatchScore.fromEvents(MatchEntity match, List<EventEntity> events) {
    final homeGoals = events
        .where(
          (e) => e.teamId == match.homeTeamId && e.eventType == EventType.goal,
        )
        .length;
    final awayGoals = events
        .where(
          (e) => e.teamId == match.awayTeamId && e.eventType == EventType.goal,
        )
        .length;

    return MatchScore(home: homeGoals, away: awayGoals);
  }
}
