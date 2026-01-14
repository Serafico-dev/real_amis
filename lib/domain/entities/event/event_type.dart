enum EventType { goal, giallo, rosso }

extension EventTypeX on EventType {
  String get value {
    switch (this) {
      case EventType.goal:
        return 'Goal';
      case EventType.giallo:
        return 'Giallo';
      case EventType.rosso:
        return 'Rosso';
    }
  }

  static EventType fromString(String s) {
    switch (s) {
      case 'Goal':
        return EventType.goal;
      case 'Giallo':
        return EventType.giallo;
      case 'Rosso':
        return EventType.rosso;
      default:
        return EventType.goal;
    }
  }
}
