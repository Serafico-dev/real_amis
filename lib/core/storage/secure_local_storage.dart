import 'package:real_amis/core/storage/secure_storage.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class SecureLocalStorage extends LocalStorage {
  final SecureStorage _secureStorage;

  SecureLocalStorage(this._secureStorage);

  @override
  Future<void> initialize() async {}

  @override
  Future<String?> accessToken() => _secureStorage.readToken();

  @override
  Future<bool> hasAccessToken() async {
    final token = await _secureStorage.readToken();
    return token != null;
  }

  @override
  Future<void> persistSession(String persistSessionString) =>
      _secureStorage.saveSession(persistSessionString);

  @override
  Future<void> removePersistedSession() => _secureStorage.clearAll();
}
