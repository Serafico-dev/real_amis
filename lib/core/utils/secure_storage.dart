import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class SecureStorage {
  final FlutterSecureStorage _storage;
  static const _keySession = 'supabase_session';
  static const _keyAccessToken = 'access_token';
  static const _keyRefreshToken = 'refresh_token';
  static const _keyExpiresAt = 'expires_at';

  SecureStorage([FlutterSecureStorage? storage])
    : _storage = storage ?? const FlutterSecureStorage();

  Future<void> saveSession(String sessionJson) =>
      _storage.write(key: _keySession, value: sessionJson);

  Future<String?> readSession() => _storage.read(key: _keySession);

  Future<void> deleteSession() => _storage.delete(key: _keySession);

  Future<void> saveToken(String token) =>
      _storage.write(key: _keyAccessToken, value: token);

  Future<String?> readToken() => _storage.read(key: _keyAccessToken);

  Future<void> deleteToken() => _storage.delete(key: _keyAccessToken);

  Future<void> saveRefreshToken(String token) =>
      _storage.write(key: _keyRefreshToken, value: token);

  Future<String?> readRefreshToken() => _storage.read(key: _keyRefreshToken);

  Future<void> deleteRefreshToken() => _storage.delete(key: _keyRefreshToken);

  Future<void> saveExpiresAt(int seconds) =>
      _storage.write(key: _keyExpiresAt, value: seconds.toString());

  Future<int?> readExpiresAt() async {
    final v = await _storage.read(key: _keyExpiresAt);
    return v == null ? null : int.tryParse(v);
  }

  Future<void> deleteExpiresAt() => _storage.delete(key: _keyExpiresAt);

  Future<void> clearAll() async {
    await deleteSession();
    await deleteToken();
    await deleteRefreshToken();
    await deleteExpiresAt();
  }
}
