enum EventType { goal, giallo, rosso }

/// Valore salvato nel campo `player` di un evento per indicare un autogoal.
///
/// L'evento va registrato sulla squadra che *beneficia* del gol (così il
/// punteggio della partita è corretto) e non è collegato ad alcun giocatore,
/// quindi non modifica le statistiche individuali.
const String ownGoalLabel = 'Autogoal';

/// Riconosce un autogoal anche se il nome è stato scritto a mano
/// (maiuscole/minuscole e spazi non contano).
bool isOwnGoalName(String name) =>
    name.trim().toLowerCase() == ownGoalLabel.toLowerCase();

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

  static EventType fromString(String? s) {
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
