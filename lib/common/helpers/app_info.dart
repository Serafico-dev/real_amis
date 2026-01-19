import 'package:package_info_plus/package_info_plus.dart';

class AppInfo {
  /// Restituisce "vX.Y.Z (build)" oppure 'N/A' se non disponibile.
  static Future<String> versionWithBuildAsync() async {
    try {
      final info = await PackageInfo.fromPlatform();
      final version = info.version;
      final build = info.buildNumber;
      return 'v$version ($build)';
    } catch (_) {
      return 'N/A';
    }
  }

  /// Sincronous helper che prova a leggere cached value se disponibile.
  /// Per semplicità nella UI usa la versione async:
  static String versionWithBuild() {
    // Se preferisci evitare async nella build, puoi chiamare versionWithBuildAsync()
    // e mostrare un placeholder; qui ritorniamo un placeholder.
    return 'vN/A';
  }
}
