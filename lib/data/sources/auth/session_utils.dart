import 'dart:convert';

String buildSupabaseSessionJson({
  required String accessToken,
  String? refreshToken,
  int? expiresAtSeconds,
  String? tokenType,
  String? providerToken,
  Map<String, dynamic>? user,
}) {
  final session = <String, dynamic>{
    'access_token': accessToken,
    if (refreshToken != null) 'refresh_token': refreshToken,
    if (expiresAtSeconds != null) 'expires_at': expiresAtSeconds,
    if (tokenType != null) 'token_type': tokenType,
    if (providerToken != null) 'provider_token': providerToken,
    'user': user ?? {},
  };

  return jsonEncode(session);
}
