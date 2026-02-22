import 'package:flutter/material.dart';
import 'package:real_amis/core/storage/secure_storage.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class SecureLocalStorage extends LocalStorage {
  final SecureStorage _secureStorage;

  SecureLocalStorage(this._secureStorage);

  @override
  Future<void> initialize() async {
    debugPrint('[SecureLocalStorage] initialize() chiamato');
  }

  @override
  Future<String?> accessToken() async {
    final session = await _secureStorage.readSession();
    debugPrint(
      '[SecureLocalStorage] accessToken() → ${session != null ? 'sessione trovata' : 'nessuna sessione'}',
    );
    return session;
  }

  @override
  Future<bool> hasAccessToken() async {
    final session = await _secureStorage.readSession();
    final has = session != null;
    debugPrint('[SecureLocalStorage] hasAccessToken() → $has');
    return has;
  }

  @override
  Future<void> persistSession(String persistSessionString) async {
    debugPrint(
      '[SecureLocalStorage] persistSession() → salvataggio sessione (${persistSessionString.length} chars)',
    );
    await _secureStorage.saveSession(persistSessionString);
  }

  @override
  Future<void> removePersistedSession() async {
    debugPrint(
      '[SecureLocalStorage] removePersistedSession() → pulizia storage',
    );
    await _secureStorage.clearAll();
  }
}
