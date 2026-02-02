import 'package:package_info_plus/package_info_plus.dart';

class AppInfo {
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

  static String versionWithBuild() {
    return 'vN/A';
  }
}
