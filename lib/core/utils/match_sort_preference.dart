import 'package:shared_preferences/shared_preferences.dart';

/// Ricorda l'ordinamento scelto dall'utente nell'elenco delle partite.
class MatchSortPreference {
  static const _key = 'matches_sort_ascending';

  /// `true` = dalla più vecchia alla più recente (valore di partenza).
  static Future<bool> getAscending() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_key) ?? true;
  }

  static Future<void> saveAscending(bool ascending) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_key, ascending);
  }
}
