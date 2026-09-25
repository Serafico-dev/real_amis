import 'package:shared_preferences/shared_preferences.dart';

/// Ricorda l'ultimo girone (League) selezionato dall'utente nei filtri a
/// chip, condiviso tra le schermate Partite e Squadre così la scelta resta
/// coerente passando dall'una all'altra.
class LeagueSelectionPreference {
  static const _key = 'last_selected_league_id';

  static Future<String?> getSavedLeagueId() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_key);
  }

  static Future<void> saveLeagueId(String leagueId) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_key, leagueId);
  }
}
