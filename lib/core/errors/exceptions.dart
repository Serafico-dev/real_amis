class ServerException implements Exception {
  final String message;
  const ServerException(this.message);

  /// Costruisce l'eccezione a partire da un messaggio d'errore qualsiasi
  /// (es. quello di una AuthException/PostgrestException), sostituendo i
  /// testi tecnici di rete con un messaggio comprensibile all'utente.
  factory ServerException.fromMessage(String message) {
    if (_isNetworkError(message)) {
      return const ServerException(
        'Impossibile raggiungere il server. Controlla la connessione a '
        'internet (o prova a cambiare rete/DNS) e riprova.',
      );
    }
    return ServerException(message);
  }

  /// Come [fromMessage], partendo da un oggetto errore generico.
  factory ServerException.fromError(Object error) =>
      ServerException.fromMessage(error.toString());

  static bool _isNetworkError(String text) {
    final lower = text.toLowerCase();
    return lower.contains('socketexception') ||
        lower.contains('failed host lookup') ||
        lower.contains('network is unreachable') ||
        lower.contains('connection refused') ||
        lower.contains('connection reset') ||
        lower.contains('connection closed') ||
        lower.contains('timeoutexception') ||
        lower.contains('handshakeexception');
  }

  @override
  String toString() => message;
}
